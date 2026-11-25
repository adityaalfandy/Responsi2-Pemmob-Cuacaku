import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_forecast_model.dart';
import '../services/local_storage_service.dart';
import '../services/open_meteo_service.dart';

/// Status state utama pada Home / Weather Screen.
enum WeatherViewStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// ViewModel (MVVM) yang mengelola data cuaca kota aktif dari Open-Meteo API.
class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel({
    required this._apiService,
    required this._storageService,
  });

  final OpenMeteoService _apiService;
  final LocalStorageService _storageService;

  WeatherViewStatus _status = WeatherViewStatus.initial;
  LocationModel? _selectedLocation;
  WeatherForecastModel? _forecast;
  String? _errorMessage;
  bool _isRefreshing = false;
  int _requestSequence = 0;

  WeatherViewStatus get status => _status;
  LocationModel? get selectedLocation => _selectedLocation;
  WeatherForecastModel? get forecast => _forecast;
  String? get errorMessage => _errorMessage;
  bool get isRefreshing => _isRefreshing;

  /// Menginisialisasi lokasi dari Local Storage lalu mengambil cuaca terkini via API.
  Future<void> initialize({bool useDefaultIfEmpty = true}) async {
    final saved = _storageService.loadSelectedLocation();
    if (saved != null) {
      _selectedLocation = saved;
      await fetchWeather();
      return;
    }

    if (useDefaultIfEmpty) {
      _selectedLocation = LocalStorageService.defaultLocation;
      await _storageService.saveSelectedLocation(_selectedLocation);
      await fetchWeather();
    } else {
      _status = WeatherViewStatus.empty;
      notifyListeners();
    }
  }

  /// Mengganti kota aktif, menyimpan ke Local Storage, dan mengambil data cuaca API.
  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    await _storageService.saveSelectedLocation(location);
    await fetchWeather(clearPrevious: true);
  }

  /// Menghapus kota aktif untuk menampilkan kondisi data kosong pada Home Screen.
  Future<void> clearLocation() async {
    _requestSequence++;
    _selectedLocation = null;
    _forecast = null;
    _errorMessage = null;
    _isRefreshing = false;
    _status = WeatherViewStatus.empty;
    await _storageService.saveSelectedLocation(null);
    notifyListeners();
  }

  /// Mengambil data cuaca terbaru dari Open-Meteo Forecast API untuk lokasi aktif.
  Future<void> fetchWeather({bool clearPrevious = false}) async {
    final location = _selectedLocation;
    if (location == null) {
      _status = WeatherViewStatus.empty;
      _forecast = null;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    final seq = ++_requestSequence;
    if (clearPrevious || _forecast == null) {
      _status = WeatherViewStatus.loading;
      if (clearPrevious) {
        _forecast = null;
      }
      _errorMessage = null;
    } else {
      _isRefreshing = true;
      _errorMessage = null;
    }
    notifyListeners();

    try {
      final result = await _apiService.fetchWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      if (seq != _requestSequence) return;

      if (result.daily.isEmpty && result.hourly.isEmpty) {
        _forecast = null;
        _status = WeatherViewStatus.empty;
      } else {
        _forecast = result;
        _status = WeatherViewStatus.loaded;
      }
      _errorMessage = null;
    } on ApiException catch (e) {
      if (seq != _requestSequence) return;
      _errorMessage = e.message;
      if (_forecast == null) {
        _status = WeatherViewStatus.error;
      }
    } catch (e) {
      if (seq != _requestSequence) return;
      _errorMessage = 'Gagal memuat data cuaca: $e';
      if (_forecast == null) {
        _status = WeatherViewStatus.error;
      }
    } finally {
      if (seq == _requestSequence) {
        _isRefreshing = false;
        notifyListeners();
      }
    }
  }
}
