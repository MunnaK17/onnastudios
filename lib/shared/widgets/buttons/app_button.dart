import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, ghost, text }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.isExpanded = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool isExpanded;

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final child = _ButtonContent(
      label: label,
      icon: icon,
      isLoading: isLoading,
      foregroundColor: _foregroundColor(context),
    );
    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: _isDisabled ? null : onPressed,
        style: _baseStyle(context).merge(
          FilledButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).extension<OnnaThemeTokens>()!.cta,
            foregroundColor: Theme.of(context).colorScheme.onTertiary,
          ),
        ),
        child: child,
      ),
      AppButtonVariant.secondary => FilledButton(
        onPressed: _isDisabled ? null : onPressed,
        style: _baseStyle(context).merge(
          FilledButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).extension<OnnaThemeTokens>()!.premiumAccent,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        child: child,
      ),
      AppButtonVariant.ghost => OutlinedButton(
        onPressed: _isDisabled ? null : onPressed,
        style: _baseStyle(context).merge(
          OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: _isDisabled ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.secondary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTypography.labelCaps,
        ),
        child: child,
      ),
    };

    if (!isExpanded) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }

  ButtonStyle _baseStyle(BuildContext context) {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonHorizontal,
          vertical: AppSpacing.buttonVertical,
        ),
      ),
      textStyle: const WidgetStatePropertyAll(AppTypography.labelCaps),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
    );
  }

  Color _foregroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (variant) {
      AppButtonVariant.primary => colorScheme.onTertiary,
      AppButtonVariant.secondary => colorScheme.onSecondary,
      AppButtonVariant.ghost => colorScheme.primary,
      AppButtonVariant.text => colorScheme.secondary,
    };
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.foregroundColor,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final Color foregroundColor;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: AppSpacing.md,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: foregroundColor,
        ),
      );
    }

    final labelWidget = Text(label.toUpperCase());

    if (icon == null) {
      return labelWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: AppSpacing.md),
        const SizedBox(width: AppSpacing.sm),
        labelWidget,
      ],
    );
  }
}
