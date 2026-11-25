import 'package:flutter/material.dart';

import '../models/weather_forecast_model.dart';

/// Grid responsif yang menampilkan parameter cuaca terkini & harian wajib dari Open-Meteo:
/// kelembapan, kecepatan angin, suhu dirasakan, curah hujan, kode cuaca, peluang hujan,
/// ditambah tutupan awan dan tekanan permukaan.
class WeatherMetricsGrid extends StatelessWidget {
  const WeatherMetricsGrid({
    super.key,
    required this.forecast,
  });

  final WeatherForecastModel forecast;

  @override
  Widget build(BuildContext context) {
    final current = forecast.current;
    final today = forecast.todayDaily;

    final items = <_MetricEntry>[
      _MetricEntry(
        icon: Icons.water_drop_rounded,
        label: 'Kelembapan',
        value: '${current.relativeHumidity2m}${current.humidityUnit}',
        subtitle: _humidityHint(current.relativeHumidity2m),
        accent: const Color(0xFF0B84D8),
      ),
      _MetricEntry(
        icon: Icons.air_rounded,
        label: 'Kecepatan Angin',
        value:
            '${current.windSpeed10m.toStringAsFixed(1)} ${current.windSpeedUnit}',
        subtitle: 'Arah ${current.windDirectionLabel}',
        accent: const Color(0xFF0D8A8A),
      ),
      _MetricEntry(
        icon: Icons.device_thermostat_rounded,
        label: 'Suhu Dirasakan',
        value:
            '${current.apparentTemperature.toStringAsFixed(1)}${current.temperatureUnit}',
        subtitle:
            'Aktual ${current.temperature2m.toStringAsFixed(1)}${current.temperatureUnit}',
        accent: const Color(0xFFE06D22),
      ),
      _MetricEntry(
        icon: Icons.grain_rounded,
        label: 'Curah Hujan',
        value:
            '${current.precipitation.toStringAsFixed(2)} ${current.precipitationUnit}',
        subtitle: 'Presipitasi saat ini',
        accent: const Color(0xFF3E63DD),
      ),
      _MetricEntry(
        icon: Icons.umbrella_rounded,
        label: 'Peluang Hujan',
        value: today != null ? '${today.precipitationProbabilityMax}%' : '-',
        subtitle: 'Maksimum hari ini',
        accent: const Color(0xFF1F7A8C),
      ),
      _MetricEntry(
        icon: Icons.tag_rounded,
        label: 'Kode Cuaca',
        value: 'WMO ${current.weatherCode}',
        subtitle: current.condition.label,
        accent: const Color(0xFF6B5CE7),
      ),
      if (current.cloudCover != null)
        _MetricEntry(
          icon: Icons.cloud_queue_rounded,
          label: 'Tutupan Awan',
          value: '${current.cloudCover}%',
          subtitle: 'Kepadatan awan langit',
          accent: const Color(0xFF5D738A),
        ),
      if (current.surfacePressure != null)
        _MetricEntry(
          icon: Icons.speed_rounded,
          label: 'Tekanan Udara',
          value:
              '${current.surfacePressure!.toStringAsFixed(0)} ${current.pressureUnit}',
          subtitle: 'Tekanan permukaan',
          accent: const Color(0xFF388E6C),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 720 ? 4 : (width >= 480 ? 3 : 2);
        const spacing = 12.0;
        final cardWidth = (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (entry) => SizedBox(
                  width: cardWidth,
                  child: _MetricCard(entry: entry),
                ),
              )
              .toList(),
        );
      },
    );
  }

  String _humidityHint(int humidity) {
    if (humidity >= 80) return 'Udara lembap';
    if (humidity >= 50) return 'Kondisi nyaman';
    return 'Udara cenderung kering';
  }
}

class _MetricEntry {
  const _MetricEntry({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color accent;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.entry});

  final _MetricEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: entry.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(entry.icon, size: 18, color: entry.accent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.label,
                    style: theme.textTheme.labelMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entry.value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              entry.subtitle,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
