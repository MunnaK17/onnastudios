import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/app_enums.dart';
import '../../../data/models/yoga_class_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../../shared/widgets/buttons/app_button.dart';

class ClassDetailScreen extends ConsumerWidget {
  const ClassDetailScreen({required this.classId, super.key});

  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classAsync = ref.watch(classByIdProvider(classId));

    return classAsync.when(
      data: (yogaClass) {
        if (yogaClass == null) {
          return const _NotFoundScreen();
        }
        return _ClassDetailContent(yogaClass: yogaClass);
      },
      loading: () => const _LoadingScreen(),
      error: (_, _) => const _NotFoundScreen(),
    );
  }
}

class _ClassDetailContent extends ConsumerWidget {
  const _ClassDetailContent({required this.yogaClass});

  final YogaClassModel yogaClass;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorAsync = ref.watch(
      instructorByIdProvider(yogaClass.instructorId),
    );
    final schedulesAsync = ref.watch(schedulesByClassIdProvider(yogaClass.id));

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Image with AppBar
              _HeroImageSection(yogaClass: yogaClass),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      // Category & Info
                      _ClassInfoSection(yogaClass: yogaClass),
                      const SizedBox(height: AppSpacing.xl),
                      // Instructor
                      _InstructorSection(
                        instructorAsync: instructorAsync,
                        instructorId: yogaClass.instructorId,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Description
                      _DescriptionSection(yogaClass: yogaClass),
                      const SizedBox(height: AppSpacing.xl),
                      // Benefits
                      _BenefitsSection(yogaClass: yogaClass),
                      const SizedBox(height: AppSpacing.xl),
                      // Schedule Preview
                      _SchedulePreviewSection(schedulesAsync: schedulesAsync),
                      const SizedBox(height: 120), // Space for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Floating CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BookClassButton(classId: yogaClass.id),
          ),
        ],
      ),
    );
  }
}

class _HeroImageSection extends StatelessWidget {
  const _HeroImageSection({required this.yogaClass});

  final YogaClassModel yogaClass;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      leading: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withAlpha(204),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.onSurface,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withAlpha(204),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                // Share functionality placeholder
              },
              icon: const Icon(Icons.share_outlined),
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image placeholder
            Container(
              color: AppColors.surfaceContainerHigh,
              child: Stack(
                children: [
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryContainer.withAlpha(77),
                          AppColors.secondaryContainer.withAlpha(77),
                        ],
                      ),
                    ),
                  ),
                  // Class icon
                  Center(
                    child: Icon(
                      Icons.self_improvement,
                      size: 80,
                      color: AppColors.onSurfaceVariant.withAlpha(77),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.background.withAlpha(230),
                    ],
                  ),
                ),
              ),
            ),
            // Intensity indicator
            Positioned(
              bottom: AppSpacing.lg,
              right: AppSpacing.screenPadding,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withAlpha(230),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: AppShadows.subtle,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getIntensityColor(yogaClass.intensity),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _formatIntensity(yogaClass.intensity),
                      style: AppTypography.bodySm,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIntensityColor(ClassIntensity intensity) {
    switch (intensity) {
      case ClassIntensity.low:
        return AppColors.secondaryContainer;
      case ClassIntensity.medium:
        return AppColors.primaryFixed;
      case ClassIntensity.high:
        return AppColors.tertiaryContainer;
    }
  }

  String _formatIntensity(ClassIntensity intensity) {
    switch (intensity) {
      case ClassIntensity.low:
        return 'Low Intensity';
      case ClassIntensity.medium:
        return 'Medium Intensity';
      case ClassIntensity.high:
        return 'High Intensity';
    }
  }
}

class _ClassInfoSection extends StatelessWidget {
  const _ClassInfoSection({required this.yogaClass});

  final YogaClassModel yogaClass;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            _formatCategory(yogaClass.category),
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.onSecondaryContainer,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Title
        Text(yogaClass.title, style: AppTypography.h1),
        const SizedBox(height: AppSpacing.lg),
        // Info chips
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.sm,
          children: [
            _InfoChip(
              icon: Icons.schedule,
              label: '${yogaClass.durationMinutes} min',
            ),
            _InfoChip(
              icon: Icons.star_outline,
              label: _formatIntensity(yogaClass.intensity),
            ),
            _InfoChip(
              icon: Icons.monetization_on_outlined,
              label: '${yogaClass.creditCost} Credits',
            ),
          ],
        ),
      ],
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

  String _formatIntensity(ClassIntensity intensity) {
    switch (intensity) {
      case ClassIntensity.low:
        return 'Low';
      case ClassIntensity.medium:
        return 'Medium';
      case ClassIntensity.high:
        return 'High';
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.bodyMd),
        ],
      ),
    );
  }
}

class _InstructorSection extends StatelessWidget {
  const _InstructorSection({
    required this.instructorAsync,
    required this.instructorId,
  });

