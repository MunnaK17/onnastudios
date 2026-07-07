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
import '../../../data/models/schedule_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/images/optimized_image.dart';
import '../../../shared/widgets/state/app_state_widgets.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedDateProvider.notifier).setDate(DateTime.now());
    });
  }

  /// Generate 7 days starting from TODAY (not past dates)
  List<DateTime> _getWeekDays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (index) {
      return today.add(Duration(days: index));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Schedule', style: AppTypography.h2),
                const SizedBox(height: AppSpacing.xs),
                Text('Find your balance today.', style: AppTypography.bodyMd),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _WeekDaySelector(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
              ref.read(selectedDateProvider.notifier).setDate(date);
            },
            weekDays: _getWeekDays(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(child: _ScheduleListByDate(selectedDate: _selectedDate)),
        ],
      ),
    );
  }
}

class _WeekDaySelector extends StatelessWidget {
  const _WeekDaySelector({
    required this.selectedDate,
    required this.onDateSelected,
    required this.weekDays,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<DateTime> weekDays;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final date = weekDays[index];
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, DateTime.now());

          return Padding(
            padding: EdgeInsets.only(
              right: index < weekDays.length - 1 ? AppSpacing.sm : 0,
            ),
            child: _DayChip(
              date: date,
              isSelected: isSelected,
              isToday: isToday,
              onTap: () => onDateSelected(date),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  bool _isPastDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final isPast = _isPastDate(date);

    return GestureDetector(
      onTap: isPast ? null : onTap,
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isPast
              ? AppColors.surfaceContainerLow.withAlpha(128)
              : (isSelected ? AppColors.primary : AppColors.surfaceContainerLow),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: isPast
              ? Border.all(color: AppColors.surfaceVariant.withAlpha(128))
              : (isSelected ? null : Border.all(color: AppColors.surfaceVariant)),
          boxShadow: isSelected && !isPast ? AppShadows.subtle : null,
        ),
        child: Opacity(
          opacity: isPast ? 0.4 : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDayName(date),
                style: AppTypography.labelCaps.copyWith(
                  fontSize: 10,
                  color: isSelected && !isPast
                      ? AppColors.onPrimary.withAlpha(204)
                      : AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isPast
                      ? AppColors.onSurfaceVariant
                      : (isSelected ? AppColors.onPrimary : AppColors.onSurface),
                ),
              ),
              if (isToday && !isSelected) ...[
                const SizedBox(height: 2),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}

class _ScheduleListByDate extends ConsumerWidget {
  const _ScheduleListByDate({required this.selectedDate});

  final DateTime selectedDate;

  bool _isPastDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.isBefore(today);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If selected date is in the past, show empty state
    if (_isPastDate(selectedDate)) {
      return AppEmptyState(
        icon: Icons.history,
        title: 'Past Schedule',
        subtitle: 'You cannot view or book past schedules',
      );
    }

    final schedulesAsync = ref.watch(schedulesForSelectedDateProvider);

    return schedulesAsync.when(
      data: (schedules) {
        if (schedules.isEmpty) {
          return AppEmptyState(
            icon: Icons.calendar_today_outlined,
            title: 'No classes scheduled',
            subtitle: 'Check back later or select another date',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.sm,
          ),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < schedules.length - 1
                    ? AppSpacing.md
                    : AppSpacing.lg,
              ),
              child: _ScheduleCard(schedule: schedule),
            );
          },
        );
      },
      loading: () => const AppLoadingState(),
      error: (e, st) => AppErrorState(
        onRetry: () => ref.invalidate(schedulesForSelectedDateProvider),
      ),
    );
  }
}

class _ScheduleCard extends ConsumerWidget {
  const _ScheduleCard({required this.schedule});

  final ScheduleModel schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classAsync = ref.watch(classByIdProvider(schedule.classId));
    final instructorAsync = ref.watch(
      instructorByIdProvider(schedule.instructorId),
    );

    final isPast = schedule.isPast;

