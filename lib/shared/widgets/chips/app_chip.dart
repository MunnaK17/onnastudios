import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    required this.selected,
    this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      labelStyle: AppTypography.bodySm.copyWith(
        color: selected
            ? colorScheme.onSecondaryContainer
            : colorScheme.onSurface,
      ),
      backgroundColor: Theme.of(
        context,
      ).extension<OnnaThemeTokens>()!.cardSurface,
      selectedColor: colorScheme.secondaryContainer,
      side: BorderSide(
        color: selected ? colorScheme.secondary : colorScheme.outlineVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
    );
  }
}
