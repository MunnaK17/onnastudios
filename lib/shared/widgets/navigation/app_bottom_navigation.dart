import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const items = [
    AppBottomNavigationItem(icon: Icons.home_outlined, label: 'Home'),
    AppBottomNavigationItem(icon: Icons.self_improvement, label: 'Classes'),
    AppBottomNavigationItem(
      icon: Icons.calendar_today_outlined,
      label: 'Schedule',
    ),
    AppBottomNavigationItem(
      icon: Icons.mood_outlined,
      label: 'Mood',
    ),
    AppBottomNavigationItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.card),
          ),
          boxShadow: AppShadows.subtle,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final item in items)
                _BottomNavigationTile(
                  item: item,
                  selected: currentIndex == items.indexOf(item),
                  onTap: () => onTap(items.indexOf(item)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBottomNavigationItem {
  const AppBottomNavigationItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _BottomNavigationTile extends StatelessWidget {
  const _BottomNavigationTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected ? colorScheme.primary : colorScheme.outline;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: color, size: AppSpacing.lg),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelCaps.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
