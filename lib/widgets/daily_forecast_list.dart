import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_forecast_model.dart';

/// Daftar prakiraan cuaca beberapa hari ke depan (`daily`) lengkap dengan
/// suhu min/maks harian, peluang hujan maksimum, dan bilah rentang suhu mingguan.
class DailyForecastList extends StatelessWidget {
  const DailyForecastList({
    super.key,
    required this.dailyItems,
    required this.onTapDay,
  });

  final List<DailyForecastItem> dailyItems;
  final ValueChanged<DailyForecastItem> onTapDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (dailyItems.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Data prakiraan harian tidak tersedia.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    final weekMin = dailyItems
        .map((e) => e.temperature2mMin)
        .reduce((a, b) => math.min(a, b));
    final weekMax = dailyItems
        .map((e) => e.temperature2mMax)
        .reduce((a, b) => math.max(a, b));

    return Card(
      child: Column(
        children: List.generate(dailyItems.length, (index) {
          final item = dailyItems[index];
          final isToday = index == 0;
          final dayName = isToday
              ? 'Hari Ini'
              : (index == 1
                  ? 'Besok'
                  : DateFormat('EEEE', 'id_ID').format(item.date));
          final dateLabel = DateFormat('d MMM', 'id_ID').format(item.date);

          return Column(
            children: [
              InkWell(
                onTap: () => onTapDay(item),
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? const Radius.circular(20) : Radius.zero,
                  bottom: index == dailyItems.length - 1
                      ? const Radius.circular(20)
                      : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // Hari & tanggal
                      SizedBox(
                        width: 82,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: isToday
                                    ? scheme.primary
                                    : scheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              dateLabel,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),

                      // Ikon & peluang hujan
                      Icon(
                        item.condition.icon(isDay: true),
                        size: 22,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 54,
                        child: Row(
                          children: [
                            Icon(
                              Icons.water_drop_rounded,
                              size: 13,
                              color: scheme.secondary,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                '${item.precipitationProbabilityMax}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Suhu min + thermal range bar + suhu maks
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${item.temperature2mMin.toStringAsFixed(0)}°',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TemperatureRangeBar(
                          min: item.temperature2mMin,
                          max: item.temperature2mMax,
                          weekMin: weekMin,
                          weekMax: weekMax,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${item.temperature2mMax.toStringAsFixed(0)}°',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              if (index < dailyItems.length - 1)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: scheme.outlineVariant.withValues(alpha: 0.55),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _TemperatureRangeBar extends StatelessWidget {
  const _TemperatureRangeBar({
    required this.min,
    required this.max,
    required this.weekMin,
    required this.weekMax,
  });

  final double min;
  final double max;
  final double weekMin;
  final double weekMax;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final span = (weekMax - weekMin).abs();
    final startFrac = span < 0.5 ? 0.0 : ((min - weekMin) / span).clamp(0.0, 1.0);
    final endFrac = span < 0.5 ? 1.0 : ((max - weekMin) / span).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;
        final left = fullWidth * startFrac;
        final barWidth = math.max(8.0, fullWidth * (endFrac - startFrac));

        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Stack(
            children: [
              Positioned(
                left: left.clamp(0.0, math.max(0.0, fullWidth - barWidth)),
                width: barWidth.clamp(0.0, fullWidth),
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2AA6DF), Color(0xFFF28B30)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
