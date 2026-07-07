import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_error_message.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/yoga_class_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../../shared/widgets/buttons/app_button.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({this.scheduleId, this.classId, super.key});

  final String? scheduleId;
  final String? classId;

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  bool _isBooking = false;

  /// Low credit threshold - notify user when credits fall below this
  static const int _lowCreditThreshold = 5;

  Future<void> _confirmBooking(YogaClassModel yogaClass) async {
    setState(() {
      _isBooking = true;
    });

    try {
      // Use scheduleId if available, otherwise get first available schedule for class
      String actualScheduleId = widget.scheduleId ?? '';
      final upcomingBookings = await ref.read(upcomingBookingsProvider.future);

      if (actualScheduleId.isEmpty) {
        // Find available schedule for this class
        final schedules = await ref.read(allSchedulesProvider.future);
        final availableSchedule = schedules
            .where(
              (s) =>
                  s.classId == yogaClass.id &&
                  s.availableSlots > 0 &&
                  !upcomingBookings.any((b) => b.scheduleId == s.id),
            )
            .firstOrNull;

        if (availableSchedule != null) {
          actualScheduleId = availableSchedule.id;
        }
      } else {
        if (upcomingBookings.any((b) => b.scheduleId == actualScheduleId)) {
          throw Exception('You already booked this schedule.');
        }

        final schedule = await ref.read(
          scheduleByIdProvider(actualScheduleId).future,
        );
        if (schedule == null || schedule.availableSlots <= 0) {
          throw Exception('This class is already full.');
        }
      }

      if (actualScheduleId.isEmpty) {
        throw Exception('No available schedule for this class');
      }

      final booking = await ref
          .read(bookingNotifierProvider.notifier)
          .createBooking(
            scheduleId: actualScheduleId,
            classId: widget.classId ?? yogaClass.id,
          );

      // Create notification for successful booking
      await ref.read(notificationNotifierProvider.notifier).createBookingConfirmedNotification(
        className: yogaClass.title,
      );

      // Check credit balance after booking and notify if low
      await _checkAndNotifyLowCredits();

      ref.invalidate(remainingCreditsProvider);
      ref.invalidate(walletSummaryProvider);
      ref.invalidate(transactionHistoryProvider);
      ref.invalidate(walletNotifierProvider);
      ref.invalidate(userBookingsProvider);
      ref.invalidate(upcomingBookingsProvider);
      ref.invalidate(allSchedulesProvider);
      ref.invalidate(availableSchedulesProvider);
      ref.invalidate(schedulesByClassIdProvider(yogaClass.id));
      ref.invalidate(scheduleByIdProvider(actualScheduleId));
      ref.invalidate(unreadCountProvider);
      ref.invalidate(notificationNotifierProvider);

      // Navigate to confirmation
      if (mounted) {
        context.pushReplacement(
          AppRoutes.bookingConfirmationPath(bookingId: booking.id),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appErrorMessage(
                e,
                fallback:
                    'This class could not be booked. Please try another schedule or refresh availability.',
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  /// Check credit balance after booking and create notification if low.
  Future<void> _checkAndNotifyLowCredits() async {
    try {
      final remainingCredits = await ref.read(remainingCreditsProvider.future);

      if (remainingCredits == 0) {
        // Create depleted notification
        await ref.read(notificationNotifierProvider.notifier).createCreditDepletedNotification();
      } else if (remainingCredits <= _lowCreditThreshold) {
        // Create low credit warning notification
        await ref.read(notificationNotifierProvider.notifier).createCreditLowNotification(
          remainingCredits: remainingCredits,
        );
      }
    } catch (e) {
      // Silently fail - notification is not critical
      debugPrint('Failed to check/create low credit notification: $e');
    }
  }

  void _showConfirmationSheet(YogaClassModel yogaClass) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ConfirmationSheet(
        yogaClass: yogaClass,
        scheduleId: widget.scheduleId,
        onConfirm: () {
          Navigator.pop(context);
          _confirmBooking(yogaClass);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classId = widget.classId;
    final scheduleId = widget.scheduleId;

    // Must have at least classId
    if (classId == null) {
      return const _NotFoundScreen(message: 'Class not specified');
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Book Class'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Class Summary
                  _ClassSummarySection(classId: classId),
                  const SizedBox(height: AppSpacing.xl),
                  // Schedule Info
                  if (scheduleId != null)
                    _ScheduleInfoSection(scheduleId: scheduleId),
                  const SizedBox(height: AppSpacing.xl),
                  // Credit Summary
                  _CreditSummarySection(classId: classId),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
          // Bottom CTA
          _BottomCTA(
            classId: classId,
            scheduleId: scheduleId,
            onBook: _showConfirmationSheet,
            isBooking: _isBooking,
          ),
        ],
      ),
    );
  }
}

class _ClassSummarySection extends ConsumerWidget {
  const _ClassSummarySection({required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classAsync = ref.watch(classByIdProvider(classId));

    return classAsync.when(
      data: (yogaClass) {
        if (yogaClass == null) {
          return const _InfoCard(child: Text('Class not found'));
        }

        final instructorAsync = ref.watch(
          instructorByIdProvider(yogaClass.instructorId),
        );

        return _InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Class',
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(yogaClass.title, style: AppTypography.h2),
              const SizedBox(height: AppSpacing.md),
              // Category & Duration
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _SmallChip(
                    label: _formatCategory(yogaClass.category),
                    color: AppColors.secondaryContainer,
                    textColor: AppColors.onSecondaryContainer,
                  ),
                  _SmallChip(
                    label: '${yogaClass.durationMinutes} min',
                    icon: Icons.schedule,
                  ),
                  _SmallChip(
                    label: '${yogaClass.creditCost} Credits',
                    icon: Icons.monetization_on_outlined,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Instructor
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.onSurfaceVariant.withAlpha(128),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
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
                        instructorAsync.when(
                          data: (instructor) => Text(
                            instructor?.name ?? 'Instructor',
                            style: AppTypography.h3,
                          ),
                          loading: () => Container(
                            width: 120,
                            height: 20,
                            color: AppColors.surfaceContainerHigh,
                          ),
                          error: (_, _) =>
                              Text('Instructor', style: AppTypography.h3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () =>
          const _InfoCard(child: Center(child: CircularProgressIndicator())),
      error: (_, _) => const _InfoCard(child: Text('Failed to load class')),
    );
  }

  String _formatCategory(dynamic category) {
    final name = category.toString().split('.').last;
    switch (name) {
      case 'yogaFlow':
        return 'Yoga Flow';
      case 'pilates':
        return 'Pilates';
      case 'meditation':
        return 'Meditation';
      case 'breathwork':
        return 'Breathwork';
      case 'strength':
        return 'Strength';
      case 'restorative':
        return 'Restorative';
      default:
        return name;
    }
  }
}

class _ScheduleInfoSection extends ConsumerWidget {
  const _ScheduleInfoSection({required this.scheduleId});

  final String scheduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get schedule from all schedules provider
    final schedulesAsync = ref.watch(allSchedulesProvider);

    return schedulesAsync.when(
      data: (schedules) {
        final schedule = schedules.where((s) => s.id == scheduleId).firstOrNull;

        if (schedule == null) {
          return const SizedBox.shrink();
        }

        // Check if schedule is in the past
        final isPast = schedule.isPast;

        return _InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Session',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (isPast)
                    Container(
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
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _ScheduleInfoItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: _formatDate(schedule.date),
                    ),
                  ),
                  Expanded(
                    child: _ScheduleInfoItem(
                      icon: Icons.schedule,
                      label: 'Time',
                      value: '${schedule.startTime} - ${schedule.endTime}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _ScheduleInfoItem(
                icon: Icons.location_on_outlined,
                label: 'Room',
                value: schedule.studioRoom,
              ),
              const SizedBox(height: AppSpacing.md),
              _ScheduleInfoItem(
                icon: Icons.event_seat_outlined,
                label: 'Availability',
                value: isPast
                    ? 'Class has ended'
                    : (schedule.availableSlots > 0
                        ? '${schedule.availableSlots} spots left'
                        : 'Full - Waitlist only'),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const _InfoCard(child: Center(child: CircularProgressIndicator())),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    }

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

class _ScheduleInfoItem extends StatelessWidget {
  const _ScheduleInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelCaps.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(value, style: AppTypography.bodyMd),
          ],
        ),
      ],
    );
  }
}

class _CreditSummarySection extends ConsumerWidget {
  const _CreditSummarySection({required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classAsync = ref.watch(classByIdProvider(classId));
    final creditsAsync = ref.watch(remainingCreditsProvider);

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Credits',
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          creditsAsync.when(
            data: (remainingCredits) {
              return classAsync.when(
                data: (yogaClass) {
                  final creditCost = yogaClass?.creditCost ?? 0;
                  final hasEnoughCredits = remainingCredits >= creditCost;

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Current Balance', style: AppTypography.bodyLg),
                          Text(
                            '$remainingCredits Credits',
                            style: AppTypography.h3,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(51),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.remove,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              '$creditCost Credit - Class Cost',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remaining Balance',
                              style: AppTypography.labelCaps.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${remainingCredits - creditCost} Credits',
                              style: AppTypography.h2.copyWith(
                                color: hasEnoughCredits
                                    ? AppColors.secondary
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!hasEnoughCredits) ...[
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.onErrorContainer,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Insufficient credits. Please contact the studio.',
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Text(
                  'Failed to load class info',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.error),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Text(
              'Failed to load credit balance',
              style: AppTypography.bodyMd.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCTA extends ConsumerWidget {
  const _BottomCTA({
    required this.classId,
    required this.scheduleId,
    required this.onBook,
    required this.isBooking,
  });

  final String classId;
  final String? scheduleId;
  final void Function(YogaClassModel) onBook;
  final bool isBooking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classAsync = ref.watch(classByIdProvider(classId));
    final creditsAsync = ref.watch(remainingCreditsProvider);
    final scheduleAsync = scheduleId == null
        ? ref.watch(schedulesByClassIdProvider(classId))
        : ref.watch(scheduleByIdProvider(scheduleId!));
    final bookingsAsync = ref.watch(upcomingBookingsProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.surfaceVariant)),
        boxShadow: AppShadows.subtle,
      ),
      child: SafeArea(
        top: false,
        child: classAsync.when(
          data: (yogaClass) {
            if (yogaClass == null) {
              return AppButton(
                label: 'Class Not Available',
                onPressed: null,
                isExpanded: true,
              );
            }

            return creditsAsync.when(
              data: (remainingCredits) {
                final hasEnoughCredits =
                    remainingCredits >= yogaClass.creditCost;

                if (!hasEnoughCredits) {
                  return AppButton(
                    label: 'Not Enough Credits',
                    onPressed: null,
                    isExpanded: true,
                  );
                }

                return scheduleAsync.when(
                  data: (scheduleData) {
                    // Check if schedule is in the past
                    final ScheduleModel? schedule;
                    final bool isPast;
                    final List<ScheduleModel> scheduleList;

                    if (scheduleId == null) {
                      scheduleList = scheduleData as List<ScheduleModel>;
                      schedule = null;
                      isPast = false;
                    } else {
                      schedule = scheduleData as ScheduleModel;
                      scheduleList = [];
                      isPast = schedule.isPast;
                    }

                    // If schedule is in the past, show "Class Ended" button
                    if (isPast) {
                      return AppButton(
                        label: 'Class Ended',
                        onPressed: null,
                        isExpanded: true,
                        variant: AppButtonVariant.secondary,
                      );
                    }

                    final hasAvailableSchedule = scheduleId == null
                        ? scheduleList.any((s) => s.availableSlots > 0)
                        : schedule != null && schedule.availableSlots > 0;

                    if (!hasAvailableSchedule) {
                      return AppButton(
                        label: 'Class Full',
                        onPressed: null,
                        isExpanded: true,
                      );
                    }

                    return bookingsAsync.when(
                      data: (bookings) {
                        final isAlreadyBooked = scheduleId == null
                            ? scheduleList
                                .where((s) => s.availableSlots > 0)
                                .every(
                                  (s) => bookings.any(
                                    (b) => b.scheduleId == s.id,
                                  ),
                                )
                            : bookings.any((b) => b.scheduleId == scheduleId);

                        if (isAlreadyBooked) {
                          return AppButton(
                            label: 'Already Booked',
                            onPressed: null,
                            isExpanded: true,
                          );
                        }

                        return AppButton(
                          label: isBooking ? 'Booking...' : 'Confirm Booking',
                          onPressed: isBooking ? null : () => onBook(yogaClass),
                          isLoading: isBooking,
                          isExpanded: true,
                        );
                      },
                      loading: () => AppButton(
                        label: 'Checking...',
                        onPressed: null,
                        isExpanded: true,
                      ),
                      error: (_, _) => AppButton(
                        label: isBooking ? 'Booking...' : 'Confirm Booking',
                        onPressed: isBooking ? null : () => onBook(yogaClass),
                        isLoading: isBooking,
                        isExpanded: true,
                      ),
                    );
                  },
                  loading: () => AppButton(
                    label: 'Checking...',
                    onPressed: null,
                    isExpanded: true,
                  ),
                  error: (_, _) => AppButton(
                    label: 'Schedule Not Available',
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
                label: 'Failed to load',
                onPressed: null,
                isExpanded: true,
              ),
            );
          },
          loading: () =>
              AppButton(label: 'Loading...', onPressed: null, isExpanded: true),
          error: (_, _) => AppButton(
            label: 'Class Not Available',
            onPressed: null,
            isExpanded: true,
          ),
        ),
      ),
    );
  }
}

class _ConfirmationSheet extends StatelessWidget {
  const _ConfirmationSheet({
    required this.yogaClass,
    required this.scheduleId,
    required this.onConfirm,
  });

  final YogaClassModel yogaClass;
  final String? scheduleId;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 32,
                color: AppColors.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Title
            Text('Confirm Your Booking', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.md),
            // Details
            Text('You are about to book:', style: AppTypography.bodyMd),
            const SizedBox(height: AppSpacing.sm),
            Text(
              yogaClass.title,
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${yogaClass.creditCost} Credits',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Navigator.pop(context),
                    isExpanded: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Confirm',
                    onPressed: onConfirm,
                    isExpanded: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: AppShadows.ambient,
      ),
      child: child,
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({
    required this.label,
    this.icon,
    this.color,
    this.textColor,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: textColor ?? AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: textColor ?? AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

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
        title: const Text('Booking'),
        centerTitle: true,
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
                message ?? 'Class Not Found',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Browse Classes',
                onPressed: () => context.go(AppRoutes.classes),
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
