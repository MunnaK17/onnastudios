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
import '../../../data/models/booking_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/yoga_class_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../../shared/widgets/dialogs/app_confirmation_dialog.dart';
import '../../../shared/widgets/state/app_state_widgets.dart';

enum BookingFilter { all, upcoming, completed, cancelled }

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              const _HeaderSection(),
              const SizedBox(height: AppSpacing.xl),
              const _FilterTabs(),
              const SizedBox(height: AppSpacing.lg),
              const _BookingsSection(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.profile);
              }
            },
            icon: const Icon(Icons.arrow_back),
            color: AppColors.onSurface,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking History', style: AppTypography.h2),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Review your past sessions and upcoming reservations.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
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

class _FilterTabs extends StatelessWidget {
  const _FilterTabs();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                isSelected:
                    ref.watch(_filterStateProvider) == BookingFilter.all,
                onTap: () => ref
                    .read(_filterStateProvider.notifier)
                    .setFilter(BookingFilter.all),
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Upcoming',
                isSelected:
                    ref.watch(_filterStateProvider) == BookingFilter.upcoming,
                onTap: () => ref
                    .read(_filterStateProvider.notifier)
                    .setFilter(BookingFilter.upcoming),
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Completed',
                isSelected:
                    ref.watch(_filterStateProvider) == BookingFilter.completed,
                onTap: () => ref
                    .read(_filterStateProvider.notifier)
                    .setFilter(BookingFilter.completed),
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Cancelled',
                isSelected:
                    ref.watch(_filterStateProvider) == BookingFilter.cancelled,
                onTap: () => ref
                    .read(_filterStateProvider.notifier)
                    .setFilter(BookingFilter.cancelled),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primaryContainer
          : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryContainer
                  : AppColors.surfaceVariant,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelCaps.copyWith(
              color: isSelected
                  ? AppColors.onPrimaryContainer
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingFilterNotifier extends Notifier<BookingFilter> {
  @override
  BookingFilter build() => BookingFilter.all;

  void setFilter(BookingFilter filter) {
    state = filter;
  }
}

final _filterStateProvider =
    NotifierProvider<_BookingFilterNotifier, BookingFilter>(() {
      return _BookingFilterNotifier();
    });

class _BookingsSection extends ConsumerWidget {
  const _BookingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(userBookingsProvider);
    final schedulesAsync = ref.watch(allSchedulesProvider);
    final filter = ref.watch(_filterStateProvider);

    return bookingsAsync.when(
      data: (bookings) {
        final schedules = schedulesAsync.when(
          data: (s) => s,
          loading: () => <ScheduleModel>[],
          error: (e, s) => <ScheduleModel>[],
        );

        final filtered = _filterBookings(bookings, schedules, filter);
        if (filtered.isEmpty) {
          return _EmptyBookings(filter: filter);
        }
        return Column(
          children: filtered.asMap().entries.map((entry) {
            final index = entry.key;
            final booking = entry.value;
            final isLast = index == filtered.length - 1;
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.screenPadding,
                right: AppSpacing.screenPadding,
                bottom: isLast ? 0 : AppSpacing.md,
              ),
              child: _BookingCard(booking: booking),
            );
          }).toList(),
        );
      },
      loading: () => const AppLoadingState(),
      error: (e, _) => AppErrorState(
        onRetry: () => ref.invalidate(userBookingsProvider),
      ),
    );
  }

  List<BookingModel> _filterBookings(
    List<BookingModel> bookings,
    List<ScheduleModel> schedules,
    BookingFilter filter,
  ) {
    // Create a map of scheduleId -> schedule for quick lookup
    final scheduleMap = {for (var s in schedules) s.id: s};

    return bookings.where((b) {
      final schedule = scheduleMap[b.scheduleId];

      switch (filter) {
        case BookingFilter.all:
          return true;
        case BookingFilter.upcoming:
          // Hide if schedule is expired (30 min after start time)
          if (schedule != null && schedule.isExpired) {
            return false;
          }
          return b.status == BookingStatus.upcoming;
        case BookingFilter.completed:
          return b.status == BookingStatus.completed;
        case BookingFilter.cancelled:
          return b.status == BookingStatus.cancelled;
      }
    }).toList();
  }
}

