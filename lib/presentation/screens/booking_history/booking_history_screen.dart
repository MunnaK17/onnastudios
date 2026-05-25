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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Header
            const _HeaderSection(),
            const SizedBox(height: AppSpacing.xl),
            // Filter Tabs
            const _FilterTabs(),
            const SizedBox(height: AppSpacing.lg),
            // Bookings List
            const _BookingsSection(),
            const SizedBox(height: AppSpacing.lg),
          ],
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
    final filter = ref.watch(_filterStateProvider);

    return bookingsAsync.when(
      data: (bookings) {
        final filtered = _filterBookings(bookings, filter);
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
      loading: () => const _LoadingBookings(),
      error: (e, st) => const _ErrorBookings(),
    );
  }

  List<BookingModel> _filterBookings(
    List<BookingModel> bookings,
    BookingFilter filter,
  ) {
    return bookings.where((b) {
      switch (filter) {
        case BookingFilter.all:
          return true;
        case BookingFilter.upcoming:
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
    final scheduleAsync = ref.watch(scheduleByIdProvider(booking.scheduleId));

    return classAsync.when(
      data: (yogaClass) {
        if (yogaClass == null) return const SizedBox.shrink();
        return scheduleAsync.when(
          data: (schedule) => _BookingCardContent(
            booking: booking,
            yogaClass: yogaClass,
            schedule: schedule,
          ),
          loading: () => _BookingCardContent(
            booking: booking,
            yogaClass: yogaClass,
            schedule: null,
          ),
          error: (e, st) => _BookingCardContent(
            booking: booking,
            yogaClass: yogaClass,
            schedule: null,
          ),
        );
      },
      loading: () => const _LoadingBookingCard(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}

class _BookingCardContent extends ConsumerWidget {
  const _BookingCardContent({
    required this.booking,
    required this.yogaClass,
    required this.schedule,
  });

  final BookingModel booking;
  final YogaClassModel yogaClass;
  final ScheduleModel? schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          // Class Image and Status
          Row(
            children: [
              // Class Image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.network(
                    yogaClass.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceContainerHigh,
                        child: Icon(
                          Icons.spa_outlined,
                          color: AppColors.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Class Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Status Row
                    Row(
                      children: [
                        if (schedule != null) ...[
                          Text(
                            _formatDate(schedule!.date),
                            style: AppTypography.labelCaps.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '•',
                            style: AppTypography.labelCaps.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            schedule!.startTime,
                            style: AppTypography.labelCaps.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    // Title
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
                    // Instructor
                    instructorAsync.when(
                      data: (instructor) => Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
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
                      error: (e, st) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Details Row
          if (schedule != null) ...[
            Row(
              children: [
                _DetailChip(
                  icon: Icons.access_time,
                  label: '${yogaClass.durationMinutes} min',
                ),
                const SizedBox(width: AppSpacing.sm),
                _DetailChip(
                  icon: Icons.room_outlined,
                  label: schedule!.studioRoom,
                ),
                const SizedBox(width: AppSpacing.sm),
                _DetailChip(
                  icon: Icons.monetization_on_outlined,
                  label: '${yogaClass.creditCost} credit',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          // Status and Actions Row
          Row(
            children: [
              // Status Badge
              _StatusBadge(status: booking.status),
              const Spacer(),
              // Actions
              if (booking.status == BookingStatus.upcoming) ...[
                _ActionButton(
                  label: 'View QR',
                  variant: _ActionVariant.outline,
                  onTap: () => context.go(
                    '${AppRoutes.bookingConfirmation}?bookingId=${booking.id}',
                  ),
                ),
              ] else if (booking.status == BookingStatus.completed) ...[
                _ActionButton(
                  label: 'Book Again',
                  variant: _ActionVariant.outline,
                  onTap: () =>
                      context.go('${AppRoutes.classDetail}/${booking.classId}'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getTitleColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.cancelled:
        return AppColors.outline;
      case BookingStatus.completed:
        return AppColors.onSurface;
      case BookingStatus.upcoming:
      case BookingStatus.expired:
        return AppColors.onSurface;
    }
  }

  String _formatDate(DateTime date) {
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
      BookingStatus.upcoming => (
        'Upcoming',
        AppColors.secondaryContainer,
        AppColors.onSecondaryContainer,
      ),
      BookingStatus.completed => (
        'Completed',
        AppColors.surfaceVariant,
        AppColors.onSurfaceVariant,
      ),
      BookingStatus.cancelled => (
        'Canceled',
        AppColors.errorContainer.withAlpha(128),
        AppColors.onErrorContainer,
      ),
      BookingStatus.expired => (
        'Expired',
        AppColors.surfaceContainerHigh,
        AppColors.onSurfaceVariant,
      ),
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
      child: Text(
        label,
        style: AppTypography.labelCaps.copyWith(color: textColor),
      ),
    );
  }
}

enum _ActionVariant { primary, outline }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.variant,
    required this.onTap,
  });

  final String label;
  final _ActionVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: variant == _ActionVariant.primary
          ? AppColors.primary
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: variant == _ActionVariant.outline
                ? Border.all(color: AppColors.outline)
                : null,
          ),
          child: Text(
            label,
            style: AppTypography.labelCaps.copyWith(
              color: variant == _ActionVariant.primary
                  ? AppColors.onPrimary
                  : AppColors.onSurface,
            ),
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
      BookingFilter.all =>
        'Start exploring our classes to book your first session.',
      _ => 'This list is currently empty.',
    };

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: AppColors.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant.withAlpha(179),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBookings extends StatelessWidget {
  const _LoadingBookings();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index < 2 ? AppSpacing.md : 0),
            child: const _LoadingBookingCard(),
          ),
        ),
      ),
    );
  }
}

class _LoadingBookingCard extends StatelessWidget {
  const _LoadingBookingCard();

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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
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

class _ErrorBookings extends StatelessWidget {
  const _ErrorBookings();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Unable to load bookings',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
