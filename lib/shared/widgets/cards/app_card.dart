import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';

enum AppCardShadow { none, subtle, ambient, elevated }

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.shadow = AppCardShadow.ambient,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final AppCardShadow shadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: _shadows,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: content,
      ),
    );
  }

  List<BoxShadow> get _shadows {
    return switch (shadow) {
      AppCardShadow.none => AppShadows.none,
      AppCardShadow.subtle => AppShadows.subtle,
      AppCardShadow.ambient => AppShadows.ambient,
      AppCardShadow.elevated => AppShadows.elevated,
    };
  }
}
