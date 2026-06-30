import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';

import '../models/shipment.dart';
import '../models/tracking_event.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../utils/formatters.dart';

enum _Kind { future, current, completed }

class _Entry {
  final TrackingStage stage;
  final String? location;
  final DateTime? time;
  final _Kind kind;
  const _Entry(this.stage, this.location, this.time, this.kind);
}

/// Vertical, easy-to-scan tracking timeline. Reached events are filled and
/// connected by an accent line; the latest event is highlighted with an icon
/// node; not-yet-reached stages appear above as muted, outlined placeholders.
class TrackingTimeline extends StatelessWidget {
  final Shipment shipment;

  const TrackingTimeline({super.key, required this.shipment});

  List<_Entry> _buildEntries() {
    final events = shipment.events; // newest-first
    final reachedIndex = events.isEmpty ? -1 : events.first.stage.index;
    final delivered = shipment.status == ShipmentStatus.delivered;

    final entries = <_Entry>[];

    // Not-yet-reached stages, shown above (highest stage at the very top).
    if (!delivered) {
      for (var i = TrackingStage.values.length - 1; i > reachedIndex; i--) {
        final stage = TrackingStage.values[i];
        entries.add(_Entry(
          stage,
          null,
          stage == TrackingStage.delivered ? shipment.expectedDelivery : null,
          _Kind.future,
        ));
      }
    }

    // Actual events: first is the current milestone.
    for (var i = 0; i < events.length; i++) {
      final e = events[i];
      entries.add(_Entry(
        e.stage,
        e.location,
        e.time,
        i == 0 ? _Kind.current : _Kind.completed,
      ));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries();
    // A segment between two entries is grey when the upper entry hasn't been
    // reached yet, otherwise accent. Computing colours here keeps each row's
    // above/below halves perfectly matched so the rail reads as one line.
    Color? segmentColor(int upper) =>
        entries[upper].kind == _Kind.future ? context.c.trackInactive : AppColors.primary;

    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineRow(
            entry: entries[i],
            aboveColor: i == 0 ? null : segmentColor(i - 1),
            belowColor: i == entries.length - 1 ? null : segmentColor(i),
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final _Entry entry;
  final Color? aboveColor; // line from row top to the node (null on first row)
  final Color? belowColor; // line from the node to row bottom (null on last)

  const _TimelineRow({
    required this.entry,
    required this.aboveColor,
    required this.belowColor,
  });

  @override
  Widget build(BuildContext context) {
    final isFuture = entry.kind == _Kind.future;
    final isCurrent = entry.kind == _Kind.current;
    final accent = entry.stage == TrackingStage.delivered && isCurrent
        ? AppColors.success
        : AppColors.primary;

    const nodeCenterY = 16.0; // distance from row top to node centre & title centre

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date / time column.
          SizedBox(
            width: 62,
            child: Padding(
              padding: const EdgeInsets.only(top: 6, right: 10),
              child: entry.time == null
                  ? Text(
                      'Pending',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: context.c.textMuted.withValues(alpha: 0.8),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.monthDay(entry.time!),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isFuture
                                ? context.c.textMuted
                                : context.c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          Formatters.time(entry.time!),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: context.c.textMuted,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          // Node + continuous connector rail.
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Segment above the node (row top → node top).
                Container(
                  width: 2.5,
                  height: (nodeCenterY - _nodeSize(entry.kind) / 2)
                      .clamp(0.0, double.infinity),
                  color: aboveColor ?? Colors.transparent,
                ),
                _Node(kind: entry.kind, icon: entry.stage.icon, accent: accent),
                // Segment below the node (node bottom → row bottom).
                Expanded(
                  child: Container(
                    width: 2.5,
                    color: belowColor ?? Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          // Title + location.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 14, top: 6, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.stage.label,
                    style: TextStyle(
                      fontSize: isCurrent ? 15.5 : 14.5,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700,
                      color: isFuture
                          ? context.c.textMuted
                          : context.c.textPrimary,
                    ),
                  ),
                  if (entry.location != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.location!,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: context.c.textSecondary,
                      ),
                    ),
                  ] else if (entry.kind == _Kind.future) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.stage == TrackingStage.delivered
                          ? 'Estimated delivery'
                          : 'Upcoming',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.c.textMuted.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Diameter of each node kind — used to align the connector rail flush.
double _nodeSize(_Kind kind) => switch (kind) {
      _Kind.current => 32,
      _Kind.completed => 14,
      _Kind.future => 20,
    };

class _Node extends StatelessWidget {
  final _Kind kind;
  final IconData icon;
  final Color accent;

  const _Node({required this.kind, required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    final size = _nodeSize(kind);
    switch (kind) {
      case _Kind.current:
        // Filled accent disc with an icon and a single soft peach ring,
        // matching the reference's box-shadow:0 0 0 5px (accent 16% over white).
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.22), // soft halo, theme-safe
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(icon, size: 17, color: Colors.white),
        );
      case _Kind.completed:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        );
      case _Kind.future:
        // Hollow grey ring; the pending "Delivered" node carries a faint check.
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: context.c.surface,
            shape: BoxShape.circle,
            border: Border.all(color: context.c.trackInactive, width: 2),
          ),
          child: Icon(FeatherIcons.check, size: 11, color: context.c.textMuted),
        );
    }
  }
}
