import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';

import '../models/courier.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';

/// Rounded-square courier logo. Shows the real logo image
/// (`assets/images/couriers/<id>.png`) on a clean tile, falling back to a
/// package icon when no logo asset is present.
class CourierAvatar extends StatelessWidget {
  final Courier? courier;
  final double size;

  const CourierAvatar({super.key, required this.courier, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final c = courier;
    final radius = BorderRadius.circular(size * 0.29);

    if (c == null) return _fallback(context, radius);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(color: context.c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        c.logoAsset,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => _fallbackContent(),
      ),
    );
  }

  // Peach tile + package glyph, used while a courier has no logo asset yet.
  Widget _fallback(BuildContext context, BorderRadius radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.c.chipTint,
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      child: _fallbackContent(),
    );
  }

  Widget _fallbackContent() {
    return Icon(
      FeatherIcons.package,
      size: size * 0.46,
      color: AppColors.primaryDark,
    );
  }
}
