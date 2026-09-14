// ── Mock data — single source of truth for the prototype ─────────────────

import 'services/location_service.dart';

class MockScrap {
  static const String material = 'Copper Wire';
  static const double defaultWeightKg = 12.0;
  static const double ratePerKg = 600.0;

  static double estimatedValue(double kg) => kg * ratePerKg;
}

class MockRecyclers {
  static const List<RecyclerData> all = [
    // ── Copper ─────────────────────────────────────────────
    RecyclerData(
      id: 'CU-A',
      name: 'GreenLoop Metals',
      authorized: true,
      ratePerKg: 600,
      distanceKm: 2.4,
      pickupAvailable: true,
      acceptsMaterial: 'Copper Wire',
      isBestMatch: false,
      address: 'Plot 42, Okhla Industrial Area Phase II',
      locality: 'Okhla, South Delhi',
      latitude: 28.5355,
      longitude: 77.2680,
      phone: '+91 98101 23456',
    ),
    RecyclerData(
      id: 'CU-B',
      name: 'EcoMetal Recycler',
      authorized: true,
      ratePerKg: 585,
      distanceKm: 1.7,
      pickupAvailable: false,
      acceptsMaterial: 'Copper Wire',
      isBestMatch: false,
      address: 'Shop 14, Mayapuri Metal Market Phase I',
      locality: 'Mayapuri, West Delhi',
      latitude: 28.6320,
      longitude: 77.1210,
      phone: '+91 98202 34567',
    ),

    // ── Aluminium ───────────────────────────────────────────
    RecyclerData(
      id: 'AL-A',
      name: 'Metro Aluminium Recovery',
      authorized: true,
      ratePerKg: 180,
      distanceKm: 2.3,
      pickupAvailable: true,
      acceptsMaterial: 'Aluminium',
      isBestMatch: false,
      address: 'G-11, Wazirpur Industrial Area',
      locality: 'Wazirpur, North Delhi',
      latitude: 28.6980,
      longitude: 77.1650,
      phone: '+91 98303 45678',
    ),

    // ── Brass ───────────────────────────────────────────────
    RecyclerData(
      id: 'BR-A',
      name: 'Circular Brass Works',
      authorized: true,
      ratePerKg: 420,
      distanceKm: 2.7,
      pickupAvailable: true,
      acceptsMaterial: 'Brass',
      isBestMatch: false,
      address: 'B-84, Naraina Industrial Area Phase I',
      locality: 'Naraina, West Delhi',
      latitude: 28.6250,
      longitude: 77.1400,
      phone: '+91 98404 56789',
    ),

    // ── Iron ────────────────────────────────────────────────
    RecyclerData(
      id: 'IR-A',
      name: 'Green Iron Recycling',
      authorized: true,
      ratePerKg: 35,
      distanceKm: 1.8,
      pickupAvailable: true,
      acceptsMaterial: 'Iron',
      isBestMatch: false,
      address: 'C-22, Kirti Nagar Industrial Area',
      locality: 'Kirti Nagar, West Delhi',
      latitude: 28.6500,
      longitude: 77.1480,
      phone: '+91 98505 67890',
    ),

    // ── PCB / E-Waste ──────────────────────────────────────
    RecyclerData(
      id: 'PCB-A',
      name: 'E-Cycle Clean Recovery Hub',
      authorized: true,
      ratePerKg: 260,
      distanceKm: 2.1,
      pickupAvailable: true,
      acceptsMaterial: 'PCB / E-Waste',
      isBestMatch: false,
      address: 'Plot 78, Okhla E-Waste Recycling Zone',
      locality: 'Okhla Phase III, New Delhi',
      latitude: 28.5410,
      longitude: 77.2750,
      phone: '+91 99111 88220',
    ),
    RecyclerData(
      id: 'PCB-B',
      name: 'Urban Tech E-Waste Recycler',
      authorized: true,
      ratePerKg: 250,
      distanceKm: 1.4,
      pickupAvailable: false,
      acceptsMaterial: 'PCB / E-Waste',
      isBestMatch: false,
      address: 'Shed 5, Nehru Place Hardware Complex',
      locality: 'Nehru Place, South Delhi',
      latitude: 28.5490,
      longitude: 77.2530,
      phone: '+91 99222 77331',
    ),
    RecyclerData(
      id: 'PCB-C',
      name: 'Circular Electronics Recycling',
      authorized: true,
      ratePerKg: 255,
      distanceKm: 3.2,
      pickupAvailable: true,
      acceptsMaterial: 'PCB / E-Waste',
      isBestMatch: false,
      address: 'Sector 8, Electronic City Hub',
      locality: 'Noida Phase II / Delhi NCR',
      latitude: 28.5300,
      longitude: 77.3800,
      phone: '+91 99333 66442',
    ),

    // ── Battery ─────────────────────────────────────────────
    RecyclerData(
      id: 'BAT-A',
      name: 'SafeCell Certified Battery Recycling',
      authorized: true,
      ratePerKg: 100,
      distanceKm: 2.8,
      pickupAvailable: true,
      acceptsMaterial: 'Battery',
      isBestMatch: false,
      address: 'Unit 3, Anand Parbat Industrial Area',
      locality: 'Anand Parbat, Central Delhi',
      latitude: 28.6650,
      longitude: 77.1720,
      phone: '+91 99444 55553',
    ),
    RecyclerData(
      id: 'BAT-B',
      name: 'Eco Battery Recovery Corp',
      authorized: true,
      ratePerKg: 95,
      distanceKm: 1.9,
      pickupAvailable: false,
      acceptsMaterial: 'Battery',
      isBestMatch: false,
      address: 'Plot 19, Mayapuri Industrial Area Phase II',
      locality: 'Mayapuri, West Delhi',
      latitude: 28.6360,
      longitude: 77.1180,
      phone: '+91 99555 44664',
    ),
    RecyclerData(
      id: 'BAT-C',
      name: 'GreenCell Lithium & Lead Recyclers',
      authorized: true,
      ratePerKg: 98,
      distanceKm: 3.5,
      pickupAvailable: true,
      acceptsMaterial: 'Battery',
      isBestMatch: false,
      address: 'Plot 102, Badarpur Industrial Estate',
      locality: 'Badarpur, South East Delhi',
      latitude: 28.5020,
      longitude: 77.3010,
      phone: '+91 99666 33775',
    ),

    // ── Mobile phones ───────────────────────────────────────
    RecyclerData(
      id: 'MOB-A',
      name: 'ReTech Electronics Exchange',
      authorized: true,
      ratePerKg: 180,
      distanceKm: 1.8,
      pickupAvailable: true,
      acceptsMaterial: 'Mobile Phone',
      isBestMatch: false,
      address: '2nd Floor, Eros Electronic Plaza, Nehru Place',
      locality: 'Nehru Place, New Delhi',
      latitude: 28.5485,
      longitude: 77.2515,
      phone: '+91 99777 22886',
    ),
    RecyclerData(
      id: 'MOB-B',
      name: 'GreenGadget Circular Recovery',
      authorized: true,
      ratePerKg: 165,
      distanceKm: 2.6,
      pickupAvailable: true,
      acceptsMaterial: 'Mobile Phone',
      isBestMatch: false,
      address: 'Plot 66, Mohan Cooperative Industrial Estate',
      locality: 'Mathura Road, New Delhi',
      latitude: 28.5120,
      longitude: 77.2980,
      phone: '+91 99888 11997',
    ),

    // ── Keyboard E-Waste ────────────────────────────────────
    RecyclerData(
      id: 'KB-A',
      name: 'Peripheral Cycle & Polymer Recovery',
      authorized: true,
      ratePerKg: 110,
      distanceKm: 2.0,
      pickupAvailable: true,
      acceptsMaterial: 'Keyboard',
      isBestMatch: false,
      address: 'Shop 29, Computer Market, Nehru Place',
      locality: 'Nehru Place, South Delhi',
      latitude: 28.5470,
      longitude: 77.2500,
      phone: '+91 98111 00223',
    ),
    RecyclerData(
      id: 'KB-B',
      name: 'CleanTech Hardware Recyclers',
      authorized: true,
      ratePerKg: 95,
      distanceKm: 3.1,
      pickupAvailable: false,
      acceptsMaterial: 'Keyboard',
      isBestMatch: false,
      address: 'Plot 15, Patparganj Industrial Area',
      locality: 'Patparganj, East Delhi',
      latitude: 28.6290,
      longitude: 77.3090,
      phone: '+91 98222 00334',
    ),

    // ── Mouse E-Waste ───────────────────────────────────────
    RecyclerData(
      id: 'MS-A',
      name: 'MicroTech E-Scrap Solutions',
      authorized: true,
      ratePerKg: 90,
      distanceKm: 1.9,
      pickupAvailable: true,
      acceptsMaterial: 'Mouse',
      isBestMatch: false,
      address: 'G-7, Wazirpur Computer Hardware Complex',
      locality: 'Wazirpur, North Delhi',
      latitude: 28.6960,
      longitude: 77.1630,
      phone: '+91 98333 00445',
    ),
    RecyclerData(
      id: 'MS-B',
      name: 'E-Cycle Clean Recovery Hub',
      authorized: true,
      ratePerKg: 85,
      distanceKm: 2.1,
      pickupAvailable: true,
      acceptsMaterial: 'Mouse',
      isBestMatch: false,
      address: 'Plot 78, Okhla E-Waste Recycling Zone',
      locality: 'Okhla Phase III, New Delhi',
      latitude: 28.5410,
      longitude: 77.2750,
      phone: '+91 99111 88220',
    ),

    // ── Light Bulb ──────────────────────────────────────────
    RecyclerData(
      id: 'LB-A',
      name: 'LumiCycle Glass & Electronic Recovery',
      authorized: true,
      ratePerKg: 40,
      distanceKm: 2.5,
      pickupAvailable: true,
      acceptsMaterial: 'Light Bulb',
      isBestMatch: false,
      address: 'Plot 31, Naraina Industrial Area Phase II',
      locality: 'Naraina, West Delhi',
      latitude: 28.6280,
      longitude: 77.1360,
      phone: '+91 98444 00556',
    ),

    // ── Metal scrap ─────────────────────────────────────────
    RecyclerData(
      id: 'MET-A',
      name: 'Metro Metal Works',
      authorized: true,
      ratePerKg: 42,
      distanceKm: 2.2,
      pickupAvailable: true,
      acceptsMaterial: 'Metal Scrap',
      isBestMatch: false,
      address: 'Plot 55, Mayapuri Industrial Area Phase I',
      locality: 'Mayapuri, West Delhi',
      latitude: 28.6340,
      longitude: 77.1240,
      phone: '+91 98555 00667',
    ),

    // ── Plastic ─────────────────────────────────────────────
    RecyclerData(
      id: 'PL-A',
      name: 'EcoPolymer Clean Recyclers',
      authorized: true,
      ratePerKg: 25,
      distanceKm: 2.7,
      pickupAvailable: true,
      acceptsMaterial: 'Plastic',
      isBestMatch: false,
      address: 'Plot 12, Bawana Industrial Area Sector 2',
      locality: 'Bawana, North West Delhi',
      latitude: 28.7950,
      longitude: 77.0420,
      phone: '+91 98666 00778',
    ),

    // ── Paper ───────────────────────────────────────────────
    RecyclerData(
      id: 'PA-A',
      name: 'Capital Paper Pulp & Recycling',
      authorized: true,
      ratePerKg: 15,
      distanceKm: 1.5,
      pickupAvailable: true,
      acceptsMaterial: 'Paper',
      isBestMatch: false,
      address: 'Chawri Bazar Paper Market Hub',
      locality: 'Old Delhi, Central Delhi',
      latitude: 28.6505,
      longitude: 77.2280,
      phone: '+91 98777 00889',
    ),

    // ── Glass ───────────────────────────────────────────────
    RecyclerData(
      id: 'GL-A',
      name: 'Veritas Glass Recovery Plant',
      authorized: true,
      ratePerKg: 12,
      distanceKm: 3.0,
      pickupAvailable: true,
      acceptsMaterial: 'Glass',
      isBestMatch: false,
      address: 'Industrial Plot 9, Sahibabad Industrial Area',
      locality: 'Sahibabad / Delhi Border',
      latitude: 28.6700,
      longitude: 77.3400,
      phone: '+91 98888 00990',
    ),
  ];

