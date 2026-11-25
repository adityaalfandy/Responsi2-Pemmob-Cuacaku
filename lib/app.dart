import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/local_storage_service.dart';
import 'services/open_meteo_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/search_location_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/main_shell_screen.dart';

/// Root widget aplikasi CuacaKu yang menyambungkan seluruh ViewModel (MVVM)
/// menggunakan [MultiProvider] dan menerapkan [AppTheme].
class CuacaKuApp extends StatelessWidget {
  const CuacaKuApp({
    super.key,
    required this.apiService,
    required this.storageService,
    this.initialTabIndex = 0,
  });

  final OpenMeteoService apiService;
  final LocalStorageService storageService;
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeViewModel>(
          create: (_) => ThemeViewModel(storageService: storageService)
            ..initialize(),
        ),
        ChangeNotifierProvider<SearchLocationViewModel>(
          create: (_) => SearchLocationViewModel(
            apiService: apiService,
            storageService: storageService,
          )..initialize(),
        ),
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => WeatherViewModel(
            apiService: apiService,
            storageService: storageService,
          )..initialize(),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVm, _) {
          return MaterialApp(
            title: 'CuacaKu — Prakiraan Cuaca',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeVm.themeMode,
            home: MainShellScreen(initialIndex: initialTabIndex),
          );
        },
      ),
    );
  }
}
