import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/shipment.dart';
import '../models/tracking_event.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

/// Owns the list of tracked shipments. Mock/in-memory for now, persisted to
/// [StorageService] as JSON. `ApiService` is the seam for a real backend later.
class ShipmentsProvider extends ChangeNotifier {
  final List<Shipment> _shipments = [];
  bool _refreshing = false;
  DateTime? _lastUpdated;

  bool get isRefreshing => _refreshing;
  DateTime? get lastUpdated => _lastUpdated;

  List<Shipment> get active =>
      _shipments.where((s) => !s.archived).toList(growable: false);

  List<Shipment> get archived =>
      _shipments.where((s) => s.archived).toList(growable: false);

  Shipment? byId(String id) {
    for (final s in _shipments) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Loads persisted shipments, seeding sample data on first launch.
  void load() {
    final raw = StorageService.getString(StorageService.kShipments);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _shipments
          ..clear()
          ..addAll(list.map((e) => Shipment.fromJson(e as Map<String, dynamic>)));
      } catch (_) {
        // Corrupt cache — fall through to seed.
      }
    }
    if (!StorageService.getBool(StorageService.kSeeded)) {
      _shipments.addAll(_seed());
      StorageService.setBool(StorageService.kSeeded, true);
      _persist();
    }
    notifyListeners();
  }

  void add(Shipment shipment) {
    _shipments.insert(0, shipment);
    _persist();
    notifyListeners();
  }

  void setArchived(String id, bool archived) {
    final i = _shipments.indexWhere((s) => s.id == id);
    if (i == -1) return;
    _shipments[i] = _shipments[i].copyWith(archived: archived);
    _persist();
    notifyListeners();
  }

  void remove(String id) {
    _shipments.removeWhere((s) => s.id == id);
    _persist();
    notifyListeners();
  }

  void updateName(String id, String name) {
    final i = _shipments.indexWhere((s) => s.id == id);
    if (i == -1 || name.trim().isEmpty) return;
    _shipments[i] = _shipments[i].copyWith(name: name.trim());
    _persist();
    notifyListeners();
  }

  /// Pushes a shipment straight to delivered, appending the final scan.
  void markDelivered(String id) {
    final i = _shipments.indexWhere((s) => s.id == id);
    if (i == -1) return;
    final s = _shipments[i];
    if (s.status == ShipmentStatus.delivered) return;
    final loc = s.latestEvent?.location ?? 'Destination';
    _shipments[i] = s.copyWith(
      status: ShipmentStatus.delivered,
      events: [
        TrackingEvent(
            stage: TrackingStage.delivered, location: loc, time: DateTime.now()),
        ...s.events,
      ],
    );
    _persist();
    notifyListeners();
  }

  /// Simulated sync — advances one in-flight shipment to its next stage so the
  /// timeline visibly changes, then stamps the refresh time.
  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    notifyListeners();
    await Future.delayed(Constants.mockLatency);
    _advanceOne();
    _lastUpdated = DateTime.now();
    _refreshing = false;
    _persist();
    notifyListeners();
  }

  /// Moves the most recently updated active shipment one stage forward.
  void _advanceOne() {
    final i = _shipments.indexWhere(
        (s) => !s.archived && s.status != ShipmentStatus.delivered);
    if (i == -1) return;
    final s = _shipments[i];
    final reached = s.latestEvent?.stage.index ?? -1;
    if (reached >= TrackingStage.values.length - 1) return;
    final next = TrackingStage.values[reached + 1];
    final loc = s.latestEvent?.location ?? 'In transit';
    final status = switch (next) {
      TrackingStage.delivered => ShipmentStatus.delivered,
      TrackingStage.outForDelivery => ShipmentStatus.outForDelivery,
      TrackingStage.orderCreated ||
      TrackingStage.courierPickedUp =>
        ShipmentStatus.pending,
      _ => ShipmentStatus.inTransit,
    };
    _shipments[i] = s.copyWith(
      status: status,
      events: [
        TrackingEvent(stage: next, location: loc, time: DateTime.now()),
        ...s.events,
      ],
    );
  }

  void _persist() {
    final raw = jsonEncode(_shipments.map((s) => s.toJson()).toList());
    StorageService.setString(StorageService.kShipments, raw);
  }

  // ---- Sample data ----------------------------------------------------------

  List<Shipment> _seed() {
    final now = DateTime.now();
    DateTime ago(int days, int hours) =>
        now.subtract(Duration(days: days, hours: hours));

    return [
      Shipment(
        id: 's_jbl',
        name: 'JBL Speaker',
        trackingNumber: 'TRK849201834',
        courierId: 'fedex',
        status: ShipmentStatus.outForDelivery,
        expectedDelivery: now.add(const Duration(hours: 5)),
        events: [
          TrackingEvent(
              stage: TrackingStage.outForDelivery,
              location: 'Kochi, KL',
              time: ago(0, 3)),
          TrackingEvent(
              stage: TrackingStage.destinationHub,
              location: 'Bangalore, KA',
              time: ago(1, 6)),
          TrackingEvent(
              stage: TrackingStage.inTransit,
              location: 'Mumbai, MH',
              time: ago(2, 12)),
          TrackingEvent(
              stage: TrackingStage.originHub,
              location: 'Gurugram, HR',
              time: ago(3, 4)),
          TrackingEvent(
              stage: TrackingStage.courierPickedUp,
              location: 'New Delhi, DL',
              time: ago(4, 8)),
          TrackingEvent(
              stage: TrackingStage.orderCreated,
              location: 'New Delhi, DL',
              time: ago(4, 14)),
        ],
      ),
      Shipment(
        id: 's_kindle',
        name: 'Kindle Paperwhite',
        trackingNumber: '1Z9831AB0420',
        courierId: 'ups',
        status: ShipmentStatus.inTransit,
        expectedDelivery: now.add(const Duration(days: 2, hours: 3)),
        events: [
          TrackingEvent(
              stage: TrackingStage.inTransit,
              location: 'Pune, MH',
              time: ago(0, 9)),
          TrackingEvent(
              stage: TrackingStage.originHub,
              location: 'Hyderabad, TG',
              time: ago(1, 2)),
          TrackingEvent(
              stage: TrackingStage.courierPickedUp,
              location: 'Hyderabad, TG',
              time: ago(1, 10)),
          TrackingEvent(
              stage: TrackingStage.orderCreated,
              location: 'Hyderabad, TG',
              time: ago(1, 16)),
        ],
      ),
      Shipment(
        id: 's_sneakers',
        name: 'Running Sneakers',
        trackingNumber: 'BD55120097IN',
        courierId: 'bluedart',
        status: ShipmentStatus.delivered,
        archived: true,
        expectedDelivery: ago(2, 0),
        events: [
          TrackingEvent(
              stage: TrackingStage.delivered,
              location: 'Chennai, TN',
              time: ago(2, 5)),
          TrackingEvent(
              stage: TrackingStage.outForDelivery,
              location: 'Chennai, TN',
              time: ago(2, 11)),
          TrackingEvent(
              stage: TrackingStage.destinationHub,
              location: 'Chennai, TN',
              time: ago(3, 6)),
          TrackingEvent(
              stage: TrackingStage.inTransit,
              location: 'Coimbatore, TN',
              time: ago(4, 9)),
          TrackingEvent(
              stage: TrackingStage.orderCreated,
              location: 'Coimbatore, TN',
              time: ago(5, 12)),
        ],
      ),
    ];
  }
}