  /// Get recyclers ranked for material, optionally calculating dynamic distance from user GPS.
  static List<RecyclerData> rankedForMaterial(
    String material, {
    double? userLat,
    double? userLng,
  }) {
    final lower = material.toLowerCase();
    // Match exact material or aliases
    List<RecyclerData> matches = all.where((r) {
      if (r.acceptsMaterial == material) return true;
      if (material == 'PCB' && r.acceptsMaterial == 'PCB / E-Waste') return true;
      if (material == 'PCB / E-Waste' && r.acceptsMaterial == 'PCB') return true;
      if (lower.contains('capacitor') ||
          lower.contains('charger') ||
          lower.contains('adapter') ||
          lower.contains('conditioner') ||
          lower.contains('remote') ||
          lower.contains('electronic') ||
          lower.contains('pcb')) {
        return r.acceptsMaterial == 'PCB / E-Waste';
      }
      if (lower.contains('battery')) {
        return r.acceptsMaterial == 'Battery';
      }
      if (lower.contains('mobile') || lower.contains('phone')) {
        return r.acceptsMaterial == 'Mobile Phone' || r.acceptsMaterial == 'PCB / E-Waste';
      }
      if (lower.contains('metal')) {
        return r.acceptsMaterial == 'Metal Scrap' ||
            r.acceptsMaterial == 'Copper Wire' ||
            r.acceptsMaterial == 'Aluminium' ||
            r.acceptsMaterial == 'Iron';
      }
      return false;
    }).toList();

    // Safe fallback: If no direct category matches, provide certified e-waste & metal facilities
    if (matches.isEmpty) {
      matches = all
          .where((r) =>
              r.acceptsMaterial == 'PCB / E-Waste' ||
              r.acceptsMaterial == 'Metal Scrap')
          .toList();
    }

    final mapped = matches.map((r) {
      if (userLat != null && userLng != null) {
        final dist = LocationService.instance.distanceBetweenKm(
          startLat: userLat,
          startLng: userLng,
          endLat: r.latitude,
          endLng: r.longitude,
        );
        return r.copyWithDistance(dist);
      }
      return r;
    }).toList();

    mapped.sort((a, b) {
      // 1. Proximity first when GPS is available
      if (userLat != null && userLng != null) {
        final distDiff = a.distanceKm.compareTo(b.distanceKm);
        if (distDiff != 0) return distDiff;
      }

      // 2. Higher price
      if (a.ratePerKg != b.ratePerKg) {
        return b.ratePerKg.compareTo(a.ratePerKg);
      }

      // 3. Pickup available
      if (a.pickupAvailable != b.pickupAvailable) {
        return a.pickupAvailable ? -1 : 1;
      }

      // 4. Default distance
      return a.distanceKm.compareTo(b.distanceKm);
    });

    // Mark the top item as best match
    if (mapped.isNotEmpty) {
      mapped[0] = mapped[0].copyWithDistance(
        mapped[0].distanceKm,
        bestMatch: true,
      );
    }

    return mapped;
  }
}

