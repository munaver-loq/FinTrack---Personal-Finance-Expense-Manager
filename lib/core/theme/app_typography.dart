import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// FinTrack Typography based on Plus Jakarta Sans
class AppTypography {
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        fontSize: 44,
        fontWeight: FontWeight.w800,
        height: 52 / 44,
        letterSpacing: -0.88,
        color: AppColors.onSurface,
      );

  static TextStyle get displaySmall => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -0.32,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 34 / 26,
        letterSpacing: -0.26,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        letterSpacing: 0,
        color: AppColors.onSurface,
      );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
        letterSpacing: 0,
        color: AppColors.onSurface,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        letterSpacing: 0.16,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        letterSpacing: 0,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        letterSpacing: 0,
        color: AppColors.onSurface,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        letterSpacing: 0.12,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18 / 13,
        letterSpacing: 0.26,
        color: AppColors.onSurface,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 14 / 11,
        letterSpacing: 0.33,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        height: 12 / 10,
        letterSpacing: 0.5,
        color: AppColors.onSurfaceVariant,
      );
}
