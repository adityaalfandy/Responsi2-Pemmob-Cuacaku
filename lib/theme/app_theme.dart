import 'package:flutter/material.dart';

import 'app_typography.dart';

/// Konfigurasi Material 3 Theme (Terang & Gelap) untuk menjaga konsistensi desain aplikasi.
class AppTheme {
  const AppTheme._();

  static const Color _lightPrimary = Color(0xFF0B63CE);
  static const Color _lightSecondary = Color(0xFF0D8A8A);
  static const Color _lightSurface = Color(0xFFF3F6FA);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightOutline = Color(0xFFD8E2EE);

  static const Color _darkPrimary = Color(0xFF69B4FF);
  static const Color _darkSecondary = Color(0xFF52D1CE);
  static const Color _darkSurface = Color(0xFF0A1220);
  static const Color _darkCard = Color(0xFF131F34);
  static const Color _darkOutline = Color(0xFF263652);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _lightPrimary,
      brightness: Brightness.light,
      primary: _lightPrimary,
      secondary: _lightSecondary,
      surface: _lightSurface,
      surfaceContainerLowest: _lightCard,
      surfaceContainerLow: const Color(0xFFF9FBFD),
      surfaceContainer: const Color(0xFFEAF0F7),
      surfaceContainerHigh: const Color(0xFFE1E9F4),
      onSurface: const Color(0xFF0F1B2D),
      onSurfaceVariant: const Color(0xFF52647A),
      outlineVariant: _lightOutline,
    );

    return _buildTheme(scheme, cardColor: _lightCard);
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _darkPrimary,
      brightness: Brightness.dark,
      primary: _darkPrimary,
      secondary: _darkSecondary,
      surface: _darkSurface,
      surfaceContainerLowest: _darkCard,
      surfaceContainerLow: const Color(0xFF101B2E),
      surfaceContainer: const Color(0xFF182640),
      surfaceContainerHigh: const Color(0xFF1E2F4E),
      onSurface: const Color(0xFFEDF3FC),
      onSurfaceVariant: const Color(0xFF99ACC4),
      outlineVariant: _darkOutline,
    );

    return _buildTheme(scheme, cardColor: _darkCard);
  }

  static ThemeData _buildTheme(
    ColorScheme scheme, {
    required Color cardColor,
  }) {
    final textTheme = AppTypography.buildTextTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        hintStyle: textTheme.bodyMedium,
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cardColor,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        selectedColor: scheme.primary.withValues(alpha: 0.16),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
