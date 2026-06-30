import 'package:flutter/material.dart';

/// A courier/carrier. Brand color + initials drive the logo placeholder.
class Courier {
  final String id;
  final String name;
  final String initials;
  final Color color;

  const Courier({
    required this.id,
    required this.name,
    required this.initials,
    required this.color,
  });

  /// Logo image path, e.g. `assets/images/couriers/fedex.png`.
  String get logoAsset => 'assets/images/couriers/$id.png';

  /// Catalog of supported couriers.
  static const List<Courier> all = [
    Courier(id: 'fedex', name: 'FedEx', initials: 'Fx', color: Color(0xFF4D148C)),
    Courier(id: 'dhl', name: 'DHL', initials: 'DH', color: Color(0xFFD40511)),
    Courier(id: 'ups', name: 'UPS', initials: 'UP', color: Color(0xFF6B3F1D)),
    Courier(id: 'usps', name: 'USPS', initials: 'US', color: Color(0xFF333366)),
    Courier(id: 'bluedart', name: 'Blue Dart', initials: 'BD', color: Color(0xFF003F87)),
    Courier(id: 'delhivery', name: 'Delhivery', initials: 'Dv', color: Color(0xFFE2231A)),
    Courier(id: 'indiapost', name: 'India Post', initials: 'IP', color: Color(0xFFB8132B)),
    Courier(id: 'dtdc', name: 'DTDC', initials: 'DT', color: Color(0xFF00529B)),
    Courier(id: 'aramex', name: 'Aramex', initials: 'Ax', color: Color(0xFFE2001A)),
    Courier(id: 'amazon', name: 'Amazon', initials: 'Az', color: Color(0xFFFF9900)),
  ];

  static Courier? byId(String? id) {
    if (id == null) return null;
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Naive carrier guess from a tracking-number shape. Reference-quality
  /// heuristic for the "Auto-detect courier" affordance — not authoritative.
  static Courier? autoDetect(String tracking) {
    final t = tracking.trim().toUpperCase();
    if (t.isEmpty) return null;
    final digits = RegExp(r'^\d+$');
    if (t.startsWith('1Z')) return byId('ups');
    if (t.startsWith('JD') || (digits.hasMatch(t) && t.length == 10)) {
      return byId('dhl');
    }
    if (digits.hasMatch(t) && (t.length == 12 || t.length == 15)) {
      return byId('fedex');
    }
    if (digits.hasMatch(t) && (t.length == 20 || t.length == 22)) {
      return byId('usps');
    }
    if (t.startsWith('BD') || t.startsWith('TRK')) return byId('bluedart');
    if (t.startsWith('TBA')) return byId('amazon');
    return byId('delhivery');
  }
}