class RecyclerData {
  final String id;
  final String name;
  final bool authorized;
  final int ratePerKg;
  final double distanceKm;
  final bool pickupAvailable;
  final String acceptsMaterial;
  final bool isBestMatch;
  final String address;
  final String locality;
  final double latitude;
  final double longitude;
  final String phone;

  const RecyclerData({
    required this.id,
    required this.name,
    required this.authorized,
    required this.ratePerKg,
    required this.distanceKm,
    required this.pickupAvailable,
    required this.acceptsMaterial,
    required this.isBestMatch,
    this.address = 'Industrial Scrap Yard, Sector 4',
    this.locality = 'Industrial Area',
    this.latitude = 28.5355,
    this.longitude = 77.2680,
    this.phone = '+91 98765 43210',
  });

  RecyclerData copyWithDistance(double newDistanceKm, {bool? bestMatch}) {
    return RecyclerData(
      id: id,
      name: name,
      authorized: authorized,
      ratePerKg: ratePerKg,
      distanceKm: newDistanceKm,
      pickupAvailable: pickupAvailable,
      acceptsMaterial: acceptsMaterial,
      isBestMatch: bestMatch ?? isBestMatch,
      address: address,
      locality: locality,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
    );
  }
}

class MockPrices {
  static const List<PriceEntry> all = [
    PriceEntry(material: 'Copper Wire',  ratePerKg: 600, trend: 1),
    PriceEntry(material: 'Aluminium',    ratePerKg: 180, trend: 0),
    PriceEntry(material: 'Brass',        ratePerKg: 420, trend: 1),
    PriceEntry(material: 'Iron',         ratePerKg: 35,  trend: -1),
    PriceEntry(material: 'PCB / E-Waste', ratePerKg: 260, trend: 1),
    PriceEntry(material: 'Mobile Phone', ratePerKg: 180, trend: 1),
    PriceEntry(material: 'Lead Battery', ratePerKg: 95,  trend: -1),
    PriceEntry(material: 'Keyboard',     ratePerKg: 110, trend: 0),
    PriceEntry(material: 'Mouse',        ratePerKg: 90,  trend: 0),
    PriceEntry(material: 'Light Bulb',   ratePerKg: 40,  trend: 0),
  ];
}

