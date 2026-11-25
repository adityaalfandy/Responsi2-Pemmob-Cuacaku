import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/location_model.dart';
import '../models/weather_forecast_model.dart';

/// Kartu utama atmosfer yang menampilkan kota terpilih, suhu saat ini,
/// kondisi cuaca terkini (kode WMO), serta suhu min/maks hari ini.
class WeatherHeroCard extends StatelessWidget {
  const WeatherHeroCard({
    super.key,
    required this.location,
    required this.forecast,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onOpenSearch,
  });

  final LocationModel location;
  final WeatherForecastModel forecast;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = forecast.current;
    final condition = current.condition;
    final gradient = condition.heroGradient(isDay: current.isDay);
    final today = forecast.todayDaily;
    final updatedTime = DateFormat('HH:mm').format(forecast.fetchedAt);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Aksen lingkaran atmosfer halus di pojok kanan atas
          Positioned(
            right: -32,
            top: -32,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris kota + tombol favorit & ganti lokasi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onOpenSearch,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      location.name,
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    size: 20,
                                  ),
                                ],
                              ),
                              if (location.subtitle.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Padding(
                                  padding: const EdgeInsets.only(left: 26),
                                  child: Text(
                                    location.subtitle,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: onToggleFavorite,
                      tooltip: isFavorite
                          ? 'Hapus dari favorit'
                          : 'Simpan sebagai favorit',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.16),
                        foregroundColor:
                            isFavorite ? const Color(0xFFFFD54F) : Colors.white,
                      ),
                      icon: Icon(
                        isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Suhu utama dan ikon kondisi cuaca
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${current.temperature2m.toStringAsFixed(1)}${current.temperatureUnit}',
                            style: theme.textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 58,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            condition.label,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            condition.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.84),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            condition.icon(isDay: current.isDay),
                            size: 52,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'WMO ${current.weatherCode}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Ringkasan chip terasa seperti, min/maks, dan zona waktu
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroPill(
                      icon: Icons.thermostat_rounded,
                      label:
                          'Terasa ${current.apparentTemperature.toStringAsFixed(1)}°',
                    ),
                    if (today != null)
                      _HeroPill(
                        icon: Icons.swap_vert_rounded,
                        label:
                            'Min ${today.temperature2mMin.toStringAsFixed(0)}° • Maks ${today.temperature2mMax.toStringAsFixed(0)}°',
                      ),
                    _HeroPill(
                      icon: Icons.schedule_rounded,
                      label:
                          '${forecast.timezoneAbbreviation.isNotEmpty ? forecast.timezoneAbbreviation : forecast.timezone} • $updatedTime',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelMedium;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: textStyle?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
