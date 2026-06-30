import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';

import '../models/courier.dart';
import '../models/shipment.dart';
import '../models/tracking_event.dart';
import '../theme/app_palette.dart';
import '../utils/formatters.dart';
import 'courier_avatar.dart';
import 'pressable.dart';
import 'status_badge.dart';

/// List card for a single shipment: courier logo, name, tracking number,
/// status badge, last update + ETA and a thin progress bar.
class ShipmentCard extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ShipmentCard({
    super.key,
    required this.shipment,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final courier = Courier.byId(shipment.courierId);
    final last = shipment.latestEvent;

    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
          decoration: BoxDecoration(
            color: context.c.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.c.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: context.c.shadow,
                blurRadius: 22,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'courier-${shipment.id}',
                    child: CourierAvatar(courier: courier, size: 50),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shipment.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: context.c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              courier?.name ?? 'Courier',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: context.c.textSecondary,
                              ),
                            ),
                            const _Dot(),
                            Flexible(
                              child: Text(
                                shipment.trackingNumber,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: context.c.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: shipment.status, compact: true),
                ],
              ),
              const SizedBox(height: 15),
              _ProgressBar(value: shipment.progress, color: shipment.status.color),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    last?.stage.icon ?? FeatherIcons.mapPin,
                    size: 15,
                    color: context.c.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      last == null
                          ? 'Awaiting first scan'
                          : '${last.stage.label} • ${last.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: context.c.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _etaLabel(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.c.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }

  String _etaLabel() {
    if (shipment.status == ShipmentStatus.delivered) {
      final t = shipment.latestEvent?.time;
      return t == null ? 'Delivered' : 'Delivered ${Formatters.relative(t)}';
    }
    final eta = shipment.expectedDelivery;
    if (eta == null) return '';
    return 'ETA ${Formatters.monthDay(eta)}';
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: context.c.textMuted,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.04, 1)),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => LinearProgressIndicator(
          value: v,
          minHeight: 6,
          backgroundColor: context.c.surfaceMuted,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    );
  }
}
