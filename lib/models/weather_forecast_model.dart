import 'weather_condition.dart';

/// Model data cuaca terkini (`current`) dari Open-Meteo Forecast API.
class CurrentWeatherModel {
  const CurrentWeatherModel({
    required this.time,
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
    required this.isDay,
    this.windDirection10m,
    this.surfacePressure,
    this.cloudCover,
    this.temperatureUnit = '°C',
    this.humidityUnit = '%',
    this.precipitationUnit = 'mm',
    this.windSpeedUnit = 'km/h',
    this.pressureUnit = 'hPa',
  });

  final DateTime time;
  final double temperature2m;
  final int relativeHumidity2m;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;
  final bool isDay;
  final int? windDirection10m;
  final double? surfacePressure;
  final int? cloudCover;

  final String temperatureUnit;
  final String humidityUnit;
  final String precipitationUnit;
  final String windSpeedUnit;
  final String pressureUnit;

  WeatherCondition get condition => WeatherCondition.fromWmoCode(weatherCode);

  /// Arah mata angin dari derajat (`wind_direction_10m`).
  String get windDirectionLabel {
    final deg = windDirection10m;
    if (deg == null) return '-';
    const dirs = ['U', 'TL', 'T', 'TG', 'S', 'BD', 'B', 'BL'];
    final index = ((deg % 360) / 45).round() % 8;
    return '${dirs[index]} ($deg°)';
  }

  factory CurrentWeatherModel.fromJson(
    Map<String, dynamic> json, [
    Map<String, dynamic>? units,
  ]) {
    return CurrentWeatherModel(
      time: DateTime.parse(json['time'] as String),
      temperature2m: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity2m: (json['relative_humidity_2m'] as num).round(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed10m: (json['wind_speed_10m'] as num).toDouble(),
      isDay: (json['is_day'] as num?)?.toInt() != 0,
      windDirection10m: (json['wind_direction_10m'] as num?)?.round(),
      surfacePressure: (json['surface_pressure'] as num?)?.toDouble(),
      cloudCover: (json['cloud_cover'] as num?)?.round(),
      temperatureUnit: (units?['temperature_2m'] as String?) ?? '°C',
      humidityUnit: (units?['relative_humidity_2m'] as String?) ?? '%',
      precipitationUnit: (units?['precipitation'] as String?) ?? 'mm',
      windSpeedUnit: (units?['wind_speed_10m'] as String?) ?? 'km/h',
      pressureUnit: (units?['surface_pressure'] as String?) ?? 'hPa',
    );
  }
}

/// Item prakiraan cuaca per jam (`hourly`) dari Open-Meteo Forecast API.
class HourlyForecastItem {
  const HourlyForecastItem({
    required this.time,
    required this.temperature2m,
    required this.weatherCode,
    required this.precipitationProbability,
  });

  final DateTime time;
  final double temperature2m;
  final int weatherCode;
  final int precipitationProbability;

  WeatherCondition get condition => WeatherCondition.fromWmoCode(weatherCode);
}

/// Item prakiraan cuaca harian (`daily`) dari Open-Meteo Forecast API.
class DailyForecastItem {
  const DailyForecastItem({
    required this.date,
    required this.weatherCode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationProbabilityMax,
    this.sunrise,
    this.sunset,
    this.uvIndexMax,
    this.windSpeed10mMax,
  });

  final DateTime date;
  final int weatherCode;
  final double temperature2mMax;
  final double temperature2mMin;
  final int precipitationProbabilityMax;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double? uvIndexMax;
  final double? windSpeed10mMax;

