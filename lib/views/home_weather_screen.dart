import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../models/weather_forecast_model.dart';
import '../viewmodels/search_location_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/favorite_chips_bar.dart';
import '../widgets/hourly_forecast_strip.dart';
import '../widgets/weather_hero_card.dart';
import '../widgets/weather_metrics_grid.dart';
import '../widgets/weather_state_views.dart';
import 'daily_detail_screen.dart';

/// Screen 1 (Wajib): Home / Weather Screen.
/// Menampilkan nama kota terpilih, kondisi cuaca terkini, suhu saat ini,
/// parameter tambahan (kelembapan, angin, curah hujan, peluang hujan, suhu dirasakan,
/// kode WMO), prakiraan 24 jam, dan prakiraan 7 hari ke depan dari Open-Meteo API.
class HomeWeatherScreen extends StatefulWidget {
  const HomeWeatherScreen({
    super.key,
    required this.onNavigateToSearch,
    required this.onNavigateToFavorites,
  });

  final VoidCallback onNavigateToSearch;
  final VoidCallback onNavigateToFavorites;

  @override
  State<HomeWeatherScreen> createState() => _HomeWeatherScreenState();
}

class _HomeWeatherScreenState extends State<HomeWeatherScreen> {
  Future<void> _handleRefresh(WeatherViewModel weatherVm) async {
    await weatherVm.fetchWeather();
    if (!mounted) return;
    if (weatherVm.errorMessage != null && weatherVm.forecast != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(weatherVm.errorMessage!),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weatherVm = context.watch<WeatherViewModel>();
    final searchVm = context.watch<SearchLocationViewModel>();
    final themeVm = context.watch<ThemeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              color: theme.colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text('CuacaKu'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: widget.onNavigateToSearch,
            tooltip: 'Cari kota',
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: themeVm.cycleThemeMode,
            tooltip: themeVm.themeModeLabel,
            icon: Icon(themeVm.themeModeIcon),
          ),
          PopupMenuButton<String>(
            tooltip: 'Menu lainnya',
            onSelected: (value) async {
              if (value == 'refresh') {
                await _handleRefresh(weatherVm);
              } else if (value == 'clear') {
                await weatherVm.clearLocation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.refresh_rounded),
                  title: Text('Muat ulang cuaca'),
                ),
              ),
              if (weatherVm.selectedLocation != null)
                const PopupMenuItem(
                  value: 'clear',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.layers_clear_rounded),
                    title: Text('Kosongkan lokasi aktif'),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: _buildBody(context, weatherVm, searchVm),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeatherViewModel weatherVm,
    SearchLocationViewModel searchVm,
  ) {
    switch (weatherVm.status) {
      case WeatherViewStatus.initial:
      case WeatherViewStatus.loading:
        return WeatherLoadingView(cityName: weatherVm.selectedLocation?.name);

      case WeatherViewStatus.empty:
        return WeatherEmptyView(
          onOpenSearch: widget.onNavigateToSearch,
          onLoadSampleCity: () => weatherVm.initialize(useDefaultIfEmpty: true),
        );

      case WeatherViewStatus.error:
        return WeatherErrorView(
          message: weatherVm.errorMessage ??
              'Tidak dapat mengambil informasi cuaca saat ini.',
          onRetry: () => weatherVm.fetchWeather(),
          onChangeLocation: widget.onNavigateToSearch,
        );

      case WeatherViewStatus.loaded:
        final location = weatherVm.selectedLocation;
        final forecast = weatherVm.forecast;
        if (location == null || forecast == null) {
          return WeatherEmptyView(onOpenSearch: widget.onNavigateToSearch);
        }

        final isFavorite = searchVm.isFavorite(location);

        return RefreshIndicator(
          onRefresh: () => _handleRefresh(weatherVm),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (weatherVm.isRefreshing)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: LinearProgressIndicator(minHeight: 3),
                          ),
                        if (searchVm.favorites.isNotEmpty) ...[
                          FavoriteChipsBar(
                            favorites: searchVm.favorites,
                            selectedLocation: location,
                            onSelect: (city) async {
                              await weatherVm.selectLocation(city);
                            },
                            onManageFavorites: widget.onNavigateToFavorites,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    WeatherHeroCard(
                                      location: location,
                                      forecast: forecast,
                                      isFavorite: isFavorite,
                                      onToggleFavorite: () =>
                                          _toggleFavorite(searchVm, location),
                                      onOpenSearch: widget.onNavigateToSearch,
                                    ),
                                    const SizedBox(height: 20),
                                    const _SectionHeader(
                                      title: 'Prakiraan 24 Jam',
                                      subtitle: 'Suhu & peluang hujan per jam',
                                    ),
                                    const SizedBox(height: 10),
                                    HourlyForecastStrip(
                                      items: forecast.next24Hours,
                                    ),
                                    const SizedBox(height: 20),
                                    if (forecast.todayDaily != null)
                                      _TodaySunUvCard(
                                        today: forecast.todayDaily!,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const _SectionHeader(
                                      title: 'Parameter Cuaca Terkini',
                                      subtitle:
                                          'Data real-time dari Open-Meteo API',
                                    ),
                                    const SizedBox(height: 10),
                                    WeatherMetricsGrid(forecast: forecast),
                                    const SizedBox(height: 22),
                                    const _SectionHeader(
                                      title: 'Prakiraan 7 Hari Ke Depan',
                                      subtitle:
                                          'Ketuk hari untuk detail per jam & matahari',
                                    ),
                                    const SizedBox(height: 10),
                                    DailyForecastList(
                                      dailyItems: forecast.daily,
                                      onTapDay: (day) => _openDailyDetail(
                                        context,
                                        location.name,
                                        day,
                                        forecast.hourlyForDate(day.date),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              WeatherHeroCard(
                                location: location,
                                forecast: forecast,
                                isFavorite: isFavorite,
                                onToggleFavorite: () =>
                                    _toggleFavorite(searchVm, location),
                                onOpenSearch: widget.onNavigateToSearch,
                              ),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Parameter Cuaca Terkini',
                                subtitle: 'Data real-time dari Open-Meteo API',
                              ),
                              const SizedBox(height: 10),
                              WeatherMetricsGrid(forecast: forecast),
                              const SizedBox(height: 22),
                              const _SectionHeader(
                                title: 'Prakiraan 24 Jam',
                                subtitle: 'Suhu & peluang hujan per jam',
                              ),
                              const SizedBox(height: 10),
                              HourlyForecastStrip(items: forecast.next24Hours),
                              const SizedBox(height: 22),
                              const _SectionHeader(
                                title: 'Prakiraan 7 Hari Ke Depan',
                                subtitle:
                                    'Ketuk hari untuk detail per jam & matahari',
                              ),
                              const SizedBox(height: 10),
                              DailyForecastList(
                                dailyItems: forecast.daily,
                                onTapDay: (day) => _openDailyDetail(
                                  context,
                                  location.name,
                                  day,
                                  forecast.hourlyForDate(day.date),
                                ),
                              ),
                              if (forecast.todayDaily != null) ...[
                                const SizedBox(height: 20),
                                _TodaySunUvCard(today: forecast.todayDaily!),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
    }
  }

  Future<void> _toggleFavorite(
    SearchLocationViewModel searchVm,
    LocationModel location,
  ) async {
    final added = await searchVm.toggleFavorite(location);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${location.name} disimpan ke lokasi favorit.'
              : '${location.name} dihapus dari lokasi favorit.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openDailyDetail(
    BuildContext context,
    String cityName,
    DailyForecastItem day,
    List<HourlyForecastItem> hourlyItems,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DailyDetailScreen(
          cityName: cityName,
          daily: day,
          hourlyItems: hourlyItems,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodaySunUvCard extends StatelessWidget {
  const _TodaySunUvCard({required this.today});

  final DailyForecastItem today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sunriseStr = today.sunrise != null
        ? DateFormat('HH:mm').format(today.sunrise!)
        : '-';
    final sunsetStr =
        today.sunset != null ? DateFormat('HH:mm').format(today.sunset!) : '-';
    final uvStr =
        today.uvIndexMax != null ? today.uvIndexMax!.toStringAsFixed(1) : '-';
    final windMaxStr = today.windSpeed10mMax != null
        ? '${today.windSpeed10mMax!.toStringAsFixed(1)} km/h'
        : '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Matahari & Indeks Harian', style: theme.textTheme.titleMedium),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _SunInfoChip(
                  icon: Icons.wb_twilight_rounded,
                  label: 'Terbit',
                  value: sunriseStr,
                ),
                _SunInfoChip(
                  icon: Icons.nights_stay_outlined,
                  label: 'Terbenam',
                  value: sunsetStr,
                ),
                _SunInfoChip(
                  icon: Icons.flare_rounded,
                  label: 'UV Maks',
                  value: uvStr,
                ),
                _SunInfoChip(
                  icon: Icons.wind_power_rounded,
                  label: 'Angin Maks',
                  value: windMaxStr,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SunInfoChip extends StatelessWidget {
  const _SunInfoChip({
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(value, style: theme.textTheme.labelLarge),
          ],
        ),
      ],
    );
  }
}
