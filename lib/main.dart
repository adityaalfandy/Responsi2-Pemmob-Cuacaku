import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'services/local_storage_service.dart';
import 'services/open_meteo_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  final storageService = await LocalStorageService.create();
  final apiService = OpenMeteoService();

  runApp(
    CuacaKuApp(
      apiService: apiService,
      storageService: storageService,
    ),
  );
}
