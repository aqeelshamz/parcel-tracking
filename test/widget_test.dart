// Unit + widget tests for the logic and key UI states of the three screens.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parcel_tracking/models/courier.dart';
import 'package:parcel_tracking/models/shipment.dart';
import 'package:parcel_tracking/models/tracking_event.dart';
import 'package:parcel_tracking/theme/app_theme.dart';
import 'package:parcel_tracking/utils/formatters.dart';
import 'package:parcel_tracking/widgets/empty_state.dart';
import 'package:parcel_tracking/widgets/status_badge.dart';
import 'package:parcel_tracking/widgets/tracking_timeline.dart';

void main() {
  group('Courier', () {
    test('autoDetect recognises UPS 1Z prefix', () {
      expect(Courier.autoDetect('1Z9831AB0420')?.id, 'ups');
    });

    test('autoDetect returns null for empty input', () {
      expect(Courier.autoDetect('   '), isNull);
    });

    test('byId round-trips a known courier', () {
      expect(Courier.byId('fedex')?.name, 'FedEx');
    });
  });

  group('Shipment', () {
    test('progress is 1.0 when delivered', () {
      const s = Shipment(
        id: 'x',
        name: 'Box',
        trackingNumber: 'T1',
        courierId: 'fedex',
        status: ShipmentStatus.delivered,
      );
      expect(s.progress, 1.0);
    });

    test('toJson/fromJson preserves fields', () {
      final s = Shipment(
        id: 'x',
        name: 'Box',
        trackingNumber: 'T1',
        courierId: 'dhl',
        status: ShipmentStatus.inTransit,
        events: [
          TrackingEvent(
            stage: TrackingStage.inTransit,
            location: 'Pune',
            time: DateTime(2026, 2, 28, 18),
          ),
        ],
      );
      final round = Shipment.fromJson(s.toJson());
      expect(round.name, 'Box');
      expect(round.courierId, 'dhl');
      expect(round.status, ShipmentStatus.inTransit);
      expect(round.events.single.stage, TrackingStage.inTransit);
    });
  });

  group('Formatters', () {
    test('formats month/day and 12-hour time', () {
      final d = DateTime(2026, 2, 28, 18, 0);
      expect(Formatters.monthDay(d), 'Feb 28');
      expect(Formatters.time(d), '6:00 PM');
      expect(Formatters.dayMonthTime(d), '28 Feb, 6:00 PM');
    });
  });

  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

  group('UI states', () {
    testWidgets('empty state shows title, message and CTA', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(EmptyState(
        title: 'No Package added yet',
        message: 'Track your shipments by adding a tracking number.',
        ctaLabel: 'Track Your First Shipment',
        onCta: () => tapped = true,
      )));

      expect(find.text('No Package added yet'), findsOneWidget);
      expect(find.text('Track Your First Shipment'), findsOneWidget);

      await tester.tap(find.text('Track Your First Shipment'));
      expect(tapped, isTrue);
    });

    testWidgets('status badge renders its label', (tester) async {
      await tester.pumpWidget(
          wrap(const StatusBadge(status: ShipmentStatus.outForDelivery)));
      expect(find.text('Out for Delivery'), findsOneWidget);
    });

    testWidgets('timeline lists reached and pending stages', (tester) async {
      final shipment = Shipment(
        id: 't',
        name: 'JBL Speaker',
        trackingNumber: 'TRK1',
        courierId: 'fedex',
        status: ShipmentStatus.outForDelivery,
        events: [
          TrackingEvent(
            stage: TrackingStage.outForDelivery,
            location: 'Kochi, KL',
            time: DateTime(2026, 2, 28, 18),
          ),
          TrackingEvent(
            stage: TrackingStage.orderCreated,
            location: 'New Delhi, DL',
            time: DateTime(2026, 2, 25, 10),
          ),
        ],
      );
      await tester.pumpWidget(
          wrap(SingleChildScrollView(child: TrackingTimeline(shipment: shipment))));

      expect(find.text('Out for Delivery'), findsOneWidget); // current
      expect(find.text('Order Created'), findsOneWidget); // completed
      expect(find.text('Delivered'), findsOneWidget); // pending placeholder
      expect(find.text('Kochi, KL'), findsOneWidget);
    });
  });
}
