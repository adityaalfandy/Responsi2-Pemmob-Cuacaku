import 'package:flutter/material.dart';

/// Kategori visual cuaca untuk menentukan ikon dan nuansa tema hero.
enum WeatherCategory {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  snow,
  thunderstorm,
}

/// Representasi terjemahan kode kondisi cuaca WMO dari Open-Meteo.
class WeatherCondition {
  const WeatherCondition({
    required this.code,
    required this.label,
    required this.description,
    required this.category,
  });

  final int code;
  final String label;
  final String description;
  final WeatherCategory category;

  /// Mengonversi kode WMO (`weather_code`) menjadi label, deskripsi, dan kategori.
  factory WeatherCondition.fromWmoCode(int code) {
    switch (code) {
      case 0:
        return const WeatherCondition(
          code: 0,
          label: 'Cerah',
          description: 'Langit cerah tanpa tutupan awan berarti.',
          category: WeatherCategory.clear,
        );
      case 1:
        return const WeatherCondition(
          code: 1,
          label: 'Sebagian Cerah',
          description: 'Didominasi langit cerah dengan sedikit awan.',
          category: WeatherCategory.clear,
        );
      case 2:
        return const WeatherCondition(
          code: 2,
          label: 'Berawan Sebagian',
          description: 'Awan tersebar di sebagian langit.',
          category: WeatherCategory.partlyCloudy,
        );
      case 3:
        return const WeatherCondition(
          code: 3,
          label: 'Mendung',
          description: 'Langit tertutup awan tebal.',
          category: WeatherCategory.cloudy,
        );
      case 45:
        return const WeatherCondition(
          code: 45,
          label: 'Berkabut',
          description: 'Jarak pandang berkurang akibat kabut.',
          category: WeatherCategory.fog,
        );
      case 48:
        return const WeatherCondition(
          code: 48,
          label: 'Kabut Beku',
          description: 'Kabut dingin yang membentuk lapisan es tipis.',
          category: WeatherCategory.fog,
        );
      case 51:
        return const WeatherCondition(
          code: 51,
          label: 'Gerimis Ringan',
          description: 'Rintik hujan halus dengan intensitas ringan.',
          category: WeatherCategory.drizzle,
        );
      case 53:
        return const WeatherCondition(
          code: 53,
          label: 'Gerimis Sedang',
          description: 'Gerimis berlangsung stabil dengan intensitas sedang.',
          category: WeatherCategory.drizzle,
        );
      case 55:
        return const WeatherCondition(
          code: 55,
          label: 'Gerimis Lebat',
          description: 'Gerimis rapat yang membuat permukaan cepat basah.',
          category: WeatherCategory.drizzle,
        );
      case 56:
      case 57:
        return WeatherCondition(
          code: code,
          label: code == 56 ? 'Gerimis Beku Ringan' : 'Gerimis Beku Lebat',
          description: 'Gerimis dingin yang berpotensi membeku saat menyentuh permukaan.',
          category: WeatherCategory.drizzle,
        );
      case 61:
        return const WeatherCondition(
          code: 61,
          label: 'Hujan Ringan',
          description: 'Hujan dengan intensitas ringan.',
          category: WeatherCategory.rain,
        );
      case 63:
        return const WeatherCondition(
          code: 63,
          label: 'Hujan Sedang',
          description: 'Hujan turun cukup konsisten dengan intensitas sedang.',
          category: WeatherCategory.rain,
        );
      case 65:
        return const WeatherCondition(
          code: 65,
          label: 'Hujan Lebat',
          description: 'Curah hujan tinggi, disarankan membawa pelindung hujan.',
          category: WeatherCategory.rain,
        );
      case 66:
      case 67:
        return WeatherCondition(
          code: code,
          label: code == 66 ? 'Hujan Beku Ringan' : 'Hujan Beku Lebat',
          description: 'Hujan bersuhu sangat rendah yang membeku di permukaan.',
          category: WeatherCategory.rain,
        );
      case 71:
        return const WeatherCondition(
          code: 71,
          label: 'Salju Ringan',
          description: 'Turun salju dengan intensitas ringan.',
          category: WeatherCategory.snow,
        );
      case 73:
        return const WeatherCondition(
          code: 73,
          label: 'Salju Sedang',
          description: 'Salju turun dengan intensitas sedang.',
          category: WeatherCategory.snow,
        );
      case 75:
        return const WeatherCondition(
          code: 75,
          label: 'Salju Lebat',
          description: 'Hujan salju tebal.',
          category: WeatherCategory.snow,
        );
      case 77:
        return const WeatherCondition(
          code: 77,
          label: 'Butiran Salju',
          description: 'Turun butiran salju halus.',
          category: WeatherCategory.snow,
        );
      case 80:
        return const WeatherCondition(
          code: 80,
          label: 'Hujan Lokal Ringan',
          description: 'Hujan singkat dengan intensitas ringan.',
          category: WeatherCategory.rain,
        );
      case 81:
        return const WeatherCondition(
          code: 81,
          label: 'Hujan Lokal Sedang',
          description: 'Hujan singkat yang turun cukup deras.',
          category: WeatherCategory.rain,
        );
      case 82:
        return const WeatherCondition(
          code: 82,
          label: 'Hujan Deras Lokal',
          description: 'Guyuran hujan lebat dalam waktu singkat.',
          category: WeatherCategory.rain,
        );
      case 85:
      case 86:
        return WeatherCondition(
          code: code,
          label: code == 85 ? 'Hujan Salju Ringan' : 'Hujan Salju Lebat',
          description: 'Curahan salju singkat dengan intensitas bervariasi.',
          category: WeatherCategory.snow,
        );
      case 95:
        return const WeatherCondition(
          code: 95,
          label: 'Badai Petir',
          description: 'Terjadi aktivitas petir dengan intensitas ringan hingga sedang.',
          category: WeatherCategory.thunderstorm,
        );
      case 96:
      case 99:
        return WeatherCondition(
          code: code,
          label: code == 96
              ? 'Badai Petir & Es Ringan'
              : 'Badai Petir & Es Lebat',
          description: 'Badai petir disertai potensi hujan es.',
          category: WeatherCategory.thunderstorm,
        );
      case 97:
        return const WeatherCondition(
          code: 97,
          label: 'Badai Petir Kuat',
          description: 'Aktivitas badai petir kuat dan hujan lebat.',
          category: WeatherCategory.thunderstorm,
        );
      default:
        return WeatherCondition(
          code: code,
          label: 'Cuaca (WMO $code)',
          description: 'Kode kondisi cuaca WMO $code dari Open-Meteo.',
          category: WeatherCategory.partlyCloudy,
        );
    }
  }

