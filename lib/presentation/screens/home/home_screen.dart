import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/mood_extensions.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/app_enums.dart';
import '../../../data/models/yoga_class_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/mood_entry_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/mood_provider.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/layout/section_header.dart';
import '../../../shared/widgets/state/app_state_widgets.dart';
import '../../../shared/widgets/images/optimized_image.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            const _GreetingSection(),
            const SizedBox(height: AppSpacing.xl),
            const _MoodQuickCheckSection(),
            const SizedBox(height: AppSpacing.xl),
            const _HeroSection(),
            const SizedBox(height: AppSpacing.xxl),
            const _CreditSummarySection(),
            const SizedBox(height: AppSpacing.xxl),
            const _UpcomingBookingSection(),
            const SizedBox(height: AppSpacing.xxl),
            const _FeaturedClassesSection(),
            const SizedBox(height: AppSpacing.xxl),
            const _QuickActionsSection(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _GreetingSection extends ConsumerWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final greeting = _getGreeting();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting,',
            style: AppTypography.bodyLg.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          userAsync.when(
            data: (user) =>
                Text(user?.fullName ?? 'Member', style: AppTypography.h1),
            loading: () => Text('Member', style: AppTypography.h1),
            error: (e, _) => Text('Member', style: AppTypography.h1),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Find your center today.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

class _MoodQuickCheckSection extends ConsumerWidget {
  const _MoodQuickCheckSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMoodAsync = ref.watch(todayMoodEntryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: todayMoodAsync.when(
        data: (mood) {
          if (mood == null) {
            return _NoMoodCard();
          }
          return _TodayMoodMiniCard(mood: mood);
        },
        loading: () => const _MoodCardLoading(),
        error: (_, _) => _NoMoodCard(),
      ),
    );
  }
}

class _NoMoodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.moodTracker),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF735A3A), // Warm brown/terracotta base
              Color(0xFF8B6914), // Gold accent
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
                color: Colors.white.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.mood_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How are you feeling?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Track your mood for personalized recommendations',
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayMoodMiniCard extends StatelessWidget {
  const _TodayMoodMiniCard({required this.mood});

  final MoodEntryModel mood;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.moodTracker),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.surfaceVariant),
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withAlpha(77),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Text(
                  mood.mood.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's mood: ${mood.mood.label}",
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Tap to update your mood',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: AppColors.onSecondaryContainer,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    'Update',
                    style: AppTypography.labelCaps.copyWith(
                      fontSize: 10,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodCardLoading extends StatelessWidget {
  const _MoodCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 16,
                  color: AppColors.surfaceContainerLow,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 200,
                  height: 12,
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

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: AppCard(
        padding: EdgeInsets.zero,
        shadow: AppCardShadow.ambient,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: OptimizedImage(
                      imageUrl: 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?w=800',
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.card),
                      ),
                      errorPlaceholder: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.secondaryContainer.withAlpha(128),
                              AppColors.tertiaryContainer.withAlpha(128),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.self_improvement,
                                size: 64,
                                color: AppColors.onSurfaceVariant.withAlpha(128),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Your sanctuary awaits',
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant.withAlpha(179),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                  Text('Start Your Practice', style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Book a class and discover your inner balance.',
                    style: AppTypography.bodyMd,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Book a Class',
                    onPressed: () => context.go(AppRoutes.schedule),
                    isExpanded: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditSummarySection extends ConsumerWidget {
  const _CreditSummarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Your Credits',
            actionText: 'View Wallet',
            onActionPressed: () => context.push(AppRoutes.wallet),
          ),
          const SizedBox(height: AppSpacing.md),
          walletAsync.when(
            data: (wallet) => AppCard(
              shadow: AppCardShadow.subtle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${wallet.remainingCredits}',
                        style: AppTypography.h2,
                      ),
                      Text('Credits Available', style: AppTypography.bodyMd),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: wallet.hasEnoughCredits
                          ? AppColors.secondaryContainer
                          : AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      wallet.hasEnoughCredits ? 'Active' : 'Low',
                      style: AppTypography.labelCaps.copyWith(
                        color: wallet.hasEnoughCredits
                            ? AppColors.onSecondaryContainer
                            : AppColors.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const _LoadingCreditCard(),
            error: (e, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _LoadingCreditCard extends StatelessWidget {
  const _LoadingCreditCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      shadow: AppCardShadow.subtle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(width: 60, height: 36),
              const SizedBox(height: AppSpacing.xs),
              _ShimmerBox(width: 100, height: 16),
            ],
          ),
          _ShimmerBox(width: 60, height: 32, isCircle: true),
        ],
      ),
    );
  }
}

class _UpcomingBookingSection extends ConsumerWidget {
  const _UpcomingBookingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(upcomingBookingsProvider);
    final schedulesAsync = ref.watch(allSchedulesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: SectionHeader(
            title: 'Upcoming Class',
            actionText: 'See All',
            onActionPressed: () => context.push(AppRoutes.bookingHistory),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        bookingsAsync.when(
          data: (bookings) {
            // Get schedules to check expiration
            final schedules = schedulesAsync.when(
              data: (s) => s,
              loading: () => <ScheduleModel>[],
              error: (e, s) => <ScheduleModel>[],
            );

            // Filter out expired bookings
            final scheduleMap = {for (var sched in schedules) sched.id: sched};
            final activeBookings = bookings.where((b) {
              final schedule = scheduleMap[b.scheduleId];
              // If schedule is expired, don't show in upcoming
              if (schedule != null && schedule.isExpired) {
                return false;
              }
              return true;
            }).toList();

            if (activeBookings.isEmpty) {
              return const _EmptyUpcomingBooking();
            }
            return _UpcomingBookingCard(booking: activeBookings.first);
          },
          loading: () => const _LoadingUpcomingBooking(),
          error: (e, _) => const _EmptyUpcomingBooking(),
        ),
      ],
    );
  }
}

