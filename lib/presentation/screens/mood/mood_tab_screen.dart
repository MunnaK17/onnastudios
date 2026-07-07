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
import '../../../data/models/mood_entry_model.dart';
import '../../../data/models/yoga_class_model.dart';
import '../../providers/mood_provider.dart';
import '../../providers/class_provider.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';

class MoodTabScreen extends ConsumerWidget {
  const MoodTabScreen({super.key});

  bool _hasMoodData(AsyncValue<MoodEntryModel?> asyncValue) {
    return asyncValue.maybeWhen(
      data: (mood) => mood != null,
      orElse: () => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMoodAsync = ref.watch(todayMoodEntryProvider);
    final streakAsync = ref.watch(moodStreakProvider);

    return AppScaffold(
      headerTitle: 'Mood',
      headerActionIcon: Icons.history,
      onHeaderActionPressed: () => context.push(AppRoutes.moodHistory),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Greeting
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you today?',
                      style: AppTypography.h2,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Track your mood to get personalized class recommendations.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Streak Card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: streakAsync.when(
                  data: (streak) => _StreakMiniCard(streak: streak),
                  loading: () => const _StreakMiniCard(streak: 0),
                  error: (_, _) => const _StreakMiniCard(streak: 0),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Today's Mood Card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: todayMoodAsync.when(
                  data: (mood) {
                    if (mood == null) {
                      return _NoMoodTodayCard();
                    }
                    return _TodayMoodCard(mood: mood);
                  },
                  loading: () => const _TodayMoodCardLoading(),
                  error: (_, _) => _NoMoodTodayCard(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Quick Check-in Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: AppButton(
                  label: _hasMoodData(todayMoodAsync)
                      ? 'Update Your Mood'
                      : 'Track Your Mood',
                  onPressed: () => context.push(AppRoutes.moodTracker),
                  isExpanded: true,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Recommendations Section
              todayMoodAsync.when(
                data: (mood) {
                  if (mood == null) return const SizedBox.shrink();
                  return _RecommendedSection(mood: mood);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakMiniCard extends StatelessWidget {
  const _StreakMiniCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: streak > 0
            ? AppColors.secondaryContainer.withAlpha(77)
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: streak > 0
              ? AppColors.secondaryContainer
              : AppColors.surfaceVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: streak > 0 ? AppColors.secondary : AppColors.outline,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$streak Day Streak',
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
              color: streak > 0 ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          if (streak >= 7)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '🔥',
                style: AppTypography.bodySm,
              ),
            ),
        ],
      ),
    );
  }
}

class _NoMoodTodayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: AppShadows.ambient,
      ),
      child: Column(
        children: [
          Icon(
            Icons.sentiment_satisfied_alt,
            size: 64,
            color: AppColors.primary.withAlpha(179),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No mood tracked today',
            style: AppTypography.h3,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Take a moment to check in with yourself',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TodayMoodCard extends StatelessWidget {
  const _TodayMoodCard({required this.mood});

  final MoodEntryModel mood;

  @override
  Widget build(BuildContext context) {
    // Get mood color for accent
    final moodColor = _getMoodColor(mood.mood);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            moodColor.withAlpha(26),
            moodColor.withAlpha(51),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: moodColor.withAlpha(77)),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Mood Emoji with colored background
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: moodColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: moodColor.withAlpha(51)),
                ),
                child: Center(
                  child: Text(
                    mood.mood.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Mood",
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      mood.mood.label,
                      style: AppTypography.h2.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              // Tracked Badge
              Container(
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
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: AppColors.onSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      'Tracked',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.onSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, color: AppColors.outline.withAlpha(77)),
          const SizedBox(height: AppSpacing.lg),
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _MoodStatTile(
                  icon: Icons.psychology_outlined,
                  label: 'Stress',
                  value: mood.stressLevel.label,
                  color: _getStressColor(mood.stressLevel),
                ),
              ),
              Expanded(
                child: _MoodStatTile(
                  icon: Icons.bolt_outlined,
                  label: 'Energy',
                  value: mood.energyLevel.label,
                  color: _getEnergyColor(mood.energyLevel),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MoodStatTile(
                  icon: Icons.accessibility_new_outlined,
                  label: 'Body',
                  value: mood.flexibility.label,
                  color: _getFlexibilityColor(mood.flexibility),
                ),
              ),
              Expanded(
                child: _MoodStatTile(
                  icon: Icons.center_focus_strong_outlined,
                  label: 'Focus',
                  value: mood.mentalFocus.label,
                  color: _getFocusColor(mood.mentalFocus),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(MoodType moodType) {
    switch (moodType) {
      case MoodType.happyPositive:
      case MoodType.feelingDetermined:
        return AppColors.secondary;
      case MoodType.relaxedWantChill:
        return AppColors.primary;
      case MoodType.readyToLearn:
        return const Color(0xFF4CAF50);
      case MoodType.stressedAnxious:
        return AppColors.error;
      case MoodType.feelingStiff:
        return const Color(0xFF9E9E9E);
      case MoodType.lowEnergy:
      case MoodType.tiredLowEnergy:
        return const Color(0xFFFF9800);
    }
  }

  Color _getStressColor(StressLevel level) {
    switch (level) {
      case StressLevel.low:
        return AppColors.secondary;
      case StressLevel.medium:
        return AppColors.tertiary;
      case StressLevel.high:
        return AppColors.error;
    }
  }

  Color _getEnergyColor(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.low:
        return AppColors.outline;
      case EnergyLevel.medium:
        return AppColors.primary;
      case EnergyLevel.high:
        return AppColors.secondary;
    }
  }

  Color _getFlexibilityColor(FlexibilityLevel level) {
    switch (level) {
      case FlexibilityLevel.tight:
        return AppColors.outline;
      case FlexibilityLevel.moderate:
        return AppColors.primary;
      case FlexibilityLevel.flexible:
        return AppColors.secondary;
    }
  }

  Color _getFocusColor(MentalFocusLevel level) {
    switch (level) {
      case MentalFocusLevel.scattered:
        return AppColors.outline;
      case MentalFocusLevel.moderate:
        return AppColors.primary;
      case MentalFocusLevel.focused:
        return AppColors.secondary;
    }
  }
}

class _MoodStatTile extends StatelessWidget {
  const _MoodStatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant.withAlpha(128)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelCaps.copyWith(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayMoodCardLoading extends StatelessWidget {
  const _TodayMoodCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 12,
                      color: AppColors.surfaceContainerLow,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: 120,
                      height: 28,
                      color: AppColors.surfaceContainerLow,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendedSection extends ConsumerWidget {
  const _RecommendedSection({required this.mood});

  final MoodEntryModel mood;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(allClassesProvider);
    final categories = getRecommendedCategories(mood);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recommended for You', style: AppTypography.h3),
              TextButton(
                onPressed: () => context.push(AppRoutes.moodRecommendations),
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 220,
          child: classesAsync.when(
            data: (classes) {
              // Filter by category OR by suitableMoods for better recommendations
              final recommended = classes.where((c) {
                final matchesCategory = categories.contains(c.category);
                final matchesMood = c.suitableMoods.isNotEmpty &&
                    c.suitableMoods.contains(mood.mood.name);
                return matchesCategory || matchesMood;
              }).take(5).toList();

              if (recommended.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Center(
                      child: Text(
                        'Track your mood to get recommendations',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                itemCount: recommended.length,
                itemBuilder: (context, index) {
                  final yogaClass = recommended[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < recommended.length - 1
                          ? AppSpacing.md
                          : 0,
                    ),
                    child: _RecommendedClassMiniCard(
                      yogaClass: yogaClass,
                      userMood: mood.mood,
                      onTap: () => context.push(
                        AppRoutes.bookingPath(classId: yogaClass.id),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              itemCount: 3,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  right: index < 2 ? AppSpacing.md : 0,
                ),
                child: const _RecommendedClassMiniCardLoading(),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _RecommendedClassMiniCard extends StatelessWidget {
  const _RecommendedClassMiniCard({
    required this.yogaClass,
    required this.userMood,
    required this.onTap,
  });

  final YogaClassModel yogaClass;
  final MoodType userMood;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Check if user's mood matches any of the class's suitable moods
    final isMoodMatch = yogaClass.suitableMoods.contains(userMood.name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
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
            // Image placeholder
            Stack(
              children: [
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryContainer.withAlpha(77),
                        AppColors.secondaryContainer.withAlpha(77),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.card),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.self_improvement,
                      size: 32,
                      color: AppColors.onSurfaceVariant.withAlpha(128),
                    ),
                  ),
                ),
                // Mood match badge
                if (isMoodMatch)
                  Positioned(
                    top: AppSpacing.xxs,
                    right: AppSpacing.xxs,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        userMood.emoji,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    yogaClass.title,
                    style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${yogaClass.durationMinutes} min • ${yogaClass.creditCost} credits',
                    style: AppTypography.labelCaps.copyWith(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Mood icons row
                  if (yogaClass.suitableMoods.isNotEmpty) ...[
                    Wrap(
                      spacing: 2,
                      children: yogaClass.suitableMoods.take(3).map((moodStr) {
                        final mood = tryParseMoodType(moodStr);
                        if (mood == null) return const SizedBox.shrink();
                        return Text(
                          mood.emoji,
                          style: TextStyle(
                            fontSize: 14,
                            color: mood == userMood ? null : AppColors.outline,
                          ),
                        );
                      }).toList(),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          'For You',
                          style: AppTypography.labelCaps.copyWith(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedClassMiniCardLoading extends StatelessWidget {
  const _RecommendedClassMiniCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.card),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 12,
                  color: AppColors.surfaceContainerLow,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 80,
                  height: 10,
                  color: AppColors.surfaceContainerLow,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
