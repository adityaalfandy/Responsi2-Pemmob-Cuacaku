import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

/// ViewModel (MVVM) untuk mengelola mode tema aplikasi secara konsisten.
class ThemeViewModel extends ChangeNotifier {
  ThemeViewModel({required this._storageService});

  final LocalStorageService _storageService;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void initialize() {
    _themeMode = _storageService.loadThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _storageService.saveThemeMode(mode);
    notifyListeners();
  }

  /// Berpindah antar mode Terang, Gelap, dan Sistem.
  Future<void> cycleThemeMode() async {
    final next = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
  }

  String get themeModeLabel => switch (_themeMode) {
        ThemeMode.system => 'Ikuti Sistem',
        ThemeMode.light => 'Mode Terang',
        ThemeMode.dark => 'Mode Gelap',
      };

  IconData get themeModeIcon => switch (_themeMode) {
        ThemeMode.system => Icons.brightness_auto_rounded,
        ThemeMode.light => Icons.light_mode_rounded,
        ThemeMode.dark => Icons.dark_mode_rounded,
      };
}
