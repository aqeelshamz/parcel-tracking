import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';

import '../theme/app_colors.dart';

/// The canonical milestones a parcel passes through, in order.
enum TrackingStage {
  orderCreated,
  courierPickedUp,
  originHub,
  inTransit,
  destinationHub,
  outForDelivery,
  delivered,
}

extension TrackingStageX on TrackingStage {
  String get label => switch (this) {
        TrackingStage.orderCreated => 'Order Created',
        TrackingStage.courierPickedUp => 'Courier Picked Up',
        TrackingStage.originHub => 'Origin Hub',
        TrackingStage.inTransit => 'In Transit',
        TrackingStage.destinationHub => 'Destination Hub',
        TrackingStage.outForDelivery => 'Out for Delivery',
        TrackingStage.delivered => 'Delivered',
      };

  IconData get icon => switch (this) {
        TrackingStage.orderCreated => FeatherIcons.fileText,
        TrackingStage.courierPickedUp => FeatherIcons.package,
        TrackingStage.originHub => FeatherIcons.server,
        TrackingStage.inTransit => FeatherIcons.truck,
        TrackingStage.destinationHub => FeatherIcons.mapPin,
        TrackingStage.outForDelivery => FeatherIcons.navigation,
        TrackingStage.delivered => FeatherIcons.checkCircle,
      };

  Color get accent => switch (this) {
        TrackingStage.delivered => AppColors.success,
        TrackingStage.outForDelivery => AppColors.primary,
        _ => AppColors.primary,
      };
}

/// A single scan / event in a shipment's history.
class TrackingEvent {
  final TrackingStage stage;
  final String location;
  final DateTime time;

  const TrackingEvent({
    required this.stage,
    required this.location,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'stage': stage.name,
        'location': location,
        'time': time.toIso8601String(),
      };

  factory TrackingEvent.fromJson(Map<String, dynamic> json) => TrackingEvent(
        stage: TrackingStage.values.firstWhere(
          (s) => s.name == json['stage'],
          orElse: () => TrackingStage.orderCreated,
        ),
        location: json['location'] as String? ?? '',
        time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
      );
}
