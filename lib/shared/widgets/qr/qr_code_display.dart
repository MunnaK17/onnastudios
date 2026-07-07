import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class FullScreenQrCode extends StatelessWidget {
  const FullScreenQrCode({
    super.key,
    required this.qrCodeValue,
    required this.bookingId,
    this.className,
    this.scheduleTime,
    this.onClose,
  });

  final String qrCodeValue;
  final String bookingId;
  final String? className;
  final String? scheduleTime;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onClose ?? () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.onSurface,
                  ),
                  const Spacer(),
                  Text(
                    'Check-in QR',
                    style: AppTypography.h3,
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Balance the close button
                ],
              ),
            ),

            // Content
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // QR Code
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: qrCodeValue,
                          version: QrVersions.auto,
                          size: 350, // 25% larger (was 280)
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black, // Dark black for better scanning
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black, // Dark black for better scanning
                          ),
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                          padding: EdgeInsets.zero,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withAlpha(51),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'Show this QR code to the instructor for check-in',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (className != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          className!,
                          style: AppTypography.h3,
                          textAlign: TextAlign.center,
                        ),
                      ],

                      if (scheduleTime != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          scheduleTime!,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Booking ID: ${bookingId.substring(0, 8)}...',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border(
                  top: BorderSide(color: AppColors.surfaceVariant),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Verified by Onna Studios',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.secondary,
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

/// Mini QR Code for embedding in booking cards
class MiniQrCode extends StatelessWidget {
  const MiniQrCode({
    super.key,
    required this.qrCodeValue,
    this.size = 60,
    this.onTap,
  });

  final String qrCodeValue;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: QrImageView(
          data: qrCodeValue,
          version: QrVersions.auto,
          size: size - 8,
          backgroundColor: Colors.white,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Colors.black, // Dark black for better scanning
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Colors.black, // Dark black for better scanning
          ),
          errorCorrectionLevel: QrErrorCorrectLevel.H,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
