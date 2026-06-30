import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The empty-state parcel: the kraft-box asset over a soft brand halo, gently
/// bobbing to feel alive.
class ParcelIllustration extends StatefulWidget {
  final double size;

  const ParcelIllustration({super.key, this.size = 132});

  @override
  State<ParcelIllustration> createState() => _ParcelIllustrationState();
}

class _ParcelIllustrationState extends State<ParcelIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft halo behind the box.
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryTint.withValues(alpha: 0.9),
                  AppColors.primaryTint.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _c,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_c.value);
              return Transform.translate(
                offset: Offset(0, -3 + t * 6), // bob ±3px
                child: child,
              );
            },
            child: Image.asset(
              'assets/images/box.png',
              width: size * 0.78,
              height: size * 0.78,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ],
      ),
    );
  }
}
