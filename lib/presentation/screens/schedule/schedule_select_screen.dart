import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/schedule_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../../shared/widgets/state/app_state_widgets.dart';

class ScheduleSelectScreen extends ConsumerWidget {
  const ScheduleSelectScreen({
    required this.classId,
    this.bookingId,
    super.key,
  });

  final String classId;
  final String? bookingId;

  bool get isRescheduleMode => bookingId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classAsync = ref.watch(classByIdProvider(classId));
    final schedulesAsync = ref.watch(schedulesByClassIdProvider(classId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(isRescheduleMode ? 'Reschedule To' : 'Select Schedule'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Class header
          classAsync.when(
            data: (yogaClass) {
              if (yogaClass == null) {
                return const SizedBox.shrink();
              }
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                color: AppColors.surfaceContainerLow,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.self_improvement,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            yogaClass.title,
                            style: AppTypography.h3,
                          ),
                          Text(
                            '${yogaClass.creditCost} Credits',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => Container(
              width: double.infinity,
              height: 80,
              color: AppColors.surfaceContainerLow,
            ),
            error: (e, s) => const SizedBox.shrink(),
          ),
          // Schedule list
          Expanded(
            child: schedulesAsync.when(
              data: (schedules) {
                // Filter only available schedules
                final availableSchedules = schedules
                    .where((s) => s.availableSlots > 0)
                    .toList();

                if (availableSchedules.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: AppColors.onSurfaceVariant.withAlpha(128),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            '📅 Jadwal tidak tersedia',
                            style: AppTypography.h3,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Tidak ada sesi yang tersedia untuk kelas ini saat ini.',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: availableSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = availableSchedules[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < availableSchedules.length - 1
                            ? AppSpacing.md
                            : 0,
                      ),
                      child: _ScheduleSelectCard(
                        schedule: schedule,
                        onTap: () {
                          if (isRescheduleMode) {
                            // Navigate to reschedule confirmation
                            context.pushReplacement(
                              AppRoutes.bookingReschedulePath(
                                bookingId: bookingId,
                                newScheduleId: schedule.id,
                              ),
                            );
                          } else {
                            // Navigate to booking flow
                            context.push(
                              AppRoutes.bookingPath(
                                scheduleId: schedule.id,
                                classId: classId,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const AppLoadingState(),
              error: (e, _) => AppErrorState(
                title: 'Gagal memuat jadwal',
                subtitle: 'Silakan coba lagi nanti.',
                onRetry: () => ref.invalidate(schedulesByClassIdProvider(classId)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleSelectCard extends ConsumerWidget {
  const _ScheduleSelectCard({
    required this.schedule,
    required this.onTap,
  });

  final ScheduleModel schedule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorAsync = ref.watch(instructorByIdProvider(schedule.instructorId));

    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Row(
            children: [
              // Date container
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
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${schedule.startTime} - ${schedule.endTime}',
                      style: AppTypography.bodyMd,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    instructorAsync.when(
                      data: (instructor) => Text(
                        instructor?.name ?? '',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (e, s) => const SizedBox.shrink(),
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
              // Slots badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: schedule.availableSlots > 3
                      ? AppColors.secondaryContainer
                      : AppColors.tertiaryFixed,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '${schedule.availableSlots} slot',
                  style: AppTypography.bodySm.copyWith(
                    color: schedule.availableSlots > 3
                        ? AppColors.onSecondaryContainer
                        : AppColors.onTertiaryFixed,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDay(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatDate(DateTime date) => '${date.day}';
}
