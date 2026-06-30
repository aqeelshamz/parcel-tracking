import 'package:flutter/material.dart';

import '../models/shipment.dart';

/// Pill badge colored by shipment status, with a leading dot.
class StatusBadge extends StatelessWidget {
  final ShipmentStatus status;
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        // Translucent so it reads on a light card or a dark one.
        color: status.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: compact ? 11.5 : 12.5,
          fontWeight: FontWeight.w700,
          color: status.color,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