class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classAsync = ref.watch(classByIdProvider(booking.classId));

    return classAsync.when(
      data: (yogaClass) {
        if (yogaClass == null) return const SizedBox.shrink();
        // Fetch schedule to check if expired
        final scheduleAsync = ref.watch(scheduleByIdProvider(booking.scheduleId));
        return scheduleAsync.when(
          data: (schedule) {
            // If schedule is expired and booking is still upcoming, don't show card
            if (schedule != null && schedule.isExpired && booking.status == BookingStatus.upcoming) {
              return const SizedBox.shrink();
            }
            return _BookingCardContent(
              booking: booking,
              yogaClass: yogaClass,
              schedule: schedule,
            );
          },
          loading: () => _BookingCardContent(
            booking: booking,
            yogaClass: yogaClass,
            schedule: null,
          ),
          error: (e, _) => _BookingCardContent(
            booking: booking,
            yogaClass: yogaClass,
            schedule: null,
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

class _BookingCardContent extends ConsumerStatefulWidget {
  const _BookingCardContent({
    required this.booking,
    required this.yogaClass,
    required this.schedule,
  });

  final BookingModel booking;
  final YogaClassModel yogaClass;
  final ScheduleModel? schedule;

  @override
  ConsumerState<_BookingCardContent> createState() =>
      _BookingCardContentState();
}

class _BookingCardContentState extends ConsumerState<_BookingCardContent> {
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final yogaClass = widget.yogaClass;
    final schedule = widget.schedule;
    final instructorAsync = ref.watch(
      instructorByIdProvider(yogaClass.instructorId),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.spa_outlined,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (schedule != null) ...[
                      Row(
                        children: [
                          Text(
                            _formatDate(schedule.date),
                            style: AppTypography.labelCaps.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text('•', style: AppTypography.labelCaps.copyWith(
                            color: AppColors.onSurfaceVariant,
                          )),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            schedule.startTime,
                            style: AppTypography.labelCaps.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                    ],
                    Text(
                      yogaClass.title,
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getTitleColor(booking.status),
                        decoration: booking.status == BookingStatus.cancelled
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    instructorAsync.when(
                      data: (instructor) => Row(
                        children: [
                          Icon(Icons.person_outline, size: 14,
                              color: AppColors.onSurfaceVariant),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            instructor?.name ?? 'Unknown',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (e, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (schedule != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _DetailChip(icon: Icons.access_time, label: '${yogaClass.durationMinutes} min'),
                const SizedBox(width: AppSpacing.sm),
                _DetailChip(icon: Icons.room_outlined, label: schedule.studioRoom),
                const SizedBox(width: AppSpacing.sm),
                _DetailChip(icon: Icons.monetization_on_outlined, label: '${yogaClass.creditCost} credit'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Row(children: [_StatusBadge(status: booking.status)]),
          if (booking.status == BookingStatus.upcoming) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'View QR',
                    icon: Icons.qr_code_2,
                    variant: _ActionVariant.outline,
                    onTap: _isCancelling
                        ? null
                        : () => context.go(
                            AppRoutes.bookingConfirmationPath(bookingId: booking.id),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionButton(
                    label: 'Reschedule',
                    icon: Icons.swap_horiz,
                    variant: _ActionVariant.outline,
                    onTap: () {
                      context.push(
                        Uri(
                          path: '/schedule/select/${booking.classId}',
                          queryParameters: {'bookingId': booking.id},
                        ).toString(),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionButton(
                    label: 'Cancel',
                    icon: Icons.close,
                    variant: _ActionVariant.destructive,
                    isLoading: _isCancelling,
                    onTap: _isCancelling ? null : _confirmCancellation,
                  ),
                ),
              ],
            ),
          ] else if (booking.status == BookingStatus.completed) ...[
            const SizedBox(height: AppSpacing.md),
            _ActionButton(
              label: 'Book Again',
              icon: Icons.refresh,
              variant: _ActionVariant.outline,
              onTap: () => context.go(AppRoutes.classDetailPath(booking.classId)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmCancellation() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Cancel this booking?',
      message: '${widget.yogaClass.creditCost} credit will be returned to your wallet.',
      confirmLabel: 'Cancel Booking',
      icon: Icons.event_busy_outlined,
    );

    if (!confirmed || !mounted) return;

    setState(() => _isCancelling = true);
    try {
      await ref
          .read(bookingNotifierProvider.notifier)
          .cancelBooking(
            bookingId: widget.booking.id,
            scheduleId: widget.booking.scheduleId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking cancelled. ${widget.yogaClass.creditCost} credit returned.'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to cancel booking. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Color _getTitleColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.cancelled:
        return AppColors.outline;
      default:
        return AppColors.onSurface;
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

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
          Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(
            child: Text(
              label,
              style: AppTypography.labelCaps.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bgColor, textColor) = switch (status) {
      BookingStatus.upcoming => ('Upcoming', AppColors.secondaryContainer, AppColors.onSecondaryContainer),
      BookingStatus.completed => ('Completed', AppColors.surfaceVariant, AppColors.onSurfaceVariant),
      BookingStatus.cancelled => ('Canceled', AppColors.errorContainer.withAlpha(128), AppColors.onErrorContainer),
      BookingStatus.expired => ('Expired', AppColors.surfaceContainerHigh, AppColors.onSurfaceVariant),
      BookingStatus.noShow => ('No Show', AppColors.errorContainer, AppColors.onErrorContainer),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: AppTypography.labelCaps.copyWith(color: textColor)),
    );
  }
}

enum _ActionVariant { primary, outline, destructive }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.variant,
    required this.onTap,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final _ActionVariant variant;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: variant == _ActionVariant.primary
          ? AppColors.primary
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: switch (variant) {
              _ActionVariant.outline => Border.all(color: AppColors.outline),
              _ActionVariant.destructive => Border.all(color: AppColors.error),
              _ActionVariant.primary => null,
            },
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox.square(dimension: AppSpacing.md, child: CircularProgressIndicator(strokeWidth: 2))
              else if (icon != null)
                Icon(icon, size: AppSpacing.md),
              if (isLoading || icon != null)
                const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelCaps.copyWith(
                    color: switch (variant) {
                      _ActionVariant.primary => AppColors.onPrimary,
                      _ActionVariant.outline => AppColors.onSurface,
                      _ActionVariant.destructive => AppColors.error,
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings({required this.filter});

  final BookingFilter filter;

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      BookingFilter.all => 'No bookings yet',
      BookingFilter.upcoming => 'No upcoming bookings',
      BookingFilter.completed => 'No completed bookings',
      BookingFilter.cancelled => 'No cancelled bookings',
    };

    final subtitle = switch (filter) {
      BookingFilter.all => 'Start exploring our classes to book your first session.',
      _ => 'This list is currently empty.',
    };

    return AppEmptyState(
      icon: Icons.calendar_today_outlined,
      title: message,
      subtitle: subtitle,
    );
  }
}
