import 'package:flutter/material.dart';

import 'favorites_screen.dart';
import 'home_weather_screen.dart';
import 'search_location_screen.dart';

/// Kerangka navigasi responsif utama:
/// - Layar sempit (< 720px): Bottom [NavigationBar]
/// - Layar lebar (>= 720px): Side [NavigationRail]
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _goToTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeWeatherScreen(
        onNavigateToSearch: () => _goToTab(1),
        onNavigateToFavorites: () => _goToTab(2),
      ),
      SearchLocationScreen(
        onLocationSelected: () => _goToTab(0),
      ),
      FavoritesScreen(
        onNavigateToSearch: () => _goToTab(1),
        onSelectFavorite: () => _goToTab(0),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 720;

        if (useRail) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _goToTab,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Icon(
                      Icons.cloud_outlined,
                      size: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.wb_sunny_outlined),
                      selectedIcon: Icon(Icons.wb_sunny_rounded),
                      label: Text('Cuaca'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search_outlined),
                      selectedIcon: Icon(Icons.search_rounded),
                      label: Text('Cari Kota'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.star_outline_rounded),
                      selectedIcon: Icon(Icons.star_rounded),
                      label: Text('Favorit'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: screens,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _goToTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.wb_sunny_outlined),
                selectedIcon: Icon(Icons.wb_sunny_rounded),
                label: 'Cuaca',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Cari Kota',
              ),
              NavigationDestination(
                icon: Icon(Icons.star_outline_rounded),
                selectedIcon: Icon(Icons.star_rounded),
                label: 'Favorit',
              ),
            ],
          ),
        );
      },
    );
  }
}
