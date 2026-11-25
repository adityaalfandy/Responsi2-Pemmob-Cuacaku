import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:responsi_weather/models/weather_condition.dart';
import 'package:responsi_weather/services/open_meteo_service.dart';

void main() {
  group('OpenMeteoService & Models', () {
    test('fetchWeather sends GET request with timezone=auto and parses JSON',
        () async {
      late Uri capturedUri;
      late String capturedMethod;

      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        capturedMethod = request.method;
        return http.Response(
          jsonEncode(_sampleForecastPayload),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = OpenMeteoService(client: mockClient);
      final forecast = await service.fetchWeather(
        latitude: -7.80139,
        longitude: 110.36472,
      );

      expect(capturedMethod, 'GET');
      expect(capturedUri.host, 'api.open-meteo.com');
      expect(capturedUri.path, '/v1/forecast');
      expect(capturedUri.queryParameters['timezone'], 'auto');
      expect(capturedUri.queryParameters['latitude'], '-7.80139');
      expect(capturedUri.queryParameters['longitude'], '110.36472');
      expect(capturedUri.queryParameters['current'], contains('temperature_2m'));
      expect(
        capturedUri.queryParameters['daily'],
        contains('precipitation_probability_max'),
      );

      expect(forecast.current.temperature2m, 28.8);
      expect(forecast.current.relativeHumidity2m, 74);
      expect(forecast.current.apparentTemperature, 33.9);
      expect(forecast.current.precipitation, 0.10);
      expect(forecast.current.weatherCode, 51);
      expect(forecast.current.windSpeed10m, 7.8);
      expect(forecast.daily.length, 2);
      expect(forecast.daily.first.temperature2mMax, 31.2);
      expect(forecast.daily.first.temperature2mMin, 24.9);
      expect(forecast.daily.first.precipitationProbabilityMax, 99);
    });

    test('searchCities parses Geocoding results and handles omitted results key',
        () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.host, 'geocoding-api.open-meteo.com');
        final name = request.url.queryParameters['name'];
        if (name == 'zzzznotfound') {
          return http.Response(
            jsonEncode({'generationtime_ms': 0.16}),
            200,
          );
        }
        return http.Response(
          jsonEncode(_sampleGeocodingPayload),
          200,
        );
      });

      final service = OpenMeteoService(client: mockClient);

      final found = await service.searchCities('Yogyakarta');
      expect(found, hasLength(1));
      expect(found.first.name, 'Yogyakarta');
      expect(found.first.country, 'Indonesia');
      expect(found.first.admin1, 'Special Region of Yogyakarta');

      final empty = await service.searchCities('zzzznotfound');
      expect(empty, isEmpty);
    });

    test('throws ApiException with Open-Meteo reason on API error response',
        () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'reason': 'Latitude must be in range of -90 to 90°.',
            'error': true,
          }),
          400,
        );
      });

      final service = OpenMeteoService(client: mockClient);

      expect(
        () => service.fetchWeather(latitude: 999, longitude: 0),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Latitude must be in range'),
          ),
        ),
      );
    });

    test('WeatherCondition maps WMO codes accurately', () {
      expect(WeatherCondition.fromWmoCode(0).label, 'Cerah');
      expect(WeatherCondition.fromWmoCode(51).label, 'Gerimis Ringan');
      expect(WeatherCondition.fromWmoCode(95).label, 'Badai Petir');
    });
  });
}

const Map<String, dynamic> _sampleForecastPayload = {
  'latitude': -7.768,
  'longitude': 110.392,
  'timezone': 'Asia/Jakarta',
  'timezone_abbreviation': 'GMT+7',
  'elevation': 106.0,
  'current_units': {
    'temperature_2m': '°C',
    'relative_humidity_2m': '%',
    'apparent_temperature': '°C',
    'precipitation': 'mm',
    'wind_speed_10m': 'km/h',
    'surface_pressure': 'hPa',
  },
  'current': {
    'time': '2026-11-25T10:15',
    'temperature_2m': 28.8,
    'relative_humidity_2m': 74,
    'apparent_temperature': 33.9,
    'is_day': 1,
    'precipitation': 0.10,
    'weather_code': 51,
    'wind_speed_10m': 7.8,
    'wind_direction_10m': 189,
    'surface_pressure': 1000.4,
    'cloud_cover': 19,
  },
  'hourly': {
    'time': ['2026-11-25T10:00', '2026-11-25T11:00'],
    'temperature_2m': [28.8, 29.5],
    'weather_code': [51, 2],
    'precipitation_probability': [65, 30],
  },
  'daily': {
    'time': ['2026-11-25', '2026-11-26'],
    'weather_code': [51, 61],
    'temperature_2m_max': [31.2, 30.6],
    'temperature_2m_min': [24.9, 24.6],
    'precipitation_probability_max': [99, 85],
    'sunrise': ['2026-11-25T05:09', '2026-11-26T05:10'],
    'sunset': ['2026-11-25T17:40', '2026-11-26T17:41'],
    'uv_index_max': [7.15, 8.7],
    'wind_speed_10m_max': [14.2, 16.0],
  },
};

const Map<String, dynamic> _sampleGeocodingPayload = {
  'results': [
    {
      'id': 1621177,
      'name': 'Yogyakarta',
      'latitude': -7.80139,
      'longitude': 110.36472,
      'elevation': 110.0,
      'country_code': 'ID',
      'timezone': 'Asia/Jakarta',
      'population': 375699,
      'country': 'Indonesia',
      'admin1': 'Special Region of Yogyakarta',
      'admin2': 'Kota Yogyakarta',
    },
  ],
  'generationtime_ms': 0.1,
};
