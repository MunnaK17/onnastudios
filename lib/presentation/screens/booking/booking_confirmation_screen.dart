import 'dart:async';

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
import '../../../data/models/instructor_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/yoga_class_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/qr/qr_code_display.dart';

/// Low credit threshold for warning
const int lowCreditThreshold = 5;

/// Time before class when check-in becomes available (30 minutes)
const Duration checkInAvailableTime = Duration(minutes: 30);

class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({this.bookingId, super.key});

  final String? bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookingId == null) {
      return const _NotFoundScreen(message: 'Booking not specified');
    }

    // Watch the booking provider with polling for real-time updates
    final bookingAsync = ref.watch(bookingWatcherProvider(bookingId!));

    return bookingAsync.when(
      data: (booking) {
        if (booking == null) {
          return const _NotFoundScreen(message: 'Booking not found');
        }
        // Pass bookingId and ref for polling
        return _BookingConfirmationWrapper(
          booking: booking,
          bookingId: bookingId!,
          ref: ref,
        );
      },
      loading: () => const _LoadingScreen(),
      error: (e, _) => _NotFoundScreen(
        message: 'Failed to load booking',
        onRetry: () => ref.invalidate(bookingWatcherProvider(bookingId!)),
      ),
    );
  }
}

/// Wrapper that handles polling and status change detection
class _BookingConfirmationWrapper extends StatefulWidget {
  const _BookingConfirmationWrapper({
    required this.booking,
    required this.bookingId,
    required this.ref,
  });

  final BookingModel booking;
  final String bookingId;
  final WidgetRef ref;

  @override
  State<_BookingConfirmationWrapper> createState() => _BookingConfirmationWrapperState();
}

class _BookingConfirmationWrapperState extends State<_BookingConfirmationWrapper> {
  Timer? _pollingTimer;
  bool _wasCheckedIn = false;
  bool _notificationShown = false;

  @override
  void initState() {
    super.initState();
    _wasCheckedIn = widget.booking.checkedIn;
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    // Poll every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        // Force refresh the booking provider
        widget.ref.invalidate(bookingWatcherProvider(widget.bookingId));
      }
    });
  }

  void _showCheckedInNotification(BuildContext context) {
    if (_notificationShown) return;
    _notificationShown = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('You have been checked in by the instructor!'),
            ),
          ],
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for booking updates
    final bookingAsync = widget.ref.watch(bookingWatcherProvider(widget.bookingId));

    return bookingAsync.when(
      data: (booking) {
        if (booking == null) {
          return const _NotFoundScreen(message: 'Booking not found');
        }

        // Check if status changed to checked in
        final isCheckedIn = booking.checkedIn;
        if (!_wasCheckedIn && isCheckedIn) {
          _wasCheckedIn = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCheckedInNotification(context);
          });
        }

        return _BookingConfirmationContent(booking: booking);
      },
      loading: () => _BookingConfirmationContent(booking: widget.booking),
      error: (e, _) => _BookingConfirmationContent(booking: widget.booking),
    );
  }
}