class PriceEntry {
  final String material;
  final int ratePerKg;
  final int trend; // 1 = up, 0 = stable, -1 = down

  const PriceEntry({
    required this.material,
    required this.ratePerKg,
    required this.trend,
  });
}

// ── Transaction model ────────────────────────────────────────────────────

class HandoverTransaction {
  final String receiptId;
  final String material;
  final double weightKg;
  final double ratePerKg;
  final double amount;
  final String recyclerName;
  final DateTime timestamp;
  final bool syncedOnline;

  const HandoverTransaction({
    required this.receiptId,
    required this.material,
    required this.weightKg,
    required this.ratePerKg,
    required this.amount,
    required this.recyclerName,
    required this.timestamp,
    required this.syncedOnline,
  });

  factory HandoverTransaction.seed({
    required String receiptId,
    required String material,
    required double weightKg,
    required double ratePerKg,
    required String recyclerName,
    required DateTime timestamp,
    bool syncedOnline = true,
  }) {
    return HandoverTransaction(
      receiptId: receiptId,
      material: material,
      weightKg: weightKg,
      ratePerKg: ratePerKg,
      amount: weightKg * ratePerKg,
      recyclerName: recyclerName,
      timestamp: timestamp,
      syncedOnline: syncedOnline,
    );
  }
}

