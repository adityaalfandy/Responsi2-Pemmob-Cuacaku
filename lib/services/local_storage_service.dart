import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

/// Service Local Storage berbasis [SharedPreferences] untuk menyimpan
/// lokasi aktif, daftar lokasi favorit, riwayat pencarian, dan tema aplikasi.
class LocalStorageService {
  LocalStorageService(this._prefs);

  static const String _selectedLocationKey = 'selected_location_v1';
  static const String _favoritesKey = 'favorite_locations_v1';
  static const String _historyKey = 'search_history_v1';
  static const String _themeModeKey = 'theme_mode_v1';

  static const int maxHistoryItems = 10;

  final SharedPreferences _prefs;

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  /// Lokasi default awal jika belum ada lokasi tersimpan pada perangkat.
  static const LocationModel defaultLocation = LocationModel(
    id: 1630366,
    name: 'Purbalingga',
    latitude: -7.38806,
    longitude: 109.36389,
    country: 'Indonesia',
    countryCode: 'ID',
    admin1: 'Central Java',
    admin2: 'Purbalingga Regency',
    timezone: 'Asia/Jakarta',
    elevation: 61.0,
    population: 56903,
  );

  LocationModel? loadSelectedLocation() {
    final raw = _prefs.getString(_selectedLocationKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return LocationModel.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSelectedLocation(LocationModel? location) async {
    if (location == null) {
      await _prefs.remove(_selectedLocationKey);
      return;
    }
    await _prefs.setString(_selectedLocationKey, location.toJsonString());
  }

  List<LocationModel> loadFavorites() {
    return _loadLocationList(_favoritesKey);
  }

  Future<void> saveFavorites(List<LocationModel> favorites) async {
    await _saveLocationList(_favoritesKey, favorites);
  }

  List<LocationModel> loadSearchHistory() {
    return _loadLocationList(_historyKey);
  }

  Future<void> saveSearchHistory(List<LocationModel> history) async {
    final limited = history.take(maxHistoryItems).toList();
    await _saveLocationList(_historyKey, limited);
  }

  ThemeMode loadThemeMode() {
    final raw = _prefs.getString(_themeModeKey);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_themeModeKey, value);
  }

  List<LocationModel> _loadLocationList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocationList(
    String key,
    List<LocationModel> locations,
  ) async {
    final encoded = jsonEncode(locations.map((e) => e.toJson()).toList());
    await _prefs.setString(key, encoded);
  }
}
