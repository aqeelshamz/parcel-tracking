import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'tracking_event.dart';

/// High-level shipment status, derived from the latest tracking event but
/// stored for cheap list rendering.
enum ShipmentStatus {
  pending,
  inTransit,
  outForDelivery,
  delivered,
  exception,
}

extension ShipmentStatusX on ShipmentStatus {
  String get label => switch (this) {
        ShipmentStatus.pending => 'Pending',
        ShipmentStatus.inTransit => 'In Transit',
        ShipmentStatus.outForDelivery => 'Out for Delivery',
        ShipmentStatus.delivered => 'Delivered',
        ShipmentStatus.exception => 'Exception',
      };

  Color get color => switch (this) {
        ShipmentStatus.delivered => AppColors.success,
        ShipmentStatus.outForDelivery => AppColors.warning,
        ShipmentStatus.inTransit => AppColors.info,
        ShipmentStatus.exception => const Color(0xFFE5484D),
        ShipmentStatus.pending => const Color(0xFF8A909C), // theme-neutral grey
      };
}

/// A tracked parcel.
class Shipment {
  final String id;
  final String name;
  final String trackingNumber;
  final String courierId;
  final ShipmentStatus status;
  final DateTime? expectedDelivery;
  final bool notifyEnabled;
  final bool archived;
  final List<TrackingEvent> events;

  const Shipment({
    required this.id,
    required this.name,
    required this.trackingNumber,
    required this.courierId,
    required this.status,
    this.expectedDelivery,
    this.notifyEnabled = true,
    this.archived = false,
    this.events = const [],
  });

  /// Latest event (history is stored newest-first).
  TrackingEvent? get latestEvent => events.isEmpty ? null : events.first;

  /// 0..1 progress along the 7-stage pipeline.
  double get progress {
    if (status == ShipmentStatus.delivered) return 1;
    final reached = latestEvent?.stage.index ?? 0;
    return (reached + 1) / TrackingStage.values.length;
  }

  Shipment copyWith({
    String? name,
    String? trackingNumber,
    String? courierId,
    ShipmentStatus? status,
    DateTime? expectedDelivery,
    bool? notifyEnabled,
    bool? archived,
    List<TrackingEvent>? events,
  }) {
    return Shipment(
      id: id,
      name: name ?? this.name,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      courierId: courierId ?? this.courierId,
      status: status ?? this.status,
      expectedDelivery: expectedDelivery ?? this.expectedDelivery,
      notifyEnabled: notifyEnabled ?? this.notifyEnabled,
      archived: archived ?? this.archived,
      events: events ?? this.events,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'trackingNumber': trackingNumber,
        'courierId': courierId,
        'status': status.name,
        'expectedDelivery': expectedDelivery?.toIso8601String(),
        'notifyEnabled': notifyEnabled,
        'archived': archived,
        'events': events.map((e) => e.toJson()).toList(),
      };

  factory Shipment.fromJson(Map<String, dynamic> json) => Shipment(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Shipment',
        trackingNumber: json['trackingNumber'] as String? ?? '',
        courierId: json['courierId'] as String? ?? 'fedex',
        status: ShipmentStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => ShipmentStatus.pending,
        ),
        expectedDelivery: DateTime.tryParse(
            json['expectedDelivery'] as String? ?? ''),
        notifyEnabled: json['notifyEnabled'] as bool? ?? true,
        archived: json['archived'] as bool? ?? false,
        events: (json['events'] as List<dynamic>? ?? [])
            .map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
