import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:responsi_weather/models/location_model.dart';
import 'package:responsi_weather/services/local_storage_service.dart';
import 'package:responsi_weather/services/open_meteo_service.dart';
import 'package:responsi_weather/viewmodels/search_location_viewmodel.dart';
import 'package:responsi_weather/viewmodels/theme_viewmodel.dart';
import 'package:responsi_weather/viewmodels/weather_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ViewModels & LocalStorageService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('LocalStorageService persists and restores favorites, history, theme',
        () async {
      final storage = await LocalStorageService.create();
      const jakarta = LocationModel(
        id: 1642911,
        name: 'Jakarta',
        latitude: -6.21462,
        longitude: 106.84513,
        country: 'Indonesia',
        timezone: 'Asia/Jakarta',
      );

      await storage.saveSelectedLocation(jakarta);
      await storage.saveFavorites([jakarta]);
      await storage.saveSearchHistory([jakarta]);
      await storage.saveThemeMode(ThemeMode.dark);

      final reopenedStorage = await LocalStorageService.create();
      expect(reopenedStorage.loadSelectedLocation()?.name, 'Jakarta');
      expect(reopenedStorage.loadFavorites().single.name, 'Jakarta');
      expect(reopenedStorage.loadSearchHistory().single.name, 'Jakarta');
      expect(reopenedStorage.loadThemeMode(), ThemeMode.dark);
    });

    test('WeatherViewModel handles loaded, error, and empty states', () async {
      var shouldFail = false;
      final client = MockClient((_) async {
        if (shouldFail) {
          return http.Response(
            jsonEncode({'error': true, 'reason': 'Server sibuk'}),
            503,
          );
        }
        return http.Response(jsonEncode(_forecastJson), 200);
      });

      final storage = await LocalStorageService.create();
      final api = OpenMeteoService(client: client);
      final vm = WeatherViewModel(apiService: api, storageService: storage);

      await vm.initialize();
      expect(vm.status, WeatherViewStatus.loaded);
      expect(vm.selectedLocation?.name, 'Purbalingga');
      expect(vm.forecast?.current.temperature2m, 28.8);

      await vm.clearLocation();
      expect(vm.status, WeatherViewStatus.empty);
      expect(vm.selectedLocation, isNull);

      shouldFail = true;
      await vm.selectLocation(LocalStorageService.defaultLocation);
      expect(vm.status, WeatherViewStatus.error);
      expect(vm.errorMessage, 'Server sibuk');
    });

    test('SearchLocationViewModel handles search, empty, favorites, history',
        () async {
      final client = MockClient((request) async {
        if (request.url.host == 'geocoding-api.open-meteo.com') {
          final q = request.url.queryParameters['name'];
          if (q == 'Bandung') {
            return http.Response(
              jsonEncode({
                'results': [
                  {
                    'id': 1650357,
                    'name': 'Bandung',
                    'latitude': -6.92222,
                    'longitude': 107.60694,
                    'country': 'Indonesia',
                    'admin1': 'West Java',
                    'timezone': 'Asia/Jakarta',
                  },
                ],
              }),
              200,
            );
          }
          return http.Response(jsonEncode({'generationtime_ms': 0.1}), 200);
        }
        return http.Response(jsonEncode(_forecastJson), 200);
      });

      final storage = await LocalStorageService.create();
      final api = OpenMeteoService(client: client);
      final vm = SearchLocationViewModel(
        apiService: api,
        storageService: storage,
      )..initialize();

      await vm.searchCities('Bandung');
      expect(vm.status, SearchStatus.loaded);
      expect(vm.results.single.name, 'Bandung');

      final bandung = vm.results.single;
      final added = await vm.toggleFavorite(bandung);
      expect(added, isTrue);
      expect(vm.isFavorite(bandung), isTrue);

      await vm.addToHistory(bandung);
      expect(vm.searchHistory.single.name, 'Bandung');

      await vm.searchCities('TidakAdaKota');
      expect(vm.status, SearchStatus.empty);

      vm.clearSearch();
      expect(vm.status, SearchStatus.idle);
      expect(storage.loadFavorites().single.name, 'Bandung');
      expect(storage.loadSearchHistory().single.name, 'Bandung');
    });

    test('ThemeViewModel cycles and persists theme mode', () async {
      final storage = await LocalStorageService.create();
      final themeVm = ThemeViewModel(storageService: storage)..initialize();

      expect(themeVm.themeMode, ThemeMode.system);
      await themeVm.cycleThemeMode();
      expect(themeVm.themeMode, ThemeMode.light);
      expect(storage.loadThemeMode(), ThemeMode.light);
    });
  });
}

const Map<String, dynamic> _forecastJson = {
  'latitude': -7.768,
  'longitude': 110.392,
  'timezone': 'Asia/Jakarta',
  'timezone_abbreviation': 'GMT+7',
  'elevation': 106.0,
  'current': {
    'time': '2026-11-25T10:15',
    'temperature_2m': 28.8,
    'relative_humidity_2m': 74,
    'apparent_temperature': 33.9,
    'is_day': 1,
    'precipitation': 0.10,
    'weather_code': 51,
    'wind_speed_10m': 7.8,
  },
  'hourly': {
    'time': ['2026-11-25T10:00'],
    'temperature_2m': [28.8],
    'weather_code': [51],
    'precipitation_probability': [60],
  },
  'daily': {
    'time': ['2026-11-25'],
    'weather_code': [51],
    'temperature_2m_max': [31.2],
    'temperature_2m_min': [24.9],
    'precipitation_probability_max': [99],
  },
};
