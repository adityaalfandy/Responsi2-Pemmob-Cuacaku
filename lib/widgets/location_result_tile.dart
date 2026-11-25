import 'package:flutter/material.dart';

import '../models/location_model.dart';

/// Kartu item lokasi untuk daftar hasil pencarian Geocoding API, riwayat, maupun favorit.
class LocationResultTile extends StatelessWidget {
  const LocationResultTile({
    super.key,
    required this.location,
    required this.isFavorite,
    required this.isSelected,
    required this.onTap,
    required this.onToggleFavorite,
    this.onRemove,
    this.leadingIcon = Icons.location_city_rounded,
  });

  final LocationModel location;
  final bool isFavorite;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onRemove;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isSelected
              ? scheme.primary
              : scheme.outlineVariant.withValues(alpha: 0.7),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? scheme.primary.withValues(alpha: 0.14)
                      : scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  leadingIcon,
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            location.name,
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Aktif',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (location.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        location.subtitle,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${location.formattedCoordinates} • ${location.timezone}',
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavorite,
                tooltip:
                    isFavorite ? 'Hapus dari favorit' : 'Simpan sebagai favorit',
                icon: Icon(
                  isFavorite
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: isFavorite
                      ? const Color(0xFFE5A100)
                      : scheme.onSurfaceVariant,
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Hapus dari riwayat',
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
