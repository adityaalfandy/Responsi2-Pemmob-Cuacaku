import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import '../models/weather_forecast_model.dart';

/// Exception khusus untuk kesalahan saat mengakses API Open-Meteo.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Service REST API Open-Meteo menggunakan HTTP GET.
class OpenMeteoService {
  OpenMeteoService({http.Client? client}) : _client = client ?? http.Client();

  static const String _forecastHost = 'api.open-meteo.com';
  static const String _geocodingHost = 'geocoding-api.open-meteo.com';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  /// Mengambil data cuaca terkini, per jam, dan harian dari Open-Meteo Forecast API.
  Future<WeatherForecastModel> fetchWeather({
    required double latitude,
    required double longitude,
    int forecastDays = 7,
  }) async {
    final uri = Uri.https(_forecastHost, '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': [
        'temperature_2m',
        'relative_humidity_2m',
        'apparent_temperature',
        'is_day',
        'precipitation',
        'weather_code',
        'wind_speed_10m',
        'wind_direction_10m',
        'surface_pressure',
        'cloud_cover',
      ].join(','),
      'hourly': [
        'temperature_2m',
        'weather_code',
        'precipitation_probability',
      ].join(','),
      'daily': [
        'weather_code',
        'temperature_2m_max',
        'temperature_2m_min',
        'precipitation_probability_max',
        'sunrise',
        'sunset',
        'uv_index_max',
        'wind_speed_10m_max',
      ].join(','),
      'timezone': 'auto',
      'forecast_days': forecastDays.toString(),
    });

    final decoded = await _getJson(uri);
    return WeatherForecastModel.fromJson(decoded);
  }

  /// Mencari daftar kota berdasarkan nama melalui Open-Meteo Geocoding API.
  Future<List<LocationModel>> searchCities(
    String query, {
    int count = 15,
    String language = 'en',
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    final uri = Uri.https(_geocodingHost, '/v1/search', {
      'name': trimmed,
      'count': count.toString(),
      'language': language,
      'format': 'json',
    });

    final decoded = await _getJson(uri);
    final rawResults = decoded['results'] as List<dynamic>?;
    if (rawResults == null || rawResults.isEmpty) {
      return [];
    }

    return rawResults
        .whereType<Map<String, dynamic>>()
        .map(LocationModel.fromGeocodingJson)
        .toList();
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);

      final body = response.body.trim();
      Map<String, dynamic>? decoded;
      if (body.isNotEmpty) {
        final raw = jsonDecode(body);
        if (raw is Map<String, dynamic>) {
          decoded = raw;
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded == null) {
          throw const ApiException('Respons server kosong atau tidak valid.');
        }
        if (decoded['error'] == true) {
          final reason = decoded['reason'] as String?;
          throw ApiException(
            reason?.isNotEmpty == true
                ? reason!
                : 'Open-Meteo menolak permintaan data.',
            statusCode: response.statusCode,
          );
        }
        return decoded;
      }

      final reason = decoded?['reason'] as String?;
      throw ApiException(
        reason?.isNotEmpty == true
            ? reason!
            : 'Permintaan gagal dengan kode HTTP ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on http.ClientException {
      throw const ApiException(
        'Gagal terhubung ke server Open-Meteo. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      throw const ApiException(
        'Waktu permintaan ke server habis. Silakan coba lagi.',
      );
    } on FormatException catch (e) {
      throw ApiException('Gagal membaca format data cuaca: ${e.message}');
    } catch (e) {
      throw ApiException('Terjadi kesalahan jaringan: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
