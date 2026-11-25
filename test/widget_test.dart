import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:responsi_weather/app.dart';
import 'package:responsi_weather/services/local_storage_service.dart';
import 'package:responsi_weather/services/open_meteo_service.dart';
import 'package:responsi_weather/widgets/location_result_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'Home screen renders required Open-Meteo metrics and Search flow updates city',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final client = MockClient((request) async {
      if (request.url.host == 'geocoding-api.open-meteo.com') {
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

      final isBandung = request.url.queryParameters['latitude'] == '-6.92222';
      return http.Response(
        jsonEncode(isBandung ? _bandungForecast : _yogyakartaForecast),
        200,
      );
    });

    final storage = await LocalStorageService.create();
    final api = OpenMeteoService(client: client);

    await tester.pumpWidget(
      CuacaKuApp(apiService: api, storageService: storage),
    );
    await tester.pumpAndSettle();

    // Verifikasi seluruh data wajib pada Home / Weather Screen
    expect(find.text('Yogyakarta'), findsOneWidget);
    expect(find.text('28.8°C'), findsOneWidget);
    expect(find.text('Gerimis Ringan'), findsAtLeastNWidgets(1));
    expect(find.text('WMO 51'), findsAtLeastNWidgets(1));
    expect(find.text('74%'), findsOneWidget);
    expect(find.text('33.9°C'), findsOneWidget);
    expect(find.text('0.10 mm'), findsOneWidget);
    expect(find.text('7.8 km/h'), findsOneWidget);
    expect(find.text('100%'), findsAtLeastNWidgets(1));

    // Pindah ke Search / Location Screen melalui bottom NavigationBar
    await tester.tap(find.text('Cari Kota'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Bandung');
    await tester.tap(find.widgetWithText(FilledButton, 'Cari'));
    await tester.pumpAndSettle();

    final resultTile = find.descendant(
      of: find.byType(LocationResultTile),
      matching: find.text('Bandung'),
    );
    expect(resultTile, findsOneWidget);
    expect(find.text('West Java, Indonesia'), findsOneWidget);

    // Simpan Bandung sebagai favorit
    await tester.tap(find.byTooltip('Simpan sebagai favorit'));
    await tester.pumpAndSettle();

    // Pilih Bandung untuk melihat cuacanya di Home Screen
    await tester.tap(resultTile);
    await tester.pumpAndSettle();

    expect(find.text('22.4°C'), findsOneWidget);
    expect(find.text('Hujan Ringan'), findsAtLeastNWidgets(1));
    expect(storage.loadFavorites().single.name, 'Bandung');

    // Buka halaman Favorit dan pastikan kota favorit tersimpan tampil
    await tester.tap(find.text('Favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Lokasi Favorit'), findsOneWidget);
    expect(find.text('Bandung'), findsAtLeastNWidgets(1));
  });

  testWidgets('Home screen displays error view with retry and wide rail layout',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var failRequest = true;
    final client = MockClient((_) async {
      if (failRequest) {
        return http.Response(
          jsonEncode({'error': true, 'reason': 'Layanan tidak tersedia'}),
          503,
        );
      }
      return http.Response(jsonEncode(_yogyakartaForecast), 200);
    });

    final storage = await LocalStorageService.create();
    final api = OpenMeteoService(client: client);

    await tester.pumpWidget(
      CuacaKuApp(apiService: api, storageService: storage),
    );
    await tester.pumpAndSettle();

    // Layar lebar menggunakan NavigationRail
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Gagal Memuat Data Cuaca'), findsOneWidget);
    expect(find.text('Layanan tidak tersedia'), findsOneWidget);

    // Tekan tombol Coba Lagi setelah API pulih
    failRequest = false;
    await tester.tap(find.widgetWithText(FilledButton, 'Coba Lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Yogyakarta'), findsOneWidget);
    expect(find.text('28.8°C'), findsOneWidget);
  });
}

const Map<String, dynamic> _yogyakartaForecast = {
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
    'wind_direction_10m': 189,
    'surface_pressure': 1000.4,
    'cloud_cover': 19,
  },
  'hourly': {
    'time': ['2026-11-25T10:00', '2026-11-25T11:00'],
    'temperature_2m': [28.8, 29.4],
    'weather_code': [51, 2],
    'precipitation_probability': [70, 40],
  },
  'daily': {
    'time': ['2026-11-25', '2026-11-26'],
    'weather_code': [51, 61],
    'temperature_2m_max': [31.2, 30.6],
    'temperature_2m_min': [24.9, 24.6],
    'precipitation_probability_max': [100, 85],
    'sunrise': ['2026-11-25T05:09', '2026-11-26T05:10'],
    'sunset': ['2026-11-25T17:40', '2026-11-26T17:41'],
    'uv_index_max': [7.15, 8.7],
    'wind_speed_10m_max': [14.2, 16.0],
  },
};

const Map<String, dynamic> _bandungForecast = {
  'latitude': -6.92222,
  'longitude': 107.60694,
  'timezone': 'Asia/Jakarta',
  'timezone_abbreviation': 'GMT+7',
  'elevation': 700.0,
  'current': {
    'time': '2026-11-25T10:15',
    'temperature_2m': 22.4,
    'relative_humidity_2m': 82,
    'apparent_temperature': 23.1,
    'is_day': 1,
    'precipitation': 1.20,
    'weather_code': 61,
    'wind_speed_10m': 6.4,
    'wind_direction_10m': 120,
    'surface_pressure': 932.0,
    'cloud_cover': 75,
  },
  'hourly': {
    'time': ['2026-11-25T10:00', '2026-11-25T11:00'],
    'temperature_2m': [22.4, 22.9],
    'weather_code': [61, 61],
    'precipitation_probability': [80, 75],
  },
  'daily': {
    'time': ['2026-11-25', '2026-11-26'],
    'weather_code': [61, 3],
    'temperature_2m_max': [25.0, 26.2],
    'temperature_2m_min': [18.5, 19.0],
    'precipitation_probability_max': [85, 60],
  },
};
