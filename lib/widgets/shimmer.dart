import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// A lightweight shimmer that sweeps a soft highlight across its [child].
/// No external package — just an animated gradient shader.
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = bounds.width * (_c.value * 2 - 1);
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0x00FFFFFF),
                Color(0x80FFFFFF),
                Color(0x00FFFFFF),
              ],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlideGradient(dx),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double dx;
  const _SlideGradient(this.dx);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(dx, 0, 0);
}

/// A neutral placeholder block used to compose skeleton screens.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 12,
    this.radius = 7,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.c.skeleton,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Skeleton stand-in for a [ShipmentCard].
class ShipmentSkeleton extends StatelessWidget {
  const ShipmentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.c.border, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonBox(width: 50, height: 50, radius: 15),
                const SizedBox(width: 13),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(width: 140, height: 15),
                    SizedBox(height: 8),
                    SkeletonBox(width: 100, height: 12),
                  ],
                ),
                const Spacer(),
                const SkeletonBox(width: 70, height: 22, radius: 11),
              ],
            ),
            const SizedBox(height: 16),
            const SkeletonBox(height: 6, radius: 3),
            const SizedBox(height: 13),
            const SkeletonBox(width: 200, height: 12),
          ],
        ),
      ),
    );
  }
}
