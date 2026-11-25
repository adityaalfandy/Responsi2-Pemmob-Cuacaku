import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../viewmodels/search_location_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/location_result_tile.dart';

/// Screen 2 (Wajib): Search / Location Screen.
/// Menyediakan input pencarian kota via Open-Meteo Geocoding API (HTTP GET),
/// menampilkan daftar hasil pencarian, memilih lokasi untuk melihat cuaca,
/// menyimpan lokasi sebagai favorit, serta menampilkan riwayat pencarian lokal.
class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({
    super.key,
    required this.onLocationSelected,
  });

  final VoidCallback onLocationSelected;

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  static const List<String> _quickQueries = [
    'Yogyakarta',
    'Jakarta',
    'Bandung',
    'Surabaya',
    'Bali',
    'Tokyo',
    'London',
  ];

  @override
  void initState() {
    super.initState();
    final existingQuery = context.read<SearchLocationViewModel>().query;
    if (existingQuery.isNotEmpty) {
      _controller.text = existingQuery;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      context.read<SearchLocationViewModel>().clearSearch();
      return;
    }
    if (trimmed.length < 2) return;

    _debounce = Timer(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      context.read<SearchLocationViewModel>().searchCities(trimmed);
    });
  }

  void _submitSearch(String value) {
    _debounce?.cancel();
    context.read<SearchLocationViewModel>().searchCities(value);
  }

  Future<void> _selectLocation(LocationModel location) async {
    final searchVm = context.read<SearchLocationViewModel>();
    final weatherVm = context.read<WeatherViewModel>();

    await searchVm.addToHistory(location);
    await weatherVm.selectLocation(location);
    if (!mounted) return;
    widget.onLocationSelected();
  }

  Future<void> _toggleFavorite(LocationModel location) async {
    final added =
        await context.read<SearchLocationViewModel>().toggleFavorite(location);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${location.name} ditambahkan ke favorit.'
              : '${location.name} dihapus dari favorit.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final searchVm = context.watch<SearchLocationViewModel>();
    final activeLocation = context.watch<WeatherViewModel>().selectedLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Lokasi Kota'),
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
                  // Kotak input pencarian kota
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.search,
                          onChanged: _onQueryChanged,
                          onSubmitted: _submitSearch,
                          decoration: InputDecoration(
                            hintText:
                                'Cari kota (mis. Yogyakarta, Bandung, Tokyo)...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _controller.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _debounce?.cancel();
                                      _controller.clear();
                                      setState(() {});
                                      searchVm.clearSearch();
                                    },
                                    tooltip: 'Bersihkan pencarian',
                                    icon: const Icon(Icons.close_rounded),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: () => _submitSearch(_controller.text),
                        child: const Text('Cari'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Chip saran cepat yang memicu request Geocoding API
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _quickQueries
                          .map(
                            (city) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                avatar: Icon(
                                  Icons.bolt_rounded,
                                  size: 16,
                                  color: scheme.primary,
                                ),
                                label: Text(city),
                                onPressed: () {
                                  _controller.text = city;
                                  _controller.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(offset: city.length),
                                  );
                                  setState(() {});
                                  _submitSearch(city);
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSearchContent(
                    context,
                    searchVm: searchVm,
                    activeLocation: activeLocation,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchContent(
    BuildContext context, {
    required SearchLocationViewModel searchVm,
    required LocationModel? activeLocation,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    switch (searchVm.status) {
      case SearchStatus.loading:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Mencari "${searchVm.query}" melalui Open-Meteo Geocoding API...',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );

      case SearchStatus.error:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.wifi_off_rounded, size: 40, color: scheme.error),
                const SizedBox(height: 12),
                Text(
                  'Pencarian Gagal',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  searchVm.errorMessage ?? 'Gagal menghubungi Geocoding API.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _submitSearch(_controller.text),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        );

      case SearchStatus.empty:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Icon(
                  Icons.location_off_rounded,
                  size: 44,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'Kota "${searchVm.query}" Tidak Ditemukan',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Pastikan ejaan nama kota benar atau tambahkan nama negara (mis. "Malang, Indonesia").',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );

      case SearchStatus.loaded:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hasil Pencarian (${searchVm.results.length})',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...searchVm.results.map(
              (location) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LocationResultTile(
                  location: location,
                  isFavorite: searchVm.isFavorite(location),
                  isSelected: activeLocation?.uniqueKey == location.uniqueKey,
                  onTap: () => _selectLocation(location),
                  onToggleFavorite: () => _toggleFavorite(location),
                ),
              ),
            ),
          ],
        );

      case SearchStatus.idle:
        return _buildSavedSections(
          context,
          searchVm: searchVm,
          activeLocation: activeLocation,
        );
    }
  }

  Widget _buildSavedSections(
    BuildContext context, {
    required SearchLocationViewModel searchVm,
    required LocationModel? activeLocation,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasFavorites = searchVm.favorites.isNotEmpty;
    final hasHistory = searchVm.searchHistory.isNotEmpty;

    if (!hasFavorites && !hasHistory) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Icon(
                Icons.explore_rounded,
                size: 46,
                color: scheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Mulai Jelajahi Cuaca Dunia',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ketik nama kota di kolom pencarian di atas untuk mengambil data koordinat langsung dari Open-Meteo Geocoding API. Kota yang dipilih atau difavoritkan akan tersimpan otomatis.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasFavorites) ...[
          Text(
            'Lokasi Favorit (${searchVm.favorites.length})',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ...searchVm.favorites.map(
            (location) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LocationResultTile(
                location: location,
                isFavorite: true,
                isSelected: activeLocation?.uniqueKey == location.uniqueKey,
                leadingIcon: Icons.star_rounded,
                onTap: () => _selectLocation(location),
                onToggleFavorite: () => _toggleFavorite(location),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (hasHistory) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Pencarian',
                style: theme.textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: searchVm.clearHistory,
                icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                label: const Text('Hapus Semua'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...searchVm.searchHistory.map(
            (location) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LocationResultTile(
                location: location,
                isFavorite: searchVm.isFavorite(location),
                isSelected: activeLocation?.uniqueKey == location.uniqueKey,
                leadingIcon: Icons.history_rounded,
                onTap: () => _selectLocation(location),
                onToggleFavorite: () => _toggleFavorite(location),
                onRemove: () => searchVm.removeHistoryItem(location),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
