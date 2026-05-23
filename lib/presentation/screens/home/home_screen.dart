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
import '../../../data/models/booking_model.dart';
import '../../../data/models/yoga_class_model.dart';
import '../../../data/models/membership_package_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/membership_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/layout/section_header.dart';

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
            // Greeting Section
            const _GreetingSection(),
            const SizedBox(height: AppSpacing.xl),
            // Hero Section
            const _HeroSection(),
            const SizedBox(height: AppSpacing.xxl),
            // Credit Summary
            const _CreditSummarySection(),
            const SizedBox(height: AppSpacing.xxl),
            // Upcoming Booking
            const _UpcomingBookingSection(),
            const SizedBox(height: AppSpacing.xxl),
            // Featured Classes
            const _FeaturedClassesSection(),
            const SizedBox(height: AppSpacing.xxl),
            // Quick Actions
            const _QuickActionsSection(),
            const SizedBox(height: AppSpacing.xxl),
            // Package Promotion
            const _PackagePromotionSection(),
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
            error: (_, _) => Text('Member', style: AppTypography.h1),
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
            // Hero Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.card),
                ),
              ),
              child: Stack(
                children: [
                  // Placeholder gradient
                  Container(
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
                  ),
                  // Center content
                  Center(
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
                ],
              ),
            ),
            // Content
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
            error: (_, _) => const SizedBox.shrink(),
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
            children: const [
              _ShimmerText(width: 60, height: 36),
              SizedBox(height: AppSpacing.xs),
              _ShimmerText(width: 100, height: 16),
            ],
          ),
          const _ShimmerBox(width: 60, height: 32, isCircle: true),
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
            if (bookings.isEmpty) {
              return const _EmptyUpcomingBooking();
            }
            return _UpcomingBookingCard(booking: bookings.first);
          },
          loading: () => const _LoadingUpcomingBooking(),
          error: (_, _) => const _EmptyUpcomingBooking(),
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
    // Get class and schedule data
    final classAsync = ref.watch(classByIdProvider(booking.classId));
    final schedulesAsync = ref.watch(
      schedulesByClassIdProvider(booking.classId),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: AppCard(
        shadow: AppCardShadow.ambient,
        child: Column(
          children: [
            Row(
              children: [
                // Instructor avatar placeholder
                Container(
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
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'In 45 Minutes',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.onTertiaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      classAsync.when(
                        data: (yogaClass) => Text(
                          yogaClass?.title ?? 'Class',
                          style: AppTypography.h3,
                        ),
                        loading: () => const _ShimmerText(width: 120),
                        error: (_, _) => Text('Class', style: AppTypography.h3),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      schedulesAsync.when(
                        data: (schedules) {
                          final schedule = schedules.isNotEmpty
                              ? schedules.first
                              : null;
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
                                    : '10:00 AM - 11:15 AM',
                                style: AppTypography.bodyMd,
                              ),
                            ],
                          );
                        },
                        loading: () => const _ShimmerText(width: 100),
                        error: (_, _) => Text(
                          '10:00 AM - 11:15 AM',
                          style: AppTypography.bodyMd,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text('with Elena R.', style: AppTypography.bodyMd),
                        ],
                      ),
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
                onPressed: () => context.push(AppRoutes.bookingConfirmation),
                isExpanded: true,
              ),
            ),
          ],
        ),
      ),
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
                const _ShimmerBox(width: 56, height: 56, isCircle: true),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _ShimmerText(width: 80),
                      SizedBox(height: AppSpacing.sm),
                      _ShimmerText(width: 140, height: 24),
                      SizedBox(height: AppSpacing.sm),
                      _ShimmerText(width: 120),
                      SizedBox(height: AppSpacing.xs),
                      _ShimmerText(width: 100),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const _ShimmerBox(height: 52),
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
            data: (classes) => ListView.builder(
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
            ),
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              itemCount: 3,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(right: AppSpacing.gutter),
                child: _LoadingClassCard(),
              ),
            ),
            error: (_, _) =>
                const Center(child: Text('Failed to load classes')),
          ),
        ),
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.classModel});

  final YogaClassModel classModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/class/${classModel.id}'),
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
            // Class image placeholder
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.card),
                ),
              ),
              child: Stack(
                children: [
                  // Placeholder gradient
                  Container(
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
                  ),
                  // Icon
                  Center(
                    child: Icon(
                      Icons.self_improvement,
                      size: 48,
                      color: AppColors.onSurfaceVariant.withAlpha(128),
                    ),
                  ),
                  // Mood indicator
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getIntensityColor(classModel.intensity),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                        boxShadow: const [
                          BoxShadow(color: Color(0x29000000), blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
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
                      '${classModel.category.name} · ${classModel.durationMinutes} Min',
                      style: AppTypography.bodyMd,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Today, 6:00 PM', style: AppTypography.labelCaps),
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

  Color _getIntensityColor(dynamic intensity) {
    final intensityName = intensity.toString().split('.').last;
    switch (intensityName) {
      case 'low':
        return AppColors.secondaryContainer;
      case 'medium':
        return AppColors.primaryFixed;
      case 'high':
        return AppColors.tertiaryContainer;
      default:
        return AppColors.secondaryContainer;
    }
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
              children: const [
                _ShimmerText(width: 140),
                SizedBox(height: AppSpacing.sm),
                _ShimmerText(width: 100),
                SizedBox(height: AppSpacing.lg),
                _ShimmerText(width: 80),
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
                icon: Icons.payments,
                label: 'Package',
                onTap: () => context.go(AppRoutes.package),
              ),
              _QuickActionCard(
                icon: Icons.account_balance_wallet,
                label: 'My Credit',
                onTap: () => context.push(AppRoutes.wallet),
              ),
              _QuickActionCard(
                icon: Icons.location_on,
                label: 'Location',
                onTap: () => context.push(AppRoutes.location),
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

class _PackagePromotionSection extends ConsumerWidget {
  const _PackagePromotionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageAsync = ref.watch(popularPackageProvider);

    return packageAsync.when(
      data: (package) {
        if (package == null) return const SizedBox.shrink();
        return _PackagePromotionCard(package: package);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _PackagePromotionCard extends StatelessWidget {
  const _PackagePromotionCard({required this.package});

  final MembershipPackageModel package;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.tertiaryContainer, AppColors.secondaryContainer],
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.ambient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Popular Choice',
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.onTertiaryFixed,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          package.name,
                          style: AppTypography.h3.copyWith(
                            color: AppColors.onTertiaryFixed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.onTertiaryFixed.withAlpha(51),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      package.hasUnlimitedCredits
                          ? 'Unlimited'
                          : '${package.credits} Credits',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.onTertiaryFixed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                package.description,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onTertiaryFixed.withAlpha(204),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${package.validityDays} Days',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.onTertiaryFixed,
                          ),
                        ),
                        Text(
                          'Validity',
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.onTertiaryFixed.withAlpha(179),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    label: 'Get Package',
                    onPressed: () => context.go(AppRoutes.package),
                    isExpanded: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widgets for shimmer loading states
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({this.width, required this.height, this.isCircle = false});

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

class _ShimmerText extends StatelessWidget {
  const _ShimmerText({this.width = 100, this.height = 16});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}
