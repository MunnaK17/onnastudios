import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const headingFamily = 'Epilogue';
  static const bodyFamily = 'Manrope';

  static const h1 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 48,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  static const h2 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 36,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  static const h3 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  static const bodyLg = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
    color: AppColors.onSurfaceVariant,
  );

  static const bodyMd = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
    color: AppColors.onSurfaceVariant,
  );

  static const bodySm = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.onSurfaceVariant,
  );

  static const labelCaps = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 1.2,
    color: AppColors.onSurfaceVariant,
  );

  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: h1,
      headlineLarge: h2,
      headlineMedium: h3,
      titleLarge: h3,
      bodyLarge: bodyLg,
      bodyMedium: bodyMd,
      bodySmall: bodySm,
      labelLarge: labelCaps,
      labelMedium: labelCaps,
      labelSmall: labelCaps,
    );
  }
}
