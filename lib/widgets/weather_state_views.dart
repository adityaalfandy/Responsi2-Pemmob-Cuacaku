import 'package:flutter/material.dart';

/// Tampilan loading terstruktur saat aplikasi sedang mengambil data dari API Open-Meteo.
class WeatherLoadingView extends StatelessWidget {
  const WeatherLoadingView({
    super.key,
    this.cityName,
  });

  final String? cityName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final boxColor = scheme.surfaceContainerHigh.withValues(alpha: 0.7);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: boxColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              cityName != null
                                  ? 'Memuat cuaca $cityName dari Open-Meteo...'
                                  : 'Memuat data cuaca dari Open-Meteo...',
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SkeletonBar(width: 140, height: 48, color: scheme.surface),
                      const SizedBox(height: 12),
                      _SkeletonBar(width: 210, height: 18, color: scheme.surface),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _SkeletonBar(
                              width: double.infinity,
                              height: 36,
                              color: scheme.surface,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SkeletonBar(
                              width: double.infinity,
                              height: 36,
                              color: scheme.surface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(
                    6,
                    (_) => SizedBox(
                      width: 165,
                      height: 92,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Tampilan kondisi data kosong ketika belum ada kota aktif atau data cuaca tidak tersedia.
class WeatherEmptyView extends StatelessWidget {
  const WeatherEmptyView({
    super.key,
    required this.onOpenSearch,
    this.onLoadSampleCity,
  });

  final VoidCallback onOpenSearch;
  final VoidCallback? onLoadSampleCity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.travel_explore_rounded,
                      size: 36,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Belum Ada Kota Dipilih',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cari dan pilih nama kota untuk menampilkan suhu, kelembapan, kecepatan angin, dan prakiraan 7 hari dari Open-Meteo.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onOpenSearch,
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Cari Lokasi Kota'),
                    ),
                  ),
                  if (onLoadSampleCity != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onLoadSampleCity,
                        icon: const Icon(Icons.my_location_rounded),
                        label: const Text('Muat Cuaca Yogyakarta'),
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

/// Tampilan error saat permintaan ke API Open-Meteo gagal dengan tombol coba lagi.
class WeatherErrorView extends StatelessWidget {
  const WeatherErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.onChangeLocation,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onChangeLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: scheme.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_off_rounded,
                      size: 36,
                      color: scheme.error,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Gagal Memuat Data Cuaca',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                    ),
                  ),
                  if (onChangeLocation != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onChangeLocation,
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('Pilih Kota Lain'),
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