    return GestureDetector(
      onTap: isPast
          ? null
          : () => context.push(
                AppRoutes.bookingPath(
                  scheduleId: schedule.id,
                  classId: schedule.classId,
                ),
              ),
      child: Opacity(
        opacity: isPast ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isPast
                  ? AppColors.surfaceVariant.withAlpha(128)
                  : AppColors.surfaceVariant,
            ),
            boxShadow: isPast ? null : AppShadows.ambient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.card),
                  ),
                ),
                child: Stack(
                  children: [
                    // Class image
                    Positioned.fill(
                      child: classAsync.when(
                        data: (yogaClass) => ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppRadius.card),
                          ),
                          child: OptimizedImage(
                            imageUrl: yogaClass?.imageUrl ?? '',
                            fit: BoxFit.cover,
                            errorPlaceholder: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryContainer.withAlpha(77),
                                    AppColors.tertiaryContainer.withAlpha(77),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.self_improvement,
                                  size: 48,
                                  color: AppColors.onSurfaceVariant.withAlpha(77),
                                ),
                              ),
                            ),
                          ),
                        ),
                        loading: () => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryContainer.withAlpha(77),
                                AppColors.tertiaryContainer.withAlpha(77),
                              ],
                            ),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary.withAlpha(128),
                              ),
                            ),
                          ),
                        ),
                        error: (e, _) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryContainer.withAlpha(77),
                                AppColors.tertiaryContainer.withAlpha(77),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.self_improvement,
                              size: 48,
                              color: AppColors.onSurfaceVariant.withAlpha(77),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isPast)
                      Positioned(
                        top: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history,
                                size: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.xxs),
                              Text(
                                'Ended',
                                style: AppTypography.labelCaps.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: classAsync.when(
                        data: (yogaClass) =>
                            _CategoryBadge(category: yogaClass?.category),
                        loading: () => const SizedBox.shrink(),
                        error: (e, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.startTime,
                              style: AppTypography.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isPast
                                    ? AppColors.onSurfaceVariant
                                    : AppColors.primary,
                              ),
                            ),
                            Text(
                              '- ${schedule.endTime}',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              classAsync.when(
                                data: (yogaClass) => Text(
                                  yogaClass?.title ?? 'Class',
                                  style: AppTypography.h3,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                loading: () => Container(
                                  width: 140,
                                  height: 24,
                                  color: AppColors.surfaceContainerHigh,
                                ),
                                error: (e, _) =>
                                    Text('Class', style: AppTypography.h3),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              instructorAsync.when(
                                data: (instructor) => Text(
                                  'with ${instructor?.name ?? 'Instructor'}',
                                  style: AppTypography.bodyMd,
                                ),
                                loading: () => Container(
                                  width: 100,
                                  height: 16,
                                  color: AppColors.surfaceContainerHigh,
                                ),
                                error: (e, _) => Text(
                                  'with Instructor',
                                  style: AppTypography.bodyMd,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.location_on_outlined,
                          label: schedule.studioRoom,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        classAsync.when(
                          data: (yogaClass) => _InfoChip(
                            icon: Icons.schedule,
                            label: '${yogaClass?.durationMinutes ?? 0} min',
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (e, _) => const SizedBox.shrink(),
                        ),
                        const Spacer(),
                        classAsync.when(
                          data: (yogaClass) => Text(
                            '${yogaClass?.creditCost ?? 0} Credits',
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isPast
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.primary,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (e, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _AvailabilityBadge(schedule: schedule),
                        AppButton(
                          label: _getButtonLabel(schedule),
                          onPressed: isPast
                              ? null
                              : () => context.push(
                                    AppRoutes.bookingPath(
                                      scheduleId: schedule.id,
                                      classId: schedule.classId,
                                    ),
                                  ),
                          variant: _getButtonVariant(schedule),
                          isExpanded: false,
                        ),
                      ],
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

  String _getButtonLabel(ScheduleModel schedule) {
    if (schedule.availableSlots == 0) {
      return 'Join Waitlist';
    }
    return 'Book';
  }

  AppButtonVariant _getButtonVariant(ScheduleModel schedule) {
    if (schedule.availableSlots == 0) {
      return AppButtonVariant.secondary;
    }
    return AppButtonVariant.primary;
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final ClassCategory? category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withAlpha(204),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.onSecondaryContainer,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            _formatCategory(category),
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCategory(ClassCategory? category) {
    if (category == null) return '';
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.schedule});

  final ScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    final isAvailable = schedule.availableSlots > 0;
    final isLow = schedule.availableSlots <= 3 && schedule.availableSlots > 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isAvailable
            ? (isLow ? AppColors.tertiaryFixed : AppColors.secondaryContainer)
            : AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        _getAvailabilityText(schedule),
        style: AppTypography.labelCaps.copyWith(
          color: isAvailable
              ? (isLow
                  ? AppColors.onTertiaryFixed
                  : AppColors.onSecondaryContainer)
              : AppColors.onErrorContainer,
        ),
      ),
    );
  }

  String _getAvailabilityText(ScheduleModel schedule) {
    if (schedule.availableSlots == 0) {
      return 'Waitlist';
    }
    if (schedule.availableSlots <= 3) {
      return '${schedule.availableSlots} Spots Left';
    }
    return 'Available';
  }
}