  /// Ikon Material yang sesuai dengan kategori cuaca dan siang/malam.
  IconData icon({bool isDay = true}) {
    switch (category) {
      case WeatherCategory.clear:
        return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
      case WeatherCategory.partlyCloudy:
        return isDay ? Icons.wb_cloudy_rounded : Icons.nights_stay_rounded;
      case WeatherCategory.cloudy:
        return Icons.cloud_rounded;
      case WeatherCategory.fog:
        return Icons.foggy;
      case WeatherCategory.drizzle:
        return Icons.grain_rounded;
      case WeatherCategory.rain:
        return Icons.umbrella_rounded;
      case WeatherCategory.snow:
        return Icons.ac_unit_rounded;
      case WeatherCategory.thunderstorm:
        return Icons.thunderstorm_rounded;
    }
  }

  /// Gradasi warna atmosfer untuk kartu hero berdasarkan kondisi cuaca dan siang/malam.
  List<Color> heroGradient({required bool isDay}) {
    if (!isDay) {
      switch (category) {
        case WeatherCategory.thunderstorm:
          return const [Color(0xFF14182E), Color(0xFF282447)];
        case WeatherCategory.rain:
        case WeatherCategory.drizzle:
          return const [Color(0xFF0F2038), Color(0xFF1C3A57)];
        case WeatherCategory.clear:
        case WeatherCategory.partlyCloudy:
          return const [Color(0xFF0B1C3A), Color(0xFF1A3A6B)];
        case WeatherCategory.cloudy:
        case WeatherCategory.fog:
        case WeatherCategory.snow:
          return const [Color(0xFF182436), Color(0xFF2B3E56)];
      }
    }

    switch (category) {
      case WeatherCategory.clear:
        return const [Color(0xFF0B66D1), Color(0xFF2A9DF4)];
      case WeatherCategory.partlyCloudy:
        return const [Color(0xFF1D6FB8), Color(0xFF53A3DA)];
      case WeatherCategory.cloudy:
        return const [Color(0xFF3E5A78), Color(0xFF607D9B)];
      case WeatherCategory.fog:
        return const [Color(0xFF4F6475), Color(0xFF7B90A0)];
      case WeatherCategory.drizzle:
        return const [Color(0xFF1C5F82), Color(0xFF388AA8)];
      case WeatherCategory.rain:
        return const [Color(0xFF174672), Color(0xFF286C96)];
      case WeatherCategory.snow:
        return const [Color(0xFF3A71A3), Color(0xFF7BB1DA)];
      case WeatherCategory.thunderstorm:
        return const [Color(0xFF232B4E), Color(0xFF3C4775)];
    }
  }
}
