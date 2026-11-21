import 'package:flutter/material.dart';

/// FinTrack Electric Midnight Fintech Color Palette
/// Derived exactly from Stitch UI specification and DESIGN.md
class AppColors {
  // Surface Hierarchy
  static const Color background = Color(0xFF0D1320);
  static const Color surface = Color(0xFF0D1320);
  static const Color surfaceDim = Color(0xFF070B14);
  static const Color surfaceBright = Color(0xFF333948);
  static const Color surfaceContainerLowest = Color(0xFF080E1B);
  static const Color surfaceContainerLow = Color(0xFF161B29);
  static const Color surfaceContainer = Color(0xFF1A1F2D);
  static const Color surfaceContainerHigh = Color(0xFF242A38);
  static const Color surfaceContainerHighest = Color(0xFF2F3543);
  static const Color surfaceVariant = Color(0xFF2F3543);

  // Content / Foreground
  static const Color onSurface = Color(0xFFDDE2F5);
  static const Color onSurfaceVariant = Color(0xFFBCC9CE);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color inverseSurface = Color(0xFFDDE2F5);
  static const Color inverseOnSurface = Color(0xFF2A303F);
  static const Color outline = Color(0xFF869398);
  static const Color outlineVariant = Color(0xFF3D494D);
  static const Color borderStroke = Color(0xFF1E293B);

  // Primary (Electric Cyan)
  static const Color primary = Color(0xFF4CD6FB);
  static const Color onPrimary = Color(0xFF003642);
  static const Color primaryContainer = Color(0xFF00B4D8);
  static const Color onPrimaryContainer = Color(0xFF00414F);
  static const Color primaryFixed = Color(0xFFB3EBFF);
  static const Color primaryFixedDim = Color(0xFF4CD6FB);
  static const Color surfaceTint = Color(0xFF4CD6FB);

  // Secondary (Sky Blue)
  static const Color secondary = Color(0xFF7BD0FF);
  static const Color onSecondary = Color(0xFF00354A);
  static const Color secondaryContainer = Color(0xFF00A6E0);
  static const Color onSecondaryContainer = Color(0xFF00374D);
  static const Color secondaryFixed = Color(0xFFC4E7FF);
  static const Color secondaryFixedDim = Color(0xFF7BD0FF);

  // Tertiary (Mint Emerald)
  static const Color tertiary = Color(0xFF4EDEA3);
  static const Color onTertiary = Color(0xFF003824);
  static const Color tertiaryContainer = Color(0xFF19BC84);
  static const Color onTertiaryContainer = Color(0xFF00442D);
  static const Color tertiaryFixed = Color(0xFF6FFBBE);
  static const Color tertiaryFixedDim = Color(0xFF4EDEA3);

  // Semantic Alerts
  static const Color error = Color(0xFFFFB4AB);
  static const Color alertDanger = Color(0xFFF43F5E);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);
  static const Color alertWarning = Color(0xFFF59E0B);
  static const Color warningAmber = Color(0xFFFBBF24);

  // Cybernetic Glows
  static const BoxShadow primaryGlow = BoxShadow(
    color: Color(0x594CD6FB),
    blurRadius: 18,
    offset: Offset(0, 4),
  );

  static const BoxShadow subtleGlow = BoxShadow(
    color: Color(0x1400B4D8),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x66000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
}