class _UpcomingBookingCard extends ConsumerWidget {
  const _UpcomingBookingCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classAsync = ref.watch(classByIdProvider(booking.classId));
    final scheduleAsync = ref.watch(scheduleByIdProvider(booking.scheduleId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: AppCard(
        shadow: AppCardShadow.ambient,
        child: Column(
          children: [
            Row(
              children: [
                classAsync.when(
                  data: (yogaClass) => OptimizedImage(
                    imageUrl: yogaClass?.imageUrl ?? '',
                    width: 56,
                    height: 56,
                    errorPlaceholder: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppColors.onSurfaceVariant.withAlpha(128),
                      ),
                    ),
                  ),
                  loading: () => _ShimmerBox(width: 56, height: 56, isCircle: true),
                  error: (e, _) => Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.onSurfaceVariant.withAlpha(128),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      scheduleAsync.when(
                        data: (schedule) => Text(
                          schedule == null
                              ? 'Upcoming'
                              : _formatRelativeSchedule(schedule),
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.onTertiaryContainer,
                          ),
                        ),
                        loading: () => _ShimmerBox(width: 80),
                        error: (e, _) => Text(
                          'Upcoming',
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.onTertiaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      classAsync.when(
                        data: (yogaClass) => Text(
                          yogaClass?.title ?? 'Class',
                          style: AppTypography.h3,
                        ),
                        loading: () => _ShimmerBox(width: 120),
                        error: (e, _) => Text('Class', style: AppTypography.h3),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      scheduleAsync.when(
                        data: (schedule) {
                          return Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                schedule != null
                                    ? '${schedule.startTime} - ${schedule.endTime}'
                                    : 'Time to be confirmed',
                                style: AppTypography.bodyMd,
                              ),
                            ],
                          );
                        },
                        loading: () => _ShimmerBox(width: 100),
                        error: (e, _) => Text(
                          'Time to be confirmed',
                          style: AppTypography.bodyMd,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      _InstructorLine(scheduleAsync: scheduleAsync),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Check In',
                onPressed: () => context.push(
                  AppRoutes.bookingConfirmationPath(bookingId: booking.id),
                ),
                isExpanded: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeSchedule(ScheduleModel schedule) {
    final now = DateTime.now();
    final startTime = _timeOnDate(schedule.date, schedule.startTime);
    final difference = startTime.difference(now);

    if (_isSameDay(schedule.date, now)) {
      if (difference.inMinutes > 0 && difference.inHours < 12) {
        if (difference.inHours == 0) {
          return 'In ${difference.inMinutes} min';
        }
        return 'In ${difference.inHours} hr';
      }
      return 'Today';
    }

    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (_isSameDay(schedule.date, tomorrow)) {
      return 'Tomorrow';
    }

    return _formatShortDate(schedule.date);
  }

  DateTime _timeOnDate(DateTime date, String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _InstructorLine extends ConsumerWidget {
  const _InstructorLine({required this.scheduleAsync});

  final AsyncValue<ScheduleModel?> scheduleAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Icon(Icons.person_outline, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        scheduleAsync.when(
          data: (schedule) {
            if (schedule == null) {
              return Text('with Instructor', style: AppTypography.bodyMd);
            }
            final instructorAsync = ref.watch(
              instructorByIdProvider(schedule.instructorId),
            );
            return instructorAsync.when(
              data: (instructor) => Text(
                'with ${instructor?.name ?? 'Instructor'}',
                style: AppTypography.bodyMd,
              ),
              loading: () => _ShimmerBox(width: 96),
              error: (e, _) =>
                  Text('with Instructor', style: AppTypography.bodyMd),
            );
          },
          loading: () => _ShimmerBox(width: 96),
          error: (e, _) => Text('with Instructor', style: AppTypography.bodyMd),
        ),
      ],
    );
  }
}

class _EmptyUpcomingBooking extends StatelessWidget {
  const _EmptyUpcomingBooking();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: AppCard(
        shadow: AppCardShadow.subtle,
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: AppColors.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No upcoming classes', style: AppTypography.bodyMd),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Book your first class to get started',
              style: AppTypography.bodySm.copyWith(color: AppColors.outline),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Browse Classes',
              onPressed: () => context.go(AppRoutes.classes),
              variant: AppButtonVariant.secondary,
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingUpcomingBooking extends StatelessWidget {
  const _LoadingUpcomingBooking();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: AppCard(
        shadow: AppCardShadow.subtle,
        child: Column(
          children: [
            Row(
              children: [
                _ShimmerBox(width: 56, height: 56, isCircle: true),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(width: 80),
                      const SizedBox(height: AppSpacing.sm),
                      _ShimmerBox(width: 140, height: 24),
                      const SizedBox(height: AppSpacing.sm),
                      _ShimmerBox(width: 120),
                      const SizedBox(height: AppSpacing.xs),
                      _ShimmerBox(width: 100),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _ShimmerBox(height: 52),
          ],
        ),
      ),
    );
  }
}

class _FeaturedClassesSection extends ConsumerWidget {
  const _FeaturedClassesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(featuredClassesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: SectionHeader(
            title: 'Recommended for You',
            actionText: 'See All',
            onActionPressed: () => context.go(AppRoutes.classes),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 280,
          child: classesAsync.when(
            data: (classes) {
              if (classes.isEmpty) {
                return const Center(
                  child: Text('No featured classes'),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < classes.length - 1 ? AppSpacing.gutter : 0,
                    ),
                    child: _ClassCard(classModel: classes[index]),
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
                padding: EdgeInsets.only(right: AppSpacing.gutter),
                child: const _LoadingClassCard(),
              ),
            ),
            error: (e, _) => const Center(
              child: AppErrorState(
                title: 'Failed to load classes',
                subtitle: '',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClassCard extends ConsumerWidget {
  const _ClassCard({required this.classModel});

  final YogaClassModel classModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(schedulesByClassIdProvider(classModel.id));

    return GestureDetector(
      onTap: () => context.push(AppRoutes.classDetailPath(classModel.id)),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.surfaceVariant),
          boxShadow: AppShadows.ambient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: OptimizedImage(
                      imageUrl: classModel.imageUrl,
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
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getIntensityColor(classModel.intensity),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surfaceContainerLowest,
                          width: 1,
                        ),
                        boxShadow: AppShadows.subtle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classModel.title,
                      style: AppTypography.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_formatCategory(classModel.category)} - ${classModel.durationMinutes} Min',
                      style: AppTypography.bodyMd,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        schedulesAsync.when(
                          data: (schedules) => Text(
                            _formatNextSchedule(schedules),
                            style: AppTypography.labelCaps,
                          ),
                          loading: () => _ShimmerBox(width: 88),
                          error: (e, _) => Text(
                            'Schedule soon',
                            style: AppTypography.labelCaps,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: AppColors.outline,
                        ),
                      ],
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

  String _formatNextSchedule(List<ScheduleModel> schedules) {
    if (schedules.isEmpty) {
      return 'Schedule soon';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextSchedule = schedules
        .where((schedule) {
          final scheduleDate = DateTime(
            schedule.date.year,
            schedule.date.month,
            schedule.date.day,
          );
          return !scheduleDate.isBefore(today);
        })
        .fold<ScheduleModel?>(null, (previous, schedule) {
          if (previous == null) return schedule;
          if (schedule.date.isBefore(previous.date)) return schedule;
          return previous;
        });

    final schedule = nextSchedule ?? schedules.first;
    if (_isSameDay(schedule.date, now)) {
      return 'Today, ${schedule.startTime}';
    }
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (_isSameDay(schedule.date, tomorrow)) {
      return 'Tomorrow, ${schedule.startTime}';
    }
    return '${_formatShortDate(schedule.date)}, ${schedule.startTime}';
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _LoadingClassCard extends StatelessWidget {
  const _LoadingClassCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: AppShadows.ambient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.card),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(width: 140),
                const SizedBox(height: AppSpacing.sm),
                _ShimmerBox(width: 100),
                const SizedBox(height: AppSpacing.lg),
                _ShimmerBox(width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: SectionHeader(title: 'Quick Actions'),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _QuickActionCard(
                icon: Icons.self_improvement,
                label: 'Classes',
                onTap: () => context.go(AppRoutes.classes),
              ),
              _QuickActionCard(
                icon: Icons.calendar_today,
                label: 'Schedule',
                onTap: () => context.go(AppRoutes.schedule),
              ),
              _QuickActionCard(
                icon: Icons.account_balance_wallet,
                label: 'Top Up',
                onTap: () => context.push(AppRoutes.topUp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).extension<OnnaThemeTokens>()!.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: AppColors.primary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.labelCaps.copyWith(
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({this.width, this.height = 16, this.isCircle = false});

  final double? width;
  final double height;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: isCircle
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}
