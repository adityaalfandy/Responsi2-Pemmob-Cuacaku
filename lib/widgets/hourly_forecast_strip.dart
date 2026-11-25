import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_forecast_model.dart';

/// Strip horizontal untuk prakiraan cuaca 24 jam ke depan.
class HourlyForecastStrip extends StatelessWidget {
  const HourlyForecastStrip({
    super.key,
    required this.items,
  });

  final List<HourlyForecastItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 138,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          final isNow = index == 0;
          final timeLabel =
              isNow ? 'Skrg' : DateFormat('HH:mm').format(item.time);
          final isDayHour = item.time.hour >= 6 && item.time.hour < 18;

          return Container(
            width: 84,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: isNow
                  ? scheme.primary.withValues(alpha: 0.14)
                  : theme.cardTheme.color,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isNow
                    ? scheme.primary
                    : scheme.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isNow ? scheme.primary : scheme.onSurfaceVariant,
                    fontWeight: isNow ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                Icon(
                  item.condition.icon(isDay: isDayHour),
                  size: 26,
                  color: isNow ? scheme.primary : scheme.onSurface,
                ),
                Text(
                  '${item.temperature2m.toStringAsFixed(0)}°',
                  style: theme.textTheme.titleMedium,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      size: 12,
                      color: scheme.secondary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${item.precipitationProbability}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
