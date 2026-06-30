import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_palette.dart';

/// Centralised typography. Swap [display] to restyle the whole app.
///
/// Uses Plus Jakarta Sans to match the Latelogic reference design.
class AppFonts {
  AppFonts._();

  /// Base font family used everywhere.
  static TextStyle display({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color ?? const Color(0xFF16181D),
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Full text theme built on Plus Jakarta Sans, tuned for a clean hierarchy.
  static TextTheme textTheme(TextTheme base, AppPalette p) {
    return GoogleFonts.plusJakartaSansTextTheme(base).copyWith(
      displaySmall: display(
          size: 30, weight: FontWeight.w800, height: 1.15, color: p.textPrimary),
      headlineMedium: display(
          size: 24, weight: FontWeight.w800, height: 1.2, color: p.textPrimary),
      headlineSmall: display(
          size: 20, weight: FontWeight.w700, height: 1.25, color: p.textPrimary),
      titleLarge: display(size: 18, weight: FontWeight.w700, color: p.textPrimary),
      titleMedium:
          display(size: 16, weight: FontWeight.w600, color: p.textPrimary),
      bodyLarge: display(
          size: 15, weight: FontWeight.w500, height: 1.45, color: p.textPrimary),
      bodyMedium: display(
        size: 14,
        weight: FontWeight.w500,
        height: 1.45,
        color: p.textSecondary,
      ),
      bodySmall: display(
        size: 12.5,
        weight: FontWeight.w500,
        color: p.textMuted,
      ),
      labelLarge: display(size: 15, weight: FontWeight.w700, color: p.textPrimary),
    );
  }
}
