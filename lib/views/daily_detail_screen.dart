import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_forecast_model.dart';

/// Screen Tambahan: Detail prakiraan harian & rincian per jam untuk satu hari tertentu.
class DailyDetailScreen extends StatelessWidget {
  const DailyDetailScreen({
    super.key,
    required this.cityName,
    required this.daily,
    required this.hourlyItems,
  });

  final String cityName;
  final DailyForecastItem daily;
  final List<HourlyForecastItem> hourlyItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final condition = daily.condition;
    final dateTitle = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(daily.date);
    final gradient = condition.heroGradient(isDay: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(cityName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradient,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateTitle,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                condition.label,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Suhu ${daily.temperature2mMin.toStringAsFixed(1)}°C – ${daily.temperature2mMax.toStringAsFixed(1)}°C',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kode WMO ${daily.weatherCode} • Peluang hujan maks ${daily.precipitationProbabilityMax}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          condition.icon(isDay: true),
                          size: 56,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _DetailChipCard(
                        icon: Icons.thermostat_rounded,
                        label: 'Suhu Maksimum',
                        value: '${daily.temperature2mMax.toStringAsFixed(1)} °C',
                      ),
                      _DetailChipCard(
                        icon: Icons.ac_unit_rounded,
                        label: 'Suhu Minimum',
                        value: '${daily.temperature2mMin.toStringAsFixed(1)} °C',
                      ),
                      _DetailChipCard(
                        icon: Icons.umbrella_rounded,
                        label: 'Peluang Hujan Maks',
                        value: '${daily.precipitationProbabilityMax}%',
                      ),
                      if (daily.windSpeed10mMax != null)
                        _DetailChipCard(
                          icon: Icons.air_rounded,
                          label: 'Angin Maksimum',
                          value:
                              '${daily.windSpeed10mMax!.toStringAsFixed(1)} km/h',
                        ),
                      if (daily.uvIndexMax != null)
                        _DetailChipCard(
                          icon: Icons.flare_rounded,
                          label: 'Indeks UV Maks',
                          value: daily.uvIndexMax!.toStringAsFixed(1),
                        ),
                      if (daily.sunrise != null)
                        _DetailChipCard(
                          icon: Icons.wb_twilight_rounded,
                          label: 'Matahari Terbit',
                          value: DateFormat('HH:mm').format(daily.sunrise!),
                        ),
                      if (daily.sunset != null)
                        _DetailChipCard(
                          icon: Icons.nights_stay_outlined,
                          label: 'Matahari Terbenam',
                          value: DateFormat('HH:mm').format(daily.sunset!),
                        ),
                    ],
                  ),
                  if (hourlyItems.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Prakiraan Per Jam (${DateFormat('d MMM', 'id_ID').format(daily.date)})',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Column(
                        children: List.generate(hourlyItems.length, (index) {
                          final item = hourlyItems[index];
                          final isDayHour =
                              item.time.hour >= 6 && item.time.hour < 18;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 58,
                                      child: Text(
                                        DateFormat('HH:mm').format(item.time),
                                        style: theme.textTheme.labelLarge,
                                      ),
                                    ),
                                    Icon(
                                      item.condition.icon(isDay: isDayHour),
                                      size: 22,
                                      color: scheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item.condition.label,
                                        style: theme.textTheme.bodyMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.water_drop_outlined,
                                      size: 14,
                                      color: scheme.secondary,
                                    ),
                                    const SizedBox(width: 3),
                                    SizedBox(
                                      width: 46,
                                      child: Text(
                                        '${item.precipitationProbability}%',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: scheme.secondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${item.temperature2m.toStringAsFixed(1)}°C',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                              if (index < hourlyItems.length - 1)
                                Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                  color: scheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailChipCard extends StatelessWidget {
  const _DetailChipCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.titleMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
