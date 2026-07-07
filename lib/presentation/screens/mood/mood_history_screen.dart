import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/extensions/mood_extensions.dart';
import '../../../data/models/app_enums.dart';
import '../../../data/models/mood_entry_model.dart';
import '../../providers/mood_provider.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../../../shared/widgets/state/app_state_widgets.dart';

class MoodHistoryScreen extends ConsumerWidget {
  const MoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyEntriesAsync = ref.watch(weeklyMoodEntriesProvider);
    final monthlyEntriesAsync = ref.watch(monthlyMoodEntriesProvider);
    final streakAsync = ref.watch(moodStreakProvider);

    return AppScaffold(
      headerTitle: 'Mood History',
      showBackButton: true,
      onBackPressed: () => context.pop(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Streak Card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: streakAsync.when(
                  data: (streak) => _StreakCard(streak: streak),
                  loading: () => const _StreakCard(streak: 0),
                  error: (_, _) => const _StreakCard(streak: 0),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Weekly Summary
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Text('This Week', style: AppTypography.h3),
              ),
              const SizedBox(height: AppSpacing.md),
              weeklyEntriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                      ),
                      child: _EmptyWeekState(),
                    );
                  }
                  return _WeeklyChart(entries: entries);
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  child: AppLoadingState(),
                ),
                error: (_, _) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  child: AppErrorState(title: 'Failed to load mood data'),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Monthly History
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Entries', style: AppTypography.h3),
                    monthlyEntriesAsync.when(
                      data: (entries) => Text(
                        '${entries.length} entries',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              monthlyEntriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                      ),
                      child: _EmptyHistoryState(),
                    );
                  }
                  return Column(
                    children: entries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final moodEntry = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          left: AppSpacing.screenPadding,
                          right: AppSpacing.screenPadding,
                          bottom: index < entries.length - 1 ? AppSpacing.md : 0,
                        ),
                        child: _MoodHistoryCard(entry: moodEntry),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  child: AppLoadingState(),
                ),
                error: (_, _) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  child: AppErrorState(title: 'Failed to load history'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryContainer,
            AppColors.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.elevated,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.onPrimaryContainer.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department,
              color: AppColors.onPrimaryContainer,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak Day${streak == 1 ? '' : 's'}',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Mood Tracking Streak',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onPrimaryContainer.withAlpha(179),
                  ),
                ),
              ],
            ),
          ),
          if (streak >= 7)
            Container(
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
                  Icon(
                    Icons.star,
                    size: 14,
                    color: AppColors.onPrimary,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    'On Fire!',
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.onPrimary,
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

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.entries});

  final List<MoodEntryModel> entries;

  @override
  Widget build(BuildContext context) {
    // Generate last 7 days
    final now = DateTime.now();
    final days = List.generate(7, (index) {
      return DateTime(now.year, now.month, now.day - (6 - index));
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.surfaceVariant),
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          children: [
            // Mood average
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MoodAverageIndicator(entries: entries),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Day bars
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((day) {
                final entry = _getEntryForDay(entries, day);
                return _DayMoodBar(
                  day: day,
                  entry: entry,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  MoodEntryModel? _getEntryForDay(List<MoodEntryModel> entries, DateTime day) {
    try {
      return entries.firstWhere((e) =>
          e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day);
    } catch (e) {
      return null;
    }
  }
}

class _MoodAverageIndicator extends StatelessWidget {
  const _MoodAverageIndicator({required this.entries});

  final List<MoodEntryModel> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Column(
        children: [
          Text('😐', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No data',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    // Calculate average mood
    int totalMood = 0;
    for (final entry in entries) {
      totalMood += entry.mood.toNumber();
    }
    final avgMood = totalMood / entries.length;

    MoodType dominantMood;
    if (avgMood >= 4.5) {
      dominantMood = MoodType.happyPositive;
    } else if (avgMood >= 3.5) {
      dominantMood = MoodType.relaxedWantChill;
    } else if (avgMood >= 2.5) {
      dominantMood = MoodType.readyToLearn;
    } else if (avgMood >= 1.5) {
      dominantMood = MoodType.stressedAnxious;
    } else {
      dominantMood = MoodType.tiredLowEnergy;
    }

    return Column(
      children: [
        Text(dominantMood.emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Average: ${dominantMood.label}',
          style: AppTypography.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DayMoodBar extends StatelessWidget {
  const _DayMoodBar({
    required this.day,
    required this.entry,
  });

  final DateTime day;
  final MoodEntryModel? entry;

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(day);
    final moodValue = entry?.mood.toNumber() ?? 0;
    final barHeight = moodValue > 0 ? (moodValue / 5) * 60 : 4.0;

    return Column(
      children: [
        SizedBox(
          height: 60,
          child: Center(
            child: Container(
              width: 24,
              height: barHeight,
              decoration: BoxDecoration(
                color: entry != null
                    ? _getMoodColor(entry!.mood)
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (entry != null)
          Text(
            entry!.mood.emoji,
            style: const TextStyle(fontSize: 16),
          )
        else
          Icon(
            Icons.remove,
            size: 16,
            color: AppColors.outline,
          ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          _formatDayShort(day),
          style: AppTypography.labelCaps.copyWith(
            fontSize: 10,
            color: isToday ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDayShort(DateTime date) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[date.weekday - 1];
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happyPositive:
      case MoodType.feelingDetermined:
        return AppColors.secondary;
      case MoodType.relaxedWantChill:
        return AppColors.primary;
      case MoodType.readyToLearn:
        return AppColors.outline;
      case MoodType.stressedAnxious:
        return AppColors.tertiary;
      case MoodType.lowEnergy:
        return AppColors.primaryFixed;
      case MoodType.tiredLowEnergy:
        return AppColors.outline;
      case MoodType.feelingStiff:
        return AppColors.secondary;
    }
  }
}

class _MoodHistoryCard extends StatelessWidget {
  const _MoodHistoryCard({required this.entry});

  final MoodEntryModel entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          // Mood Emoji
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withAlpha(77),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: Text(
                entry.mood.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.mood.label,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _formatDate(entry.date),
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Quick stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MiniStat(
                    icon: Icons.psychology_outlined,
                    value: entry.stressLevel.label,
                    color: _getStressColor(entry.stressLevel),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _MiniStat(
                    icon: Icons.bolt_outlined,
                    value: entry.energyLevel.label,
                    color: _getEnergyColor(entry.energyLevel),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            value,
            style: AppTypography.labelCaps.copyWith(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWeekState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 48,
            color: AppColors.onSurfaceVariant.withAlpha(128),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No mood entries this week',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start tracking to see your weekly trends',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_outlined,
            size: 48,
            color: AppColors.onSurfaceVariant.withAlpha(128),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No mood history yet',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your mood entries will appear here',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}
