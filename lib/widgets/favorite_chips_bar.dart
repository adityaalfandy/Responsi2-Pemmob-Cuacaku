import 'package:flutter/material.dart';

import '../models/location_model.dart';

/// Bar chip horizontal pada Home Screen untuk berpindah cepat antar kota favorit tersimpan.
class FavoriteChipsBar extends StatelessWidget {
  const FavoriteChipsBar({
    super.key,
    required this.favorites,
    required this.selectedLocation,
    required this.onSelect,
    required this.onManageFavorites,
  });

  final List<LocationModel> favorites;
  final LocationModel? selectedLocation;
  final ValueChanged<LocationModel> onSelect;
  final VoidCallback onManageFavorites;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (favorites.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == favorites.length) {
            return ActionChip(
              avatar: Icon(
                Icons.bookmarks_outlined,
                size: 16,
                color: scheme.primary,
              ),
              label: const Text('Kelola'),
              onPressed: onManageFavorites,
            );
          }

          final city = favorites[index];
          final isSelected = selectedLocation?.uniqueKey == city.uniqueKey;

          return ChoiceChip(
            avatar: Icon(
              Icons.star_rounded,
              size: 16,
              color: isSelected ? scheme.primary : const Color(0xFFE5A100),
            ),
            label: Text(city.name),
            selected: isSelected,
            onSelected: (_) => onSelect(city),
          );
        },
      ),
    );
  }
}
