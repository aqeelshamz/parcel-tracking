import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';

/// Circular icon button used in headers. Flat soft-gray by default; pass
/// [primary] for the orange filled treatment used by primary actions (e.g. +).
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final bool spinning;
  final bool primary;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.spinning = false,
    this.primary = false,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: primary ? AppColors.primary : context.c.surfaceMuted,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        child: SizedBox(
          width: size,
          height: size,
          child: spinning
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                )
              : Icon(
                  icon,
                  size: 20,
                  color: primary ? Colors.white : context.c.textPrimary,
                ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
