import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_forecast_model.dart';
import '../services/local_storage_service.dart';
import '../services/open_meteo_service.dart';

/// Status pencarian kota pada Search / Location Screen.
enum SearchStatus {
  idle,
  loading,
  loaded,
  empty,
  error,
}

/// ViewModel (MVVM) untuk pencarian lokasi (Geocoding API), riwayat pencarian,
/// dan daftar lokasi favorit yang disimpan di Local Storage.
class SearchLocationViewModel extends ChangeNotifier {
  SearchLocationViewModel({
    required this._apiService,
    required this._storageService,
  });

  final OpenMeteoService _apiService;
  final LocalStorageService _storageService;

  SearchStatus _status = SearchStatus.idle;
  String _query = '';
  List<LocationModel> _results = [];
  String? _errorMessage;
  List<LocationModel> _favorites = [];
  List<LocationModel> _searchHistory = [];

  final Map<String, WeatherForecastModel> _favoriteForecasts = {};
  final Set<String> _loadingFavoriteKeys = {};
  final Map<String, String> _favoriteErrors = {};

  int _searchSequence = 0;

  SearchStatus get status => _status;
  String get query => _query;
  List<LocationModel> get results => List.unmodifiable(_results);
  String? get errorMessage => _errorMessage;
  List<LocationModel> get favorites => List.unmodifiable(_favorites);
  List<LocationModel> get searchHistory => List.unmodifiable(_searchHistory);

  WeatherForecastModel? previewFor(LocationModel location) =>
      _favoriteForecasts[location.uniqueKey];

  bool isPreviewLoading(LocationModel location) =>
      _loadingFavoriteKeys.contains(location.uniqueKey);

  String? previewErrorFor(LocationModel location) =>
      _favoriteErrors[location.uniqueKey];

  /// Memuat data favorit dan riwayat pencarian dari Local Storage saat aplikasi dibuka.
  void initialize() {
    _favorites = _storageService.loadFavorites();
    _searchHistory = _storageService.loadSearchHistory();
    notifyListeners();
  }

  /// Mencari kota menggunakan Open-Meteo Geocoding API (HTTP GET).
  Future<void> searchCities(String rawQuery) async {
    _query = rawQuery;
    final trimmed = rawQuery.trim();

    if (trimmed.isEmpty) {
      _searchSequence++;
      _results = [];
      _errorMessage = null;
      _status = SearchStatus.idle;
      notifyListeners();
      return;
    }

    final seq = ++_searchSequence;
    _status = SearchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final locations = await _apiService.searchCities(trimmed);
      if (seq != _searchSequence) return;

      _results = locations;
      _status = locations.isEmpty ? SearchStatus.empty : SearchStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      if (seq != _searchSequence) return;
      _results = [];
      _errorMessage = e.message;
      _status = SearchStatus.error;
    } catch (e) {
      if (seq != _searchSequence) return;
      _results = [];
      _errorMessage = 'Terjadi kesalahan saat mencari lokasi: $e';
      _status = SearchStatus.error;
    }
    notifyListeners();
  }

  /// Mengosongkan input pencarian dan kembali ke tampilan riwayat & favorit.
  void clearSearch() {
    _searchSequence++;
    _query = '';
    _results = [];
    _errorMessage = null;
    _status = SearchStatus.idle;
    notifyListeners();
  }

  /// Mengecek apakah suatu lokasi tersimpan dalam daftar favorit.
  bool isFavorite(LocationModel location) {
    final key = location.uniqueKey;
    return _favorites.any((item) => item.uniqueKey == key);
  }

  /// Menambah atau menghapus lokasi favorit dan menyimpannya ke Local Storage.
  Future<bool> toggleFavorite(LocationModel location) async {
    final key = location.uniqueKey;
    final existingIndex = _favorites.indexWhere((item) => item.uniqueKey == key);
    final updated = List<LocationModel>.from(_favorites);

    late final bool added;
    if (existingIndex >= 0) {
      updated.removeAt(existingIndex);
      added = false;
    } else {
      updated.insert(0, location);
      added = true;
    }

    _favorites = updated;
    await _storageService.saveFavorites(_favorites);
    notifyListeners();

    if (added) {
      await fetchFavoritePreview(location);
    }
    return added;
  }

  /// Mencatat lokasi yang dipilih pengguna ke dalam riwayat pencarian lokal.
  Future<void> addToHistory(LocationModel location) async {
    final key = location.uniqueKey;
    final updated = List<LocationModel>.from(_searchHistory)
      ..removeWhere((item) => item.uniqueKey == key)
      ..insert(0, location);

    _searchHistory =
        updated.take(LocalStorageService.maxHistoryItems).toList();
    await _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  /// Menghapus satu item dari riwayat pencarian lokal.
  Future<void> removeHistoryItem(LocationModel location) async {
    final key = location.uniqueKey;
    _searchHistory = _searchHistory
        .where((item) => item.uniqueKey != key)
        .toList();
    await _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  /// Menghapus seluruh riwayat pencarian dari Local Storage.
  Future<void> clearHistory() async {
    _searchHistory = [];
    await _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  /// Memuat ringkasan cuaca terkini langsung dari Open-Meteo API untuk seluruh kota favorit.
  Future<void> refreshAllFavoritePreviews() async {
    if (_favorites.isEmpty) return;
    await Future.wait(_favorites.map(fetchFavoritePreview));
  }

  /// Mengambil ringkasan cuaca live untuk satu lokasi favorit.
  Future<void> fetchFavoritePreview(LocationModel location) async {
    final key = location.uniqueKey;
    if (_loadingFavoriteKeys.contains(key)) return;

    _loadingFavoriteKeys.add(key);
    _favoriteErrors.remove(key);
    notifyListeners();

    try {
      final weather = await _apiService.fetchWeather(
        latitude: location.latitude,
        longitude: location.longitude,
        forecastDays: 1,
      );
      _favoriteForecasts[key] = weather;
    } on ApiException catch (e) {
      _favoriteErrors[key] = e.message;
    } catch (_) {
      _favoriteErrors[key] = 'Gagal memuat cuaca';
    } finally {
      _loadingFavoriteKeys.remove(key);
      notifyListeners();
    }
  }
}
