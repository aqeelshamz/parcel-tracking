import 'package:flutter/material.dart';

/// Theme-varying (neutral) colors. Brand colors live in [AppColors] since they
/// are constant across light/dark; everything that flips between themes lives
/// here and is read via `context.c`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color panel;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color shadow;
  final Color trackInactive;
  final Color skeleton;
  final Color chipTint; // icon-tile background
  final Color elevated; // raised surface (e.g. active tab pill)

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.panel,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.shadow,
    required this.trackInactive,
    required this.skeleton,
    required this.chipTint,
    required this.elevated,
  });

  static const light = AppPalette(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF4F5F7),
    panel: Color(0xFFFAFAFB),
    border: Color(0xFFECEDF0),
    textPrimary: Color(0xFF16181D),
    textSecondary: Color(0xFF9398A1),
    textMuted: Color(0xFFAEB3BB),
    shadow: Color(0x0D101828),
    trackInactive: Color(0xFFD9DCE1),
    skeleton: Color(0xFFE9EBEF),
    chipTint: Color(0xFFFFEDE2),
    elevated: Color(0xFFFFFFFF),
  );

  static const dark = AppPalette(
    background: Color(0xFF0E0F12),
    surface: Color(0xFF17191F),
    surfaceMuted: Color(0xFF202329),
    panel: Color(0xFF15171C),
    border: Color(0xFF2A2D34),
    textPrimary: Color(0xFFF3F4F6),
    textSecondary: Color(0xFF9BA1AC),
    textMuted: Color(0xFF6E7480),
    shadow: Color(0x40000000),
    trackInactive: Color(0xFF353941),
    skeleton: Color(0xFF24272E),
    chipTint: Color(0xFF37221D), // warm dark tile (orange @ ~14% over surface)
    elevated: Color(0xFF2E323A),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? panel,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? shadow,
    Color? trackInactive,
    Color? skeleton,
    Color? chipTint,
    Color? elevated,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      panel: panel ?? this.panel,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      shadow: shadow ?? this.shadow,
      trackInactive: trackInactive ?? this.trackInactive,
      skeleton: skeleton ?? this.skeleton,
      chipTint: chipTint ?? this.chipTint,
      elevated: elevated ?? this.elevated,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      trackInactive: Color.lerp(trackInactive, other.trackInactive, t)!,
      skeleton: Color.lerp(skeleton, other.skeleton, t)!,
      chipTint: Color.lerp(chipTint, other.chipTint, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
    );
  }
}

/// Shorthand: `context.c.textPrimary`.
extension PaletteContext on BuildContext {
  AppPalette get c => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