  final AsyncValue<dynamic> instructorAsync;
  final String instructorId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.instructorProfile}/$instructorId'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Icon(
                Icons.person,
                size: 32,
                color: AppColors.onSurfaceVariant.withAlpha(128),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guided By',
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  instructorAsync.when(
                    data: (instructor) => Text(
                      instructor?.name ?? 'Instructor',
                      style: AppTypography.h3,
                    ),
                    loading: () => Container(
                      width: 120,
                      height: 24,
                      color: AppColors.surfaceContainerHigh,
                    ),
                    error: (_, _) =>
                        Text('Instructor', style: AppTypography.h3),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  instructorAsync.when(
                    data: (instructor) => Text(
                      instructor?.specialty ?? '',
                      style: AppTypography.bodySm,
                    ),
                    loading: () => Container(
                      width: 80,
                      height: 14,
                      color: AppColors.surfaceContainerHigh,
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.yogaClass});

  final YogaClassModel yogaClass;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About the Practice', style: AppTypography.h2),
        const SizedBox(height: AppSpacing.md),
        Text(yogaClass.description, style: AppTypography.bodyLg),
      ],
    );
  }
}

class _BenefitsSection extends StatelessWidget {
  const _BenefitsSection({required this.yogaClass});

  final YogaClassModel yogaClass;

  @override
  Widget build(BuildContext context) {
    if (yogaClass.benefits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What to Bring', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            children: yogaClass.benefits.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < yogaClass.benefits.length - 1
                      ? AppSpacing.md
                      : 0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Icon(
                        _getBenefitIcon(entry.value),
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(entry.value, style: AppTypography.bodyMd),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getBenefitIcon(String benefit) {
    final lower = benefit.toLowerCase();
    if (lower.contains('mat')) return Icons.sports_gymnastics;
    if (lower.contains('water') || lower.contains('bottle')) {
      return Icons.water_drop;
    }
    if (lower.contains('cloth') || lower.contains('wear')) {
      return Icons.checkroom;
    }
    if (lower.contains('towel')) return Icons.dry_cleaning;
    if (lower.contains('props')) return Icons.category;
    return Icons.check_circle_outline;
  }
}

class _SchedulePreviewSection extends StatelessWidget {
  const _SchedulePreviewSection({required this.schedulesAsync});

  final AsyncValue<dynamic> schedulesAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upcoming Sessions', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.md),
        schedulesAsync.when(
          data: (schedules) {
            if (schedules == null || schedules.isEmpty) {
              return _EmptyScheduleCard();
            }
            return Column(
              children: schedules.take(3).map<Widget>((schedule) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ScheduleCard(schedule: schedule),
                );
              }).toList(),
            );
          },
          loading: () => const _LoadingScheduleCard(),
          error: (_, _) => _EmptyScheduleCard(),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedule});

  final dynamic schedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          // Date
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.base),
            ),
            child: Column(
              children: [
                Text(
                  _formatDay(schedule.date),
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
                Text(
                  _formatDate(schedule.date),
                  style: AppTypography.h3.copyWith(
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Time & Room
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${schedule.startTime} - ${schedule.endTime}',
                  style: AppTypography.bodyMd,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  schedule.studioRoom,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Available slots
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: schedule.availableSlots > 3
                  ? AppColors.secondaryContainer
                  : AppColors.errorContainer,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              '${schedule.availableSlots} left',
              style: AppTypography.bodySm.copyWith(
                color: schedule.availableSlots > 3
                    ? AppColors.onSecondaryContainer
                    : AppColors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDay(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day}';
  }
}

class _LoadingScheduleCard extends StatelessWidget {
  const _LoadingScheduleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            color: AppColors.surfaceContainerHigh,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  color: AppColors.surfaceContainerHigh,
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: 60,
                  height: 14,
                  color: AppColors.surfaceContainerHigh,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyScheduleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 24,
            color: AppColors.onSurfaceVariant.withAlpha(128),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'No upcoming sessions available',
              style: AppTypography.bodyMd,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookClassButton extends StatelessWidget {
  const _BookClassButton({required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withAlpha(0),
            AppColors.background.withAlpha(255),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: 'Book This Class',
          onPressed: () =>
              context.push('${AppRoutes.booking}?classId=$classId'),
          isExpanded: true,
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withAlpha(204),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.onSurface,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: AppColors.surfaceContainerHigh),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 20,
                    color: AppColors.surfaceContainerHigh,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: 200,
                    height: 36,
                    color: AppColors.surfaceContainerHigh,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    width: 300,
                    height: 80,
                    color: AppColors.surfaceContainerHigh,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Class Not Found'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.onSurfaceVariant.withAlpha(128),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Class Not Found',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This class may no longer be available',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Browse Classes',
                onPressed: () => context.go(AppRoutes.classes),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
