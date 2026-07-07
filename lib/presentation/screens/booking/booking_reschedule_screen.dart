import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_error_message.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/instructor_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/yoga_class_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../../shared/widgets/buttons/app_button.dart';

class BookingRescheduleScreen extends ConsumerWidget {
  const BookingRescheduleScreen({
    this.bookingId,
    this.newScheduleId,
    super.key,
  });

  final String? bookingId;
  final String? newScheduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookingId == null || newScheduleId == null) {
      return const _NotFoundScreen(message: 'Missing booking or schedule info');
    }

    return _RescheduleContent(
      bookingId: bookingId!,
      newScheduleId: newScheduleId!,
    );
  }
}

class _RescheduleContent extends ConsumerStatefulWidget {
  const _RescheduleContent({
    required this.bookingId,
    required this.newScheduleId,
  });

  final String bookingId;
  final String newScheduleId;

  @override
  ConsumerState<_RescheduleContent> createState() => _RescheduleContentState();
}

class _RescheduleContentState extends ConsumerState<_RescheduleContent> {
  bool _isRescheduling = false;

  Future<void> _handleReschedule() async {
    setState(() => _isRescheduling = true);

    try {
      final oldBooking = await ref.read(bookingByIdProvider(widget.bookingId).future);

      await ref.read(bookingNotifierProvider.notifier).rescheduleBooking(
        bookingId: widget.bookingId,
        newScheduleId: widget.newScheduleId,
        oldScheduleId: oldBooking!.scheduleId,
      );

      if (!mounted) return;

      // Refresh booking data
      await ref.read(bookingByIdProvider(widget.bookingId).future);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking rescheduled successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );

      // Navigate to confirmation page
      context.pushReplacement(
        AppRoutes.bookingConfirmationPath(bookingId: widget.bookingId),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRescheduling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appErrorMessage(e, fallback: 'Unable to reschedule. Please try again.')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingByIdProvider(widget.bookingId));
    final newScheduleAsync = ref.watch(scheduleByIdProvider(widget.newScheduleId));
    final creditsAsync = ref.watch(remainingCreditsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Reschedule'),
        centerTitle: true,
      ),
      body: bookingAsync.when(
        data: (booking) {
          if (booking == null) {
            return const _NotFoundScreen(message: 'Booking not found');
          }
          return newScheduleAsync.when(
            data: (newSchedule) {
              if (newSchedule == null) {
                return const _NotFoundScreen(message: 'Schedule not found');
              }
              return _buildContent(context, booking, newSchedule, creditsAsync);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _NotFoundScreen(message: 'Failed to load schedule'),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _NotFoundScreen(message: 'Failed to load booking'),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BookingModel booking,
    ScheduleModel newSchedule,
    AsyncValue<int> creditsAsync,
  ) {
    final oldClassAsync = ref.watch(classByIdProvider(booking.classId));
    final newClassAsync = ref.watch(classByIdProvider(newSchedule.classId));
    final oldScheduleAsync = ref.watch(scheduleByIdProvider(booking.scheduleId));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Old Booking Info
                _SectionTitle(title: 'Current Booking'),
                const SizedBox(height: AppSpacing.sm),
                _OldBookingCard(
                  booking: booking,
                  scheduleAsync: oldScheduleAsync,
                  classAsync: oldClassAsync,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Arrow
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_downward,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // New Schedule Info
                _SectionTitle(title: 'New Schedule'),
                const SizedBox(height: AppSpacing.sm),
                _NewScheduleCard(
                  schedule: newSchedule,
                  classAsync: newClassAsync,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Credit Summary
                _SectionTitle(title: 'Credit Summary'),
                const SizedBox(height: AppSpacing.sm),
                _CreditSummaryCard(
                  oldClassAsync: oldClassAsync,
                  newClassAsync: newClassAsync,
                  creditsAsync: creditsAsync,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),

        // Bottom CTA
        _RescheduleBottomCTA(
          isRescheduling: _isRescheduling,
          onConfirm: _handleReschedule,
          oldClassAsync: oldClassAsync,
          newClassAsync: newClassAsync,
          creditsAsync: creditsAsync,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.h3,
    );
  }
}

class _OldBookingCard extends StatelessWidget {
  const _OldBookingCard({
    required this.booking,
    required this.scheduleAsync,
    required this.classAsync,
  });

  final BookingModel booking;
  final AsyncValue<ScheduleModel?> scheduleAsync;
  final AsyncValue<YogaClassModel?> classAsync;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withAlpha(51),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.errorContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, size: 12, color: AppColors.onError),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      'WILL BE CANCELLED',
                      style: AppTypography.labelCaps.copyWith(color: AppColors.onError, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          classAsync.when(
            data: (yogaClass) => Text(yogaClass?.title ?? 'Class', style: AppTypography.h3),
            loading: () => Container(width: 120, height: 24, color: AppColors.surfaceContainerHigh),
            error: (_, _) => Text('Class', style: AppTypography.h3),
          ),
          const SizedBox(height: AppSpacing.sm),
          scheduleAsync.when(
            data: (schedule) {
              if (schedule == null) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.xs),
                      Text(_formatDate(schedule.date), style: AppTypography.bodyMd),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.xs),
                      Text('${schedule.startTime} - ${schedule.endTime}', style: AppTypography.bodyMd),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Icon(Icons.room_outlined, size: 16, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.xs),
                      Text(schedule.studioRoom, style: AppTypography.bodyMd),
                    ],
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

class _NewScheduleCard extends ConsumerWidget {
  const _NewScheduleCard({
    required this.schedule,
    required this.classAsync,
  });

  final ScheduleModel schedule;
  final AsyncValue<YogaClassModel?> classAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorAsync = classAsync.maybeWhen(
      data: (yogaClass) => yogaClass == null
          ? const AsyncValue<InstructorModel?>.data(null)
          : ref.watch(instructorByIdProvider(yogaClass.instructorId)),
      orElse: () => const AsyncValue<InstructorModel?>.loading(),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withAlpha(51),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.secondaryContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                    Icon(Icons.check, size: 12, color: AppColors.onPrimary),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      'NEW BOOKING',
                      style: AppTypography.labelCaps.copyWith(color: AppColors.onPrimary, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          classAsync.when(
            data: (yogaClass) => Text(yogaClass?.title ?? 'Class', style: AppTypography.h3),
            loading: () => Container(width: 120, height: 24, color: AppColors.surfaceContainerHigh),
            error: (_, _) => Text('Class', style: AppTypography.h3),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Text(_formatDate(schedule.date), style: AppTypography.bodyMd),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Text('${schedule.startTime} - ${schedule.endTime}', style: AppTypography.bodyMd),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              Icon(Icons.room_outlined, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Text(schedule.studioRoom, style: AppTypography.bodyMd),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          instructorAsync.when(
            data: (instructor) => Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Text('with ${instructor?.name ?? 'Instructor'}', style: AppTypography.bodyMd),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

class _CreditSummaryCard extends StatelessWidget {
  const _CreditSummaryCard({
    required this.oldClassAsync,
    required this.newClassAsync,
    required this.creditsAsync,
  });

  final AsyncValue<YogaClassModel?> oldClassAsync;
  final AsyncValue<YogaClassModel?> newClassAsync;
  final AsyncValue<int> creditsAsync;

  @override
  Widget build(BuildContext context) {
    return oldClassAsync.when(
      data: (oldClass) {
        return newClassAsync.when(
          data: (newClass) {
            if (oldClass == null || newClass == null) {
              return const SizedBox.shrink();
            }

            final oldCost = oldClass.creditCost;
            final newCost = newClass.creditCost;
            final difference = newCost - oldCost;

            return creditsAsync.when(
              data: (credits) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: Column(
                    children: [
                      // Old class credit
                      _CreditRow(
                        label: oldClass.title,
                        amount: -oldCost,
                        color: AppColors.error,
                      ),
                      const Divider(height: AppSpacing.lg),
                      // New class credit
                      _CreditRow(
                        label: newClass.title,
                        amount: difference > 0 ? -difference : 0,
                        color: difference > 0 ? AppColors.error : AppColors.onSurface,
                        isVisible: difference > 0,
                      ),
                      if (difference < 0) ...[
                        const Divider(height: AppSpacing.lg),
                        // Refund
                        _CreditRow(
                          label: 'Credit Refund',
                          amount: difference.abs(),
                          color: AppColors.primary,
                          isBold: true,
                        ),
                      ],
                      const Divider(height: AppSpacing.lg),
                      // Current balance after
                      _CreditRow(
                        label: 'New Balance',
                        amount: credits - (difference > 0 ? difference : 0),
                        color: credits >= (difference > 0 ? difference : 0)
                            ? AppColors.primary
                            : AppColors.error,
                        isBold: true,
                        isDivider: false,
                      ),
                      if (difference > 0 && credits < difference) ...[
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.onErrorContainer),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  'Insufficient credits. Need ${difference - credits} more.',
                                  style: AppTypography.bodySm.copyWith(color: AppColors.onErrorContainer),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SizedBox.shrink(),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({
    required this.label,
    required this.amount,
    required this.color,
    this.isBold = false,
    this.isVisible = true,
    this.isDivider = true,
  });

  final String label;
  final int amount;
  final Color color;
  final bool isBold;
  final bool isVisible;
  final bool isDivider;

  @override
  Widget build(BuildContext context) {
    if (!isVisible && amount == 0) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: isBold
                  ? AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)
                  : AppTypography.bodyMd,
            ),
            Text(
              amount >= 0 ? '+$amount' : '$amount',
              style: (isBold
                      ? AppTypography.h3.copyWith(fontWeight: FontWeight.w600)
                      : AppTypography.bodyMd)
                  .copyWith(color: color),
            ),
          ],
        ),
      ],
    );
  }
}

class _RescheduleBottomCTA extends StatelessWidget {
  const _RescheduleBottomCTA({
    required this.isRescheduling,
    required this.onConfirm,
    required this.oldClassAsync,
    required this.newClassAsync,
    required this.creditsAsync,
  });

  final bool isRescheduling;
  final VoidCallback onConfirm;
  final AsyncValue<YogaClassModel?> oldClassAsync;
  final AsyncValue<YogaClassModel?> newClassAsync;
  final AsyncValue<int> creditsAsync;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.surfaceVariant)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: oldClassAsync.when(
          data: (oldClass) {
            return newClassAsync.when(
              data: (newClass) {
                if (oldClass == null || newClass == null) {
                  return AppButton(
                    label: 'Unable to reschedule',
                    onPressed: null,
                    isExpanded: true,
                  );
                }

                final difference = newClass.creditCost - oldClass.creditCost;

                return creditsAsync.when(
                  data: (credits) {
                    final canReschedule = difference <= 0 || credits >= difference;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppButton(
                          label: isRescheduling
                              ? 'Rescheduling...'
                              : 'Confirm Reschedule',
                          onPressed: canReschedule && !isRescheduling
                              ? onConfirm
                              : null,
                          isLoading: isRescheduling,
                          isExpanded: true,
                        ),
                        if (!canReschedule) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Insufficient credits to reschedule',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => AppButton(
                    label: 'Loading...',
                    onPressed: null,
                    isExpanded: true,
                  ),
                  error: (_, _) => AppButton(
                    label: 'Unable to check credits',
                    onPressed: null,
                    isExpanded: true,
                  ),
                );
              },
              loading: () => AppButton(
                label: 'Loading...',
                onPressed: null,
                isExpanded: true,
              ),
              error: (_, _) => AppButton(
                label: 'Unable to load new class',
                onPressed: null,
                isExpanded: true,
              ),
            );
          },
          loading: () => AppButton(
            label: 'Loading...',
            onPressed: null,
            isExpanded: true,
          ),
          error: (_, _) => AppButton(
            label: 'Unable to load class',
            onPressed: null,
            isExpanded: true,
          ),
        ),
      ),
    );
  }
}

// Helper provider for getting booking after reschedule
final bookingByIdProviderFuture = FutureProvider.family<BookingModel?, String>((
  ref,
  id,
) async {
  // Small delay to allow database to update
  await Future.delayed(const Duration(milliseconds: 500));
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getBookingById(id);
});

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Reschedule'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.onSurfaceVariant.withAlpha(128),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                message ?? 'Unable to reschedule',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Go Back',
                onPressed: () => context.pop(),
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
