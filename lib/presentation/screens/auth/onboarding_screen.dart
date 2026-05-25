import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/buttons/app_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 1.0],
            colors: [
              AppColors.secondaryContainer.withAlpha(51),
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Illustration/Icon
                _OnboardingIllustration(),
                const SizedBox(height: AppSpacing.xl),
                // Headline
                Text(
                  'Find Your Inner Balance',
                  style: AppTypography.h1.copyWith(color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Value Proposition
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Text(
                    'Join Onna Studios for premium yoga and wellness classes. Connect with expert instructors and nurture your well-being.',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(flex: 3),
                // Features
                _FeatureList(),
                const Spacer(flex: 2),
                // CTAs
                Column(
                  children: [
                    AppButton(
                      label: 'Get Started',
                      onPressed: () => context.push(AppRoutes.register),
                      isExpanded: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'I already have an account',
                      onPressed: () => context.push(AppRoutes.login),
                      variant: AppButtonVariant.ghost,
                      isExpanded: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withAlpha(26),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner gradient circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.secondaryContainer.withAlpha(179),
                  AppColors.secondaryContainer.withAlpha(51),
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
          // Icon
          Icon(Icons.self_improvement, size: 80, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withAlpha(128),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 24, color: AppColors.secondary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _FeatureItem(
          icon: Icons.spa_outlined,
          title: 'Expert Instructors',
          description: 'Learn from certified yoga teachers',
        ),
        const SizedBox(height: AppSpacing.md),
        const _FeatureItem(
          icon: Icons.calendar_today_outlined,
          title: 'Flexible Scheduling',
          description: 'Book classes that fit your routine',
        ),
        const SizedBox(height: AppSpacing.md),
        const _FeatureItem(
          icon: Icons.monetization_on_outlined,
          title: 'Credit-Based System',
          description: 'Pay as you go with our credit packages',
        ),
      ],
    );
  }
}
