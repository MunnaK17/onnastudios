import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../config/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/app_enums.dart';
import '../../providers/booking_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../../shared/widgets/buttons/app_button.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({this.bookingId, super.key});

  final String? bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookingId == null) {
      return const _NotFoundScreen(message: 'Booking not specified');
    }

    final bookingAsync = ref.watch(bookingByIdProvider(bookingId!));

    return bookingAsync.when(
      data: (booking) {
        if (booking == null) {
          return const _NotFoundScreen(message: 'Booking not found');
        }
        return _BookingConfirmationContent(booking: booking);
      },
      loading: () => const _LoadingScreen(),
      error: (_, _) => const _NotFoundScreen(message: 'Failed to load booking'),
    );
  }
}

class _BookingConfirmationContent extends ConsumerWidget {
  const _BookingConfirmationContent({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classAsync = ref.watch(classByIdProvider(booking.classId));
    final schedulesAsync = ref.watch(
      schedulesByClassIdProvider(booking.classId),
    );
    final locationAsync = ref.watch(mainLocationProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              // Success Header
              _SuccessHeader(classAsync: classAsync),
              const SizedBox(height: AppSpacing.xxl),
              // QR Code Card
              _QRCodeCard(booking: booking),
              const SizedBox(height: AppSpacing.xl),
              // Booking Details
              _BookingDetailsSection(
                booking: booking,
                classAsync: classAsync,
                schedulesAsync: schedulesAsync,
                locationAsync: locationAsync,
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Action Buttons
              _ActionButtons(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({required this.classAsync});

  final AsyncValue<dynamic> classAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Success Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 48,
            color: AppColors.onSecondaryContainer,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Title
        Text(
          "You're all set!",
          style: AppTypography.h2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: classAsync.when(
            data: (yogaClass) => Text(
              'Your spot for the ${yogaClass?.title ?? 'class'} has been securely booked. We look forward to seeing you in the studio.',
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            loading: () => Text(
              'Your spot has been securely booked. We look forward to seeing you in the studio.',
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            error: (_, _) => Text(
              'Your spot has been securely booked. We look forward to seeing you in the studio.',
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _QRCodeCard extends StatelessWidget {
  const _QRCodeCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final qrPayload = _generateSecureQRPayload(booking);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: AppShadows.ambient,
      ),
      child: Column(
        children: [
          // QR Code
          Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: QrImageView(
              data: qrPayload,
              version: QrVersions.auto,
              size: 150,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF181512),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF181512),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Scan at Front Desk',
            style: AppTypography.labelCaps.copyWith(color: AppColors.outline),
          ),
        ],
      ),
    );
  }

  /// Generates a secure QR payload following SECURITY.md guidelines.
  /// QR payload contains: booking_id, checkin_token, expiry timestamp.
  String _generateSecureQRPayload(BookingModel booking) {
    // QR payload structure per SECURITY.md:
    // - booking_id: unique booking identifier
    // - checkin_token: secure token for check-in
    // - expiry: timestamp when QR expires (1 hour from now for demo)
    final expiryTimestamp = DateTime.now()
        .add(const Duration(hours: 24))
        .millisecondsSinceEpoch;

    final payload = {
      'booking_id': booking.id,
      'checkin_token': booking.qrCodeValue,
      'expiry': expiryTimestamp.toString(),
    };

    // Encode as base64 for compact QR and additional privacy
    final jsonString = jsonEncode(payload);
    final base64String = base64Encode(utf8.encode(jsonString));

    return base64String;
  }
}

class _BookingDetailsSection extends ConsumerWidget {
  const _BookingDetailsSection({
    required this.booking,
    required this.classAsync,
    required this.schedulesAsync,
    required this.locationAsync,
  });

  final BookingModel booking;
  final AsyncValue<dynamic> classAsync;
  final AsyncValue<dynamic> schedulesAsync;
  final AsyncValue<dynamic> locationAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorAsync = ref.watch(instructorByIdProvider(booking.classId));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          // Class Title
          classAsync.when(
            data: (yogaClass) =>
                Text(yogaClass?.title ?? 'Class', style: AppTypography.h3),
            loading: () => Container(
              width: 160,
              height: 24,
              color: AppColors.surfaceContainerHigh,
            ),
            error: (_, _) => Text('Class', style: AppTypography.h3),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Instructor
          _DetailRow(
            icon: Icons.person_outline,
            label: 'Instructor',
            child: instructorAsync.when(
              data: (instructor) =>
                  Text(instructor?.name ?? 'TBA', style: AppTypography.bodyLg),
              loading: () => Container(
                width: 100,
                height: 16,
                color: AppColors.surfaceContainerHigh,
              ),
              error: (_, _) => Text('TBA', style: AppTypography.bodyLg),
            ),
          ),
          const Divider(color: AppColors.outlineVariant, height: AppSpacing.xl),
          // Date & Time
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date & Time',
            child: schedulesAsync.when(
              data: (schedules) {
                final schedule = schedules.isNotEmpty ? schedules.first : null;
                if (schedule == null) {
                  return Text('TBA', style: AppTypography.bodyLg);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(schedule.date),
                      style: AppTypography.bodyLg,
                    ),
                    Text(
                      '${schedule.startTime} - ${schedule.endTime}',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
              loading: () => Container(
                width: 120,
                height: 32,
                color: AppColors.surfaceContainerHigh,
              ),
              error: (_, _) => Text('TBA', style: AppTypography.bodyLg),
            ),
          ),
          const Divider(color: AppColors.outlineVariant, height: AppSpacing.xl),
          // Location
          _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            child: schedulesAsync.when(
              data: (schedules) {
                final schedule = schedules.isNotEmpty ? schedules.first : null;
                return locationAsync.when(
                  data: (location) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location?.name ?? schedule?.studioRoom ?? 'TBA',
                        style: AppTypography.bodyLg,
                      ),
                      if (location != null)
                        Text(
                          '${location.address}',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  loading: () => Text(
                    schedule?.studioRoom ?? 'TBA',
                    style: AppTypography.bodyLg,
                  ),
                  error: (_, _) => Text(
                    schedule?.studioRoom ?? 'TBA',
                    style: AppTypography.bodyLg,
                  ),
                );
              },
              loading: () => Container(
                width: 120,
                height: 32,
                color: AppColors.surfaceContainerHigh,
              ),
              error: (_, _) => Text('TBA', style: AppTypography.bodyLg),
            ),
          ),
          const Divider(color: AppColors.outlineVariant, height: AppSpacing.xl),
          // Credits Used
          _DetailRow(
            icon: Icons.monetization_on_outlined,
            label: 'Credits Used',
            child: classAsync.when(
              data: (yogaClass) => Text(
                '${yogaClass?.creditCost ?? 0} Credits',
                style: AppTypography.bodyLg,
              ),
              loading: () => Container(
                width: 80,
                height: 16,
                color: AppColors.surfaceContainerHigh,
              ),
              error: (_, _) => Text('0 Credits', style: AppTypography.bodyLg),
            ),
          ),
          const Divider(color: AppColors.outlineVariant, height: AppSpacing.xl),
          // Status
          _DetailRow(
            icon: Icons.verified_outlined,
            label: 'Status',
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                _formatStatus(booking.status),
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.upcoming:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.expired:
        return 'Expired';
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add to Calendar (Placeholder)
        AppButton(
          label: 'Add to Calendar',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Calendar integration will be available soon.'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
          isExpanded: true,
        ),
        const SizedBox(height: AppSpacing.md),
        // View Booking History
        AppButton(
          label: 'View My Schedule',
          variant: AppButtonVariant.ghost,
          onPressed: () => context.push(AppRoutes.bookingHistory),
          isExpanded: true,
        ),
        const SizedBox(height: AppSpacing.md),
        // Back to Home
        AppButton(
          label: 'Back to Home',
          variant: AppButtonVariant.text,
          onPressed: () => context.go(AppRoutes.home),
          isExpanded: true,
        ),
      ],
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: 200,
                height: 32,
                color: AppColors.surfaceContainerHigh,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: 250,
                height: 180,
                color: AppColors.surfaceContainerHigh,
              ),
            ],
          ),
        ),
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
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner_outlined,
                  size: 64,
                  color: AppColors.onSurfaceVariant.withAlpha(128),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  message ?? 'Booking Not Found',
                  style: AppTypography.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This booking may no longer be available',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Back to Home',
                  onPressed: () => context.go(AppRoutes.home),
                  isExpanded: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
