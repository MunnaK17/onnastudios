import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.actionIcon,
    this.onActionPressed,
    super.key,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.sm,
        ),
        child: SizedBox(
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: showBackButton
                    ? _HeaderIconButton(
                        icon: Icons.arrow_back,
                        onPressed:
                            onBackPressed ?? () => Navigator.maybePop(context),
                      )
                    : const SizedBox.shrink(),
              ),
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              Align(
                alignment: Alignment.centerRight,
                child: actionIcon == null
                    ? const SizedBox.shrink()
                    : _HeaderIconButton(
                        icon: actionIcon!,
                        onPressed: onActionPressed,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        foregroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}
