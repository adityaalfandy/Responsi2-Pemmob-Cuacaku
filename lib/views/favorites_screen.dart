import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../viewmodels/search_location_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';

/// Screen Tambahan: Halaman Lokasi Favorit dengan ringkasan suhu live dari Open-Meteo.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    required this.onNavigateToSearch,
    required this.onSelectFavorite,
  });

  final VoidCallback onNavigateToSearch;
  final VoidCallback onSelectFavorite;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SearchLocationViewModel>().refreshAllFavoritePreviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final searchVm = context.watch<SearchLocationViewModel>();
    final weatherVm = context.watch<WeatherViewModel>();
    final favorites = searchVm.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Favorit'),
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              onPressed: searchVm.refreshAllFavoritePreviews,
              tooltip: 'Muat ulang cuaca favorit',
              icon: const Icon(Icons.refresh_rounded),
            ),
          IconButton(
            onPressed: widget.onNavigateToSearch,
            tooltip: 'Tambah kota',
            icon: const Icon(Icons.add_location_alt_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: favorites.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
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
                                Icons.star_outline_rounded,
                                size: 38,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Belum Ada Kota Favorit',
                              style: theme.textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tandai bintang pada kota di halaman Cuaca atau Cari Lokasi agar dapat diakses cepat di sini dan tersimpan di perangkat.',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: widget.onNavigateToSearch,
                                icon: const Icon(Icons.search_rounded),
                                label: const Text('Cari & Tambah Kota'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: searchVm.refreshAllFavoritePreviews,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  itemCount: favorites.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final city = favorites[index];
                    final isSelected =
                        weatherVm.selectedLocation?.uniqueKey == city.uniqueKey;
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: _FavoriteCityCard(
                          city: city,
                          isSelected: isSelected,
                          searchVm: searchVm,
                          onTap: () async {
                            await weatherVm.selectLocation(city);
                            if (!context.mounted) return;
                            widget.onSelectFavorite();
                          },
                          onRemove: () => searchVm.toggleFavorite(city),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _FavoriteCityCard extends StatelessWidget {
  const _FavoriteCityCard({
    required this.city,
    required this.isSelected,
    required this.searchVm,
    required this.onTap,
    required this.onRemove,
  });

  final LocationModel city;
  final bool isSelected;
  final SearchLocationViewModel searchVm;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final preview = searchVm.previewFor(city);
    final isLoading = searchVm.isPreviewLoading(city);
    final error = searchVm.previewErrorFor(city);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? scheme.primary
              : scheme.outlineVariant.withValues(alpha: 0.7),
          width: isSelected ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            city.name,
                            style: theme.textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Dipilih',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (city.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        city.subtitle,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    if (preview != null)
                      Text(
                        '${preview.current.condition.label} • Kelembapan ${preview.current.relativeHumidity2m}% • Angin ${preview.current.windSpeed10m.toStringAsFixed(1)} km/h',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else if (error != null)
                      Text(
                        error,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.error,
                        ),
                      )
                    else
                      Text(
                        city.formattedCoordinates,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (preview != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      preview.current.condition
                          .icon(isDay: preview.current.isDay),
                      color: scheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${preview.current.temperature2m.toStringAsFixed(0)}°',
                      style: theme.textTheme.headlineMedium,
                    ),
                  ],
                ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onRemove,
                tooltip: 'Hapus dari favorit',
                icon: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFE5A100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