  WeatherCondition get condition => WeatherCondition.fromWmoCode(weatherCode);
}

/// Model respons lengkap Open-Meteo Weather Forecast API.
class WeatherForecastModel {
  const WeatherForecastModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.elevation,
    required this.current,
    required this.daily,
    required this.hourly,
    required this.fetchedAt,
  });

  final double latitude;
  final double longitude;
  final String timezone;
  final String timezoneAbbreviation;
  final double elevation;
  final CurrentWeatherModel current;
  final List<DailyForecastItem> daily;
  final List<HourlyForecastItem> hourly;
  final DateTime fetchedAt;

  /// Mengambil daftar prakiraan 24 jam ke depan dimulai dari waktu saat ini.
  List<HourlyForecastItem> get next24Hours {
    final anchor = current.time.subtract(const Duration(minutes: 45));
    final upcoming = hourly.where((item) => !item.time.isBefore(anchor)).toList();
    if (upcoming.isEmpty) {
      return hourly.take(24).toList();
    }
    return upcoming.take(24).toList();
  }

  /// Mengambil daftar prakiraan per jam khusus pada tanggal [date].
  List<HourlyForecastItem> hourlyForDate(DateTime date) {
    return hourly
        .where((item) =>
            item.time.year == date.year &&
            item.time.month == date.month &&
            item.time.day == date.day)
        .toList();
  }

  /// Hari pertama (hari ini) jika tersedia pada data `daily`.
  DailyForecastItem? get todayDaily => daily.isNotEmpty ? daily.first : null;

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    final currentMap = json['current'] as Map<String, dynamic>?;
    if (currentMap == null) {
      throw const FormatException('Field "current" tidak ditemukan pada respons API.');
    }

    final currentUnits = json['current_units'] as Map<String, dynamic>?;
    final current = CurrentWeatherModel.fromJson(currentMap, currentUnits);

    final dailyMap = json['daily'] as Map<String, dynamic>?;
    final dailyItems = <DailyForecastItem>[];
    if (dailyMap != null) {
      final times = (dailyMap['time'] as List<dynamic>? ?? []);
      final codes = (dailyMap['weather_code'] as List<dynamic>? ?? []);
      final maxTemps = (dailyMap['temperature_2m_max'] as List<dynamic>? ?? []);
      final minTemps = (dailyMap['temperature_2m_min'] as List<dynamic>? ?? []);
      final rainProbs =
          (dailyMap['precipitation_probability_max'] as List<dynamic>? ?? []);
      final sunrises = (dailyMap['sunrise'] as List<dynamic>? ?? []);
      final sunsets = (dailyMap['sunset'] as List<dynamic>? ?? []);
      final uvMaxList = (dailyMap['uv_index_max'] as List<dynamic>? ?? []);
      final windMaxList = (dailyMap['wind_speed_10m_max'] as List<dynamic>? ?? []);

      for (var i = 0; i < times.length; i++) {
        final dateStr = times[i] as String?;
        if (dateStr == null) continue;
        final code = i < codes.length ? (codes[i] as num?)?.toInt() : null;
        final tMax = i < maxTemps.length ? (maxTemps[i] as num?)?.toDouble() : null;
        final tMin = i < minTemps.length ? (minTemps[i] as num?)?.toDouble() : null;
        final prob = i < rainProbs.length ? (rainProbs[i] as num?)?.round() : null;

        if (tMax == null || tMin == null) continue;

        dailyItems.add(
          DailyForecastItem(
            date: DateTime.parse(dateStr),
            weatherCode: code ?? current.weatherCode,
            temperature2mMax: tMax,
            temperature2mMin: tMin,
            precipitationProbabilityMax: prob ?? 0,
            sunrise: i < sunrises.length && sunrises[i] is String
                ? DateTime.tryParse(sunrises[i] as String)
                : null,
            sunset: i < sunsets.length && sunsets[i] is String
                ? DateTime.tryParse(sunsets[i] as String)
                : null,
            uvIndexMax:
                i < uvMaxList.length ? (uvMaxList[i] as num?)?.toDouble() : null,
            windSpeed10mMax: i < windMaxList.length
                ? (windMaxList[i] as num?)?.toDouble()
                : null,
          ),
        );
      }
    }

    final hourlyMap = json['hourly'] as Map<String, dynamic>?;
    final hourlyItems = <HourlyForecastItem>[];
    if (hourlyMap != null) {
      final times = (hourlyMap['time'] as List<dynamic>? ?? []);
      final temps = (hourlyMap['temperature_2m'] as List<dynamic>? ?? []);
      final codes = (hourlyMap['weather_code'] as List<dynamic>? ?? []);
      final probs =
          (hourlyMap['precipitation_probability'] as List<dynamic>? ?? []);

      for (var i = 0; i < times.length; i++) {
        final timeStr = times[i] as String?;
        final temp = i < temps.length ? (temps[i] as num?)?.toDouble() : null;
        if (timeStr == null || temp == null) continue;

        hourlyItems.add(
          HourlyForecastItem(
            time: DateTime.parse(timeStr),
            temperature2m: temp,
            weatherCode: i < codes.length
                ? ((codes[i] as num?)?.toInt() ?? current.weatherCode)
                : current.weatherCode,
            precipitationProbability:
                i < probs.length ? ((probs[i] as num?)?.round() ?? 0) : 0,
          ),
        );
      }
    }

    return WeatherForecastModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: (json['timezone'] as String?) ?? 'auto',
      timezoneAbbreviation: (json['timezone_abbreviation'] as String?) ?? '',
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
      current: current,
      daily: dailyItems,
      hourly: hourlyItems,
      fetchedAt: DateTime.now(),
    );
  }
}