// ── Per-material mock rates ──────────────────────────────────────────────────

/// Returns the mock rate (₹/kg) for a given display label.
double rateForMaterial(String displayLabel) {
  const rates = {
    'Copper Wire': 600.0,
    'Aluminium': 180.0,
    'Brass': 420.0,
    'Iron': 35.0,
    'PCB / E-Waste': 260.0,
    'Capacitor / Electronic Component': 210.0,
    'Charger / Power Adapter': 140.0,
    'Air Conditioner / Remote Scrap': 95.0,
    'Switch Board / Electrical Scrap': 75.0,
    'Battery': 95.0,
    'PCB': 260.0,
    'Metal Scrap': 40.0,
    'Mobile Phone': 180.0,
    'Keyboard': 110.0,
    'Mouse': 90.0,
    'Light Bulb': 40.0,
    'Plastic': 25.0,
    'Paper': 15.0,
    'Glass': 10.0,
  };
  return rates[displayLabel] ?? 50.0;
}

// ── Selectable materials for manual override ─────────────────────────────────

/// All materials available for manual selection (picker bottom sheet).
const List<String> allSelectableMaterials = [
  'Copper Wire',
  'Aluminium',
  'Brass',
  'Iron',
  'PCB / E-Waste',
  'Capacitor / Electronic Component',
  'Charger / Power Adapter',
  'Air Conditioner / Remote Scrap',
  'Switch Board / Electrical Scrap',
  'Battery',
  'Metal Scrap',
  'Mobile Phone',
  'Keyboard',
  'Mouse',
  'Light Bulb',
  'Plastic',
  'Paper',
  'Glass',
];
