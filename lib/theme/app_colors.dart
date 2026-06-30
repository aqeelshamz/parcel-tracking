import 'package:flutter/material.dart';

/// Brand colors — constant across light/dark. Theme-varying neutral colors live
/// in [AppPalette] and are read via `context.c`.
class AppColors {
  AppColors._();

  // Brand (matched to the Latelogic reference).
  static const Color primary = Color(0xFFFB5A12); // vivid orange
  static const Color primaryDark = Color(0xFFF2530F); // gradient end
  static const Color primaryTint = Color(0xFFFFEDE2); // soft peach (glow/halo)

  // Status.
  static const Color success = Color(0xFF22A565); // delivered
  static const Color warning = Color(0xFFFB5A12); // out for delivery (brand)
  static const Color info = Color(0xFF3B82F6); // in transit (alt)

  // Snackbar/toast background — fixed charcoal that reads on light or dark.
  static const Color toast = Color(0xFF23262D);
}