class _BookingConfirmationContent extends ConsumerWidget {
  const _BookingConfirmationContent({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classAsync = ref.watch(classByIdProvider(booking.classId));
    final scheduleAsync = ref.watch(scheduleByIdProvider(booking.scheduleId));
    final creditsAsync = ref.watch(remainingCreditsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              _SuccessHeader(classAsync: classAsync),
              const SizedBox(height: AppSpacing.xxl),
              _QRCodeCard(booking: booking),
              const SizedBox(height: AppSpacing.xl),
              // Low credit warning banner
              _CreditWarningBanner(
                creditsAsync: creditsAsync,
                threshold: lowCreditThreshold,
              ),
              if (_hasLowCredit(creditsAsync)) const SizedBox(height: AppSpacing.xl),
              _BookingDetailsSection(
                booking: booking,
                classAsync: classAsync,
                scheduleAsync: scheduleAsync,
              ),
              const SizedBox(height: AppSpacing.xxl),
              _ActionButtons(booking: booking),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasLowCredit(AsyncValue<int> creditsAsync) {
    return creditsAsync.maybeWhen(
      data: (credits) => credits <= lowCreditThreshold,
      orElse: () => false,
    );
  }
}

class _CreditWarningBanner extends StatelessWidget {
  const _CreditWarningBanner({
    required this.creditsAsync,
    required this.threshold,
  });

  final AsyncValue<int> creditsAsync;
  final int threshold;

  @override
  Widget build(BuildContext context) {
    return creditsAsync.when(
      data: (credits) {
        if (credits == 0) {
          return _WarningBanner(
            icon: Icons.credit_card_off_outlined,
            title: 'Credits Depleted',
            message: 'You have no credits remaining. Top up to continue booking.',
            backgroundColor: AppColors.errorContainer,
            textColor: AppColors.onErrorContainer,
          );
        } else if (credits <= threshold) {
          return _WarningBanner(
            icon: Icons.warning_amber_rounded,
            title: 'Credits Running Low',
            message: 'You only have $credits credits left. Consider topping up.',
            backgroundColor: AppColors.tertiaryFixed,
            textColor: AppColors.onTertiaryFixed,
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({
    required this.icon,
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMd.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: AppTypography.bodySm.copyWith(color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({required this.classAsync});

  final AsyncValue<YogaClassModel?> classAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, size: 48, color: AppColors.onSecondaryContainer),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text("You're all set!", style: AppTypography.h2, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: classAsync.when(
            data: (yogaClass) => Text(
              'Your spot for the ${yogaClass?.title ?? 'class'} has been securely booked. We look forward to seeing you in the studio.',
              style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            loading: () => Text(
              'Your spot has been securely booked. We look forward to seeing you in the studio.',
              style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            error: (e, _) => Text(
              'Your spot has been securely booked. We look forward to seeing you in the studio.',
              style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _QRCodeCard extends ConsumerStatefulWidget {
  const _QRCodeCard({required this.booking});

  final BookingModel booking;

  @override
  ConsumerState<_QRCodeCard> createState() => _QRCodeCardState();
}

class _QRCodeCardState extends ConsumerState<_QRCodeCard> {
  Timer? _countdownTimer;
  Duration _timeUntilClass = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _updateTimeUntilClass();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeUntilClass();
    });
  }

  void _updateTimeUntilClass() {
    final scheduleAsync = ref.read(scheduleByIdProvider(widget.booking.scheduleId));
    scheduleAsync.whenData((schedule) {
      if (schedule != null) {
        final now = DateTime.now();
        final classStart = DateTime(
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
          int.parse(schedule.startTime.split(':')[0]),
          int.parse(schedule.startTime.split(':')[1]),
        );
        if (mounted) {
          setState(() {
            _timeUntilClass = classStart.difference(now);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final qrPayload = _generateSecureQRPayload(widget.booking);
    final isCheckInAvailable = _timeUntilClass.inMinutes <= 30 && !_timeUntilClass.isNegative;
    final isCheckedIn = widget.booking.checkedIn;

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
          // Status Badge
          _CheckInStatusBadge(
            isCheckedIn: isCheckedIn,
            timeUntilClass: _timeUntilClass,
          ),

          const SizedBox(height: AppSpacing.lg),

          // QR Code
          GestureDetector(
            onTap: isCheckInAvailable || isCheckedIn
                ? () => _showFullScreenQr(context)
                : null,
            child: Opacity(
              opacity: isCheckInAvailable || isCheckedIn ? 1.0 : 0.4,
              child: Container(
                width: 225, // 25% larger (was 180)
                height: 225, // 25% larger (was 180)
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isCheckInAvailable
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    width: isCheckInAvailable ? 2 : 1,
                  ),
                ),
                child: QrImageView(
                  data: qrPayload,
                  version: QrVersions.auto,
                  size: 188, // 25% larger (was 150)
                  backgroundColor: AppColors.surfaceContainerLowest,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black, // Dark black for better scanning
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black, // Dark black for better scanning
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Instruction text
          Text(
            isCheckedIn
                ? 'Checked In Successfully'
                : isCheckInAvailable
                    ? 'Tap QR to enlarge'
                    : 'QR available 30 min before class',
            style: AppTypography.labelCaps.copyWith(
              color: isCheckedIn
                  ? AppColors.secondary
                  : AppColors.outline,
            ),
          ),

          // Countdown timer
          if (!isCheckedIn && _timeUntilClass.inMinutes > 0) ...[
            const SizedBox(height: AppSpacing.lg),
            _CountdownTimer(timeUntilClass: _timeUntilClass),
          ],

          // Check In button
          if (isCheckInAvailable && !isCheckedIn) ...[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Show QR to Instructor',
                onPressed: () => _showFullScreenQr(context),
                isExpanded: true,
              ),
            ),
          ],

          // Checked In confirmation
          if (isCheckedIn) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withAlpha(77),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Attendance Confirmed',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullScreenQr(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenQrCode(
          qrCodeValue: _generateSecureQRPayload(widget.booking),
          bookingId: widget.booking.id,
        ),
      ),
    );
  }

  String _generateSecureQRPayload(BookingModel booking) {
    // Use booking ID directly as QR data for easier scanning
    // The admin scanner will use this ID to look up the booking
    return booking.id;
  }
}

class _CheckInStatusBadge extends StatelessWidget {
  const _CheckInStatusBadge({
    required this.isCheckedIn,
    required this.timeUntilClass,
  });

  final bool isCheckedIn;
  final Duration timeUntilClass;

  @override
  Widget build(BuildContext context) {
    final status = _getStatus();
    final color = _getStatusColor();
    final bgColor = _getStatusBgColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 16,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            status,
            style: AppTypography.labelCaps.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatus() {
    if (isCheckedIn) return 'Checked In';
    if (timeUntilClass.inMinutes <= 15) return 'Get Ready!';
    if (timeUntilClass.inMinutes <= 30) return 'Check In Now';
    return 'Upcoming';
  }

  Color _getStatusColor() {
    if (isCheckedIn) return AppColors.secondary;
    if (timeUntilClass.inMinutes <= 15) return AppColors.tertiary;
    if (timeUntilClass.inMinutes <= 30) return AppColors.primary;
    return AppColors.outline;
  }

  Color _getStatusBgColor() {
    if (isCheckedIn) return AppColors.secondaryContainer;
    if (timeUntilClass.inMinutes <= 15) return AppColors.tertiaryFixed;
    if (timeUntilClass.inMinutes <= 30) return AppColors.primaryContainer;
    return AppColors.surfaceContainerHigh;
  }

  IconData _getStatusIcon() {
    if (isCheckedIn) return Icons.check_circle;
    if (timeUntilClass.inMinutes <= 30) return Icons.qr_code_scanner;
    return Icons.schedule;
  }
}

class _CountdownTimer extends StatelessWidget {
  const _CountdownTimer({required this.timeUntilClass});

  final Duration timeUntilClass;

  @override
  Widget build(BuildContext context) {
    final hours = timeUntilClass.inHours;
    final minutes = timeUntilClass.inMinutes.remainder(60);
    final seconds = timeUntilClass.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Class starts in ',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingDetailsSection extends ConsumerWidget {
  const _BookingDetailsSection({
    required this.booking,
    required this.classAsync,
    required this.scheduleAsync,
  });

  final BookingModel booking;
  final AsyncValue<YogaClassModel?> classAsync;
  final AsyncValue<ScheduleModel?> scheduleAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorAsync = classAsync.maybeWhen(
      data: (yogaClass) => yogaClass == null
          ? const AsyncValue<InstructorModel?>.data(null)
          : ref.watch(instructorByIdProvider(yogaClass.instructorId)),
      orElse: () => const AsyncValue<InstructorModel?>.loading(),
    );

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
          classAsync.when(
            data: (yogaClass) => Text(yogaClass?.title ?? 'Class', style: AppTypography.h3),
            loading: () => Container(width: 160, height: 24, color: AppColors.surfaceContainerHigh),
            error: (e, _) => Text('Class', style: AppTypography.h3),
          ),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(
            icon: Icons.person_outline,
            label: 'Instructor',
            child: instructorAsync.when(
              data: (instructor) => Text(instructor?.name ?? 'TBA', style: AppTypography.bodyLg),
              loading: () => Container(width: 100, height: 16, color: AppColors.surfaceContainerHigh),
              error: (e, _) => Text('TBA', style: AppTypography.bodyLg),
            ),
          ),
          const Divider(color: AppColors.outlineVariant, height: AppSpacing.xl),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date & Time',
            child: scheduleAsync.when(
              data: (schedule) {
                if (schedule == null) return Text('TBA', style: AppTypography.bodyLg);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatDate(schedule.date), style: AppTypography.bodyLg),
                    Text('${schedule.startTime} - ${schedule.endTime}', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                );
              },
              loading: () => Container(width: 120, height: 32, color: AppColors.surfaceContainerHigh),
              error: (e, _) => Text('TBA', style: AppTypography.bodyLg),
            ),
          ),
          const Divider(color: AppColors.outlineVariant, height: AppSpacing.xl),
          _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Room',
            child: scheduleAsync.when(
              data: (schedule) => Text(schedule?.studioRoom ?? 'TBA', style: AppTypography.bodyLg),
              loading: () => Container(width: 120, height: 32, color: AppColors.surfaceContainerHigh),
              error: (e, _) => Text('TBA', style: AppTypography.bodyLg),
            ),
          ),
          const Divider(color: AppColors.outlineVariant, height: AppSpacing.xl),
          _DetailRow(
            icon: Icons.monetization_on_outlined,
            label: 'Credits Used',
            child: classAsync.when(
              data: (yogaClass) => Text('${yogaClass?.creditCost ?? 0} Credits', style: AppTypography.bodyLg),
              loading: () => Container(width: 80, height: 16, color: AppColors.surfaceContainerHigh),
              error: (e, _) => Text('0 Credits', style: AppTypography.bodyLg),
            ),
          ),
          const Divider(color: AppColors.outlineVariant, height: AppSpacing.xl),
          // Booking ID - Important for manual check-in
          _DetailRow(
            icon: Icons.tag,
            label: 'Booking ID',
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    booking.id.length > 8 ? '${booking.id.substring(0, 8)}...' : booking.id,
                    style: AppTypography.bodyLg.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    // Copy to clipboard functionality would go here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Booking ID: ${booking.id}'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Show full ID',
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Show full booking ID for instructor
          GestureDetector(
            onTap: () => _showFullBookingId(context, booking.id),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withAlpha(51),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Show this ID to instructor for manual check-in',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: AppColors.outlineVariant, height: AppSpacing.xl),
          _DetailRow(
            icon: Icons.verified_outlined,
            label: 'Status',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
              decoration: BoxDecoration(
                color: booking.checkedIn
                    ? AppColors.secondaryContainer
                    : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    booking.checkedIn ? Icons.check_circle : Icons.schedule,
                    size: 14,
                    color: booking.checkedIn
                        ? AppColors.onSecondaryContainer
                        : AppColors.onPrimaryContainer,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    booking.checkedIn ? 'Checked In' : _formatStatus(booking.status),
                    style: AppTypography.bodySm.copyWith(
                      color: booking.checkedIn
                          ? AppColors.onSecondaryContainer
                          : AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (booking.checkedIn && booking.checkedInAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 56),
              child: Text(
                'Checked in at ${_formatTime(booking.checkedInAt!)}',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.upcoming: return 'Confirmed';
      case BookingStatus.completed: return 'Completed';
      case BookingStatus.cancelled: return 'Cancelled';
      case BookingStatus.expired: return 'Expired';
      case BookingStatus.noShow: return 'No Show';
    }
  }

  void _showFullBookingId(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.tag, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Booking ID'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Show this ID to the instructor for manual check-in:',
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                bookingId,
                style: AppTypography.bodyLg.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.child});

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
              Text(label.toUpperCase(), style: AppTypography.labelCaps.copyWith(color: AppColors.outline)),
              const SizedBox(height: AppSpacing.xxs),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpcoming = booking.status == BookingStatus.upcoming && !booking.checkedIn;
    final canCheckIn = _canCheckInNow(ref);

    return Column(
      children: [
        // Manual Check-in Button (Backup)
        if (isUpcoming) ...[
          _ManualCheckInButton(
            booking: booking,
            canCheckIn: canCheckIn,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AppButton(
          label: 'Add to Calendar',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Calendar integration will be available soon.'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
          isExpanded: true,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Reschedule',
          variant: AppButtonVariant.secondary,
          onPressed: () {
            // Navigate to schedule select for reschedule
            context.push(
              Uri(
                path: '/schedule/select/${booking.classId}',
                queryParameters: {'bookingId': booking.id},
              ).toString(),
            );
          },
          isExpanded: true,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'View My Schedule',
          variant: AppButtonVariant.ghost,
          onPressed: () => context.push(AppRoutes.bookingHistory),
          isExpanded: true,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Back to Home',
          variant: AppButtonVariant.text,
          onPressed: () => context.go(AppRoutes.home),
          isExpanded: true,
        ),
      ],
    );
  }

  bool _canCheckInNow(WidgetRef ref) {
    final scheduleAsync = ref.read(scheduleByIdProvider(booking.scheduleId));
    return scheduleAsync.maybeWhen(
      data: (schedule) {
        if (schedule == null) return false;
        final now = DateTime.now();
        final classStart = DateTime(
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
          int.parse(schedule.startTime.split(':')[0]),
          int.parse(schedule.startTime.split(':')[1]),
        );
        final diff = classStart.difference(now);
        // Can check in 30 minutes before class
        return diff.inMinutes <= 30 && !diff.isNegative;
      },
      orElse: () => false,
    );
  }
}

class _ManualCheckInButton extends ConsumerStatefulWidget {
  const _ManualCheckInButton({
    required this.booking,
    required this.canCheckIn,
  });

  final BookingModel booking;
  final bool canCheckIn;

  @override
  ConsumerState<_ManualCheckInButton> createState() => _ManualCheckInButtonState();
}

class _ManualCheckInButtonState extends ConsumerState<_ManualCheckInButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: widget.canCheckIn
            ? AppColors.secondaryContainer
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: widget.canCheckIn
              ? AppColors.secondary.withAlpha(77)
              : AppColors.surfaceVariant,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.canCheckIn
                      ? AppColors.secondary
                      : AppColors.outline,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manual Check-in',
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.canCheckIn
                            ? AppColors.onSecondaryContainer
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      widget.canCheckIn
                          ? 'Tap to mark attendance'
                          : 'Available 30 min before class',
                      style: AppTypography.bodySm.copyWith(
                        color: widget.canCheckIn
                            ? AppColors.onSecondaryContainer.withAlpha(179)
                            : AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: widget.canCheckIn
                      ? () => _performManualCheckIn(context)
                      : null,
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: widget.canCheckIn
                        ? AppColors.secondary
                        : AppColors.outline,
                    size: 20,
                  ),
                ),
            ],
          ),
          if (!widget.canCheckIn) ...[
            const SizedBox(height: AppSpacing.sm),
            _CheckInCountdown(ref: ref, scheduleId: widget.booking.scheduleId),
          ],
        ],
      ),
    );
  }

  Future<void> _performManualCheckIn(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      await ref.read(bookingNotifierProvider.notifier).markAsCheckedIn(widget.booking.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Check-in successful!'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check-in failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _CheckInCountdown extends StatefulWidget {
  const _CheckInCountdown({
    required this.ref,
    required this.scheduleId,
  });

  final WidgetRef ref;
  final String scheduleId;

  @override
  State<_CheckInCountdown> createState() => _CheckInCountdownState();
}

class _CheckInCountdownState extends State<_CheckInCountdown> {
  Timer? _timer;
  Duration _timeUntilCheckIn = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeUntilCheckIn();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeUntilCheckIn();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTimeUntilCheckIn() {
    final scheduleAsync = widget.ref.read(scheduleByIdProvider(widget.scheduleId));
    scheduleAsync.whenData((schedule) {
      if (schedule != null) {
        final now = DateTime.now();
        final classStart = DateTime(
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
          int.parse(schedule.startTime.split(':')[0]),
          int.parse(schedule.startTime.split(':')[1]),
        );
        // Check-in available 30 min before
        final checkInTime = classStart.subtract(const Duration(minutes: 30));
        if (mounted) {
          setState(() {
            _timeUntilCheckIn = checkInTime.difference(now);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hours = _timeUntilCheckIn.inHours;
    final minutes = _timeUntilCheckIn.inMinutes.remainder(60);
    final seconds = _timeUntilCheckIn.inSeconds.remainder(60);

    if (_timeUntilCheckIn.isNegative || _timeUntilCheckIn.inMinutes < 0) {
      return const SizedBox.shrink();
    }

    return Text(
      'Check-in available in ${hours > 0 ? '${hours}h ' : ''}${minutes}m ${seconds}s',
      style: AppTypography.labelCaps.copyWith(
        color: AppColors.outline,
        fontSize: 11,
      ),
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
              Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle)),
              const SizedBox(height: AppSpacing.xl),
              Container(width: 200, height: 32, color: AppColors.surfaceContainerHigh),
              const SizedBox(height: AppSpacing.lg),
              Container(width: 250, height: 180, color: AppColors.surfaceContainerHigh),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

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
                Icon(Icons.qr_code_scanner_outlined, size: 64, color: AppColors.onSurfaceVariant.withAlpha(128)),
                const SizedBox(height: AppSpacing.lg),
                Text(message ?? 'Booking Not Found', style: AppTypography.h3, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text('This booking may no longer be available', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xl),
                AppButton(label: 'Back to Home', onPressed: () => context.go(AppRoutes.home), isExpanded: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
