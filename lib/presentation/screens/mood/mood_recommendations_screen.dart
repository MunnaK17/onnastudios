import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/extensions/mood_extensions.dart';
import '../../../data/models/app_enums.dart';
import '../../../data/models/yoga_class_model.dart';
import '../../../data/models/mood_entry_model.dart';
import '../../providers/mood_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../../../shared/widgets/images/optimized_image.dart';

class MoodRecommendationsScreen extends ConsumerWidget {
  const MoodRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMoodAsync = ref.watch(todayMoodEntryProvider);
    final allClassesAsync = ref.watch(allClassesProvider);

    return AppScaffold(
      headerTitle: 'Your Recommendations',
      showBackButton: true,
      onBackPressed: () => context.go(AppRoutes.home),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Mood Summary Card
              todayMoodAsync.when(
                data: (mood) {
                  if (mood == null) {
                    return const _EmptyMoodState();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: _MoodSummaryCard(mood: mood),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const _EmptyMoodState(),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Recommendations
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Text(
                  'Suggested Classes',
                  style: AppTypography.h3,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              todayMoodAsync.when(
                data: (mood) {
                  if (mood == null) {
                    return const SizedBox.shrink();
                  }
                  final categories = getRecommendedCategories(mood);
                  return allClassesAsync.when(
                    data: (classes) {
                      // Filter by category OR by suitableMoods for better recommendations
                      final recommendedClasses = classes.where((c) {
                        final matchesCategory = categories.contains(c.category);
                        final matchesMood = c.suitableMoods.isNotEmpty &&
                            c.suitableMoods.contains(mood.mood.name);
                        return matchesCategory || matchesMood;
                      }).toList();

                      if (recommendedClasses.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPadding,
                          ),
                          child: AppCard(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Text(
                                  'No specific recommendations yet. Browse all classes!',
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: recommendedClasses.asMap().entries.map((entry) {
                          final index = entry.key;
                          final yogaClass = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              left: AppSpacing.screenPadding,
                              right: AppSpacing.screenPadding,
                              bottom: index < recommendedClasses.length - 1
                                  ? AppSpacing.md
                                  : 0,
                            ),
                            child: _RecommendedClassCard(
                              yogaClass: yogaClass,
                              userMood: mood.mood,
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const Text('Failed to load classes'),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Column(
                  children: [
                    AppButton(
                      label: 'Book a Recommended Class',
                      onPressed: () => context.go(AppRoutes.schedule),
                      isExpanded: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'View All Classes',
                      onPressed: () => context.go(AppRoutes.classes),
                      variant: AppButtonVariant.secondary,
                      isExpanded: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodSummaryCard extends StatelessWidget {
  const _MoodSummaryCard({required this.mood});

  final MoodEntryModel mood;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      shadow: AppCardShadow.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Center(
                  child: Text(
                    mood.mood.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your mood today',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      mood.mood.label,
                      style: AppTypography.h2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.lg),
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _MoodStatItem(
                  label: 'Stress',
                  value: mood.stressLevel.label,
                  icon: Icons.psychology_outlined,
                  color: _getStressColor(mood.stressLevel),
                ),
              ),
              Expanded(
                child: _MoodStatItem(
                  label: 'Energy',
                  value: mood.energyLevel.label,
                  icon: Icons.bolt_outlined,
                  color: _getEnergyColor(mood.energyLevel),
                ),
              ),
              Expanded(
                child: _MoodStatItem(
                  label: 'Body',
                  value: mood.flexibility.label,
                  icon: Icons.accessibility_new_outlined,
                  color: _getFlexibilityColor(mood.flexibility),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStressColor(StressLevel stressLevel) {
    if (stressLevel == StressLevel.high) return AppColors.error;
    if (stressLevel == StressLevel.medium) return AppColors.tertiary;
    return AppColors.secondary;
  }

  Color _getEnergyColor(dynamic energyLevel) {
    if (energyLevel == EnergyLevel.high) return AppColors.secondary;
    if (energyLevel == EnergyLevel.medium) return AppColors.primary;
    return AppColors.outline;
  }

  Color _getFlexibilityColor(dynamic flexibility) {
    if (flexibility == FlexibilityLevel.flexible) return AppColors.secondary;
    if (flexibility == FlexibilityLevel.moderate) return AppColors.primary;
    return AppColors.outline;
  }
}

class _MoodStatItem extends StatelessWidget {
  const _MoodStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelCaps.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _RecommendedClassCard extends ConsumerWidget {
  const _RecommendedClassCard({
    required this.yogaClass,
    required this.userMood,
  });

  final YogaClassModel yogaClass;
  final MoodType userMood;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorAsync = ref.watch(
      instructorByIdProvider(yogaClass.instructorId),
    );

    // Check if user's mood matches any of the class's suitable moods
    final isMoodMatch = yogaClass.suitableMoods.contains(userMood.name);

    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.classDetailPath(yogaClass.id),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isMoodMatch ? AppColors.secondary : AppColors.surfaceVariant,
            width: isMoodMatch ? 2 : 1,
          ),
          boxShadow: AppShadows.ambient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: OptimizedImage(
                      imageUrl: yogaClass.imageUrl,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.card),
                      ),
                      errorPlaceholder: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryContainer.withAlpha(77),
                              AppColors.secondaryContainer.withAlpha(77),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.self_improvement,
                            size: 48,
                            color: AppColors.onSurfaceVariant.withAlpha(128),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Category Badge
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withAlpha(230),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        _formatCategory(yogaClass.category),
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
                  // Mood Match Badge (if matches user's mood)
                  if (isMoodMatch)
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              userMood.emoji,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              'Perfect for You!',
                              style: AppTypography.labelCaps.copyWith(
                                color: AppColors.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 12,
                              color: AppColors.onPrimary,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              'For You',
                              style: AppTypography.labelCaps.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    yogaClass.title,
                    style: AppTypography.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        '${yogaClass.durationMinutes} min',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        '${yogaClass.creditCost} Credits',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  // Mood Tags
                  if (yogaClass.suitableMoods.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xxs,
                      runSpacing: AppSpacing.xxs,
                      children: yogaClass.suitableMoods.take(4).map((moodStr) {
                        final mood = tryParseMoodType(moodStr);
                        if (mood == null) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: mood == userMood
                                ? AppColors.secondaryContainer
                                : AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  instructorAsync.when(
                    data: (instructor) => Row(
                      children: [
                        OptimizedAvatar(
                          imageUrl: instructor?.photoUrl ?? '',
                          name: instructor?.name,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            instructor?.name ?? 'Instructor',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCategory(ClassCategory category) {
    switch (category) {
      case ClassCategory.yogaFlow:
        return 'Yoga Flow';
      case ClassCategory.pilates:
        return 'Pilates';
      case ClassCategory.meditation:
        return 'Meditation';
      case ClassCategory.breathwork:
        return 'Breathwork';
      case ClassCategory.strength:
        return 'Strength';
      case ClassCategory.restorative:
        return 'Restorative';
    }
  }
}

class _EmptyMoodState extends StatelessWidget {
  const _EmptyMoodState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: AppCard(
        child: Column(
          children: [
            Icon(
              Icons.sentiment_satisfied_alt,
              size: 64,
              color: AppColors.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Track your mood first!',
              style: AppTypography.h3,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Complete the mood tracker to get personalized recommendations.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Start Mood Tracker',
              onPressed: () => context.push(AppRoutes.moodTracker),
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }
}
