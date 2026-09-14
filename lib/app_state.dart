import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'mock_data.dart';
import 'services/ai_api_service.dart';
import 'services/location_service.dart';
import 'services/scrap_classifier_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  // ── Offline flag ───────────────────────────────────────────────────────
  bool _isOffline = false;
  bool get isOffline => _isOffline;

  void setOffline(bool value) {
    _isOffline = value;
    notifyListeners();
  }

  // ── User location ──────────────────────────────────────────────────────
  double? _userLatitude;
  double? _userLongitude;
  String _userLocationDescription = 'Tap to fetch GPS location';
  bool _isFetchingLocation = false;

  double? get userLatitude => _userLatitude;
  double? get userLongitude => _userLongitude;
  String get userLocationDescription => _userLocationDescription;
  bool get isFetchingLocation => _isFetchingLocation;

  Future<void> refreshUserLocation({bool allowFallback = true}) async {
    _isFetchingLocation = true;
    notifyListeners();

    try {
      final res = await LocationService.instance.fetchLocation(
        allowFallback: allowFallback,
      );
      _userLatitude = res.latitude;
      _userLongitude = res.longitude;
      _userLocationDescription = res.description;
      _handoverLocation = res.coordinatesString;
    } catch (_) {
      // Ignored, safe fallback is preserved
    } finally {
      _isFetchingLocation = false;
      notifyListeners();
    }
  }

  // ── API service ────────────────────────────────────────────────────────
  final AiApiService _apiService = AiApiService();

  // ── On-device classifier (fallback, kept for when backend is absent) ──
  final ScrapClassifierService _classifier = ScrapClassifierService();
  bool _classifierReady = false;

  bool get classifierReady => _classifierReady;
  bool get classifierAvailable => _classifier.isAvailable;
  String? get classifierError => _classifier.initError;

  /// Attempt to load the on-device TFLite model (non-fatal if absent).
  Future<void> initClassifier() async {
    await _classifier.initialize();
    _classifierReady = true;
    notifyListeners();
  }

  // ── Current scan session ───────────────────────────────────────────────
  String _scannedMaterial = MockScrap.material;
  double _weightKg = MockScrap.defaultWeightKg;
  double _ratePerKg = MockScrap.ratePerKg;
  double _aiConfidence = 0.0;
  RecyclerData? _selectedRecycler;
  String? _capturedImagePath;
  XFile? _capturedXFile;
  String? _handoverLocation;
  XFile? _handoverPhoto;

  XFile? get capturedXFile => _capturedXFile;
  String get scannedMaterial => _scannedMaterial;
  double get weightKg => _weightKg;
  double get ratePerKg => _ratePerKg;
  double get estimatedValue => _weightKg * _ratePerKg;

  bool get hasSupportedMaterial {
    return _ratePerKg > 0 &&
        MockRecyclers.rankedForMaterial(
          _scannedMaterial,
          userLat: _userLatitude,
          userLng: _userLongitude,
        ).isNotEmpty;
  }

  List<RecyclerData> get nearbyRecyclers {
    return MockRecyclers.rankedForMaterial(
      _scannedMaterial,
      userLat: _userLatitude,
      userLng: _userLongitude,
    );
  }

  double get aiConfidence => _aiConfidence;
  RecyclerData? get selectedRecycler => _selectedRecycler;
  String? get capturedImagePath => _capturedImagePath;
  String? get handoverLocation => _handoverLocation;
  XFile? get handoverPhoto => _handoverPhoto;

  void setHandoverLocation(String location) {
    _handoverLocation = location;
    notifyListeners();
  }
void setHandoverPhoto(XFile file) {
  _handoverPhoto = file;
  notifyListeners();
}

  void setCapturedImage(XFile file) {
    _capturedXFile = file;
    _capturedImagePath = file.path;
    notifyListeners();
  }

  void setCapturedImagePath(String? path) {
    _capturedImagePath = path;
    notifyListeners();
  }

  void setWeight(double w) {
    _weightKg = w;
    notifyListeners();
  }

  void setSelectedRecycler(RecyclerData r) {
    _selectedRecycler = r;
    notifyListeners();
  }

  /// Apply a prediction from the API (or on-device classifier).
  void applyApiPrediction(
  PredictedMaterial material, {
  List<DetectedComponent> components = const [],
  ValuationInfo? valuation,
}) {
  _scannedMaterial = material.displayName;
  _aiConfidence = material.confidence;

  _detectedComponents = components;
  _valuation = valuation;

  if (valuation != null && valuation.rateMinPerKg > 0) {
    _ratePerKg =
        (valuation.rateMinPerKg + valuation.rateMaxPerKg) / 2;
  } else {
    _ratePerKg = rateForMaterial(_scannedMaterial);
  }

  notifyListeners();
}

  /// Apply a prediction from the on-device classifier.
  void applyPrediction(ClassificationResult result) {
    _scannedMaterial = result.top.label;
    _aiConfidence = result.top.confidence;
    _ratePerKg = rateForMaterial(_scannedMaterial);
    notifyListeners();
  }

  /// Manually override material from the picker.
  void setMaterialManually(String displayLabel) {
    _scannedMaterial = displayLabel;
    _aiConfidence = 0.0;
    _ratePerKg = rateForMaterial(displayLabel);
    notifyListeners();
  }

  /// Call the FastAPI backend. Returns [PredictResult] for the caller to handle.
  Future<PredictResult> runApiInference() async {
    final xfile = _capturedXFile;
    if (xfile == null) {
      return const PredictFailure(NetworkError('No image selected.'));
    }
    final result = await _apiService.predict(xfile);
    if (result is PredictSuccess && result.response.detected) {
      applyApiPrediction(
  result.response.prediction!,
  components: result.response.components,
  valuation: result.response.valuation,
);
    }
    return result;
  }

  /// On-device TFLite inference (fallback path).
  Future<String?> runInference() async {
    final xfile = _capturedXFile;
    if (xfile == null) return 'No image captured.';
    if (!_classifier.isAvailable) {
      return _classifier.initError ?? 'Model not available.';
    }
    try {
      final result = await _classifier.classify(xfile);
      applyPrediction(result);
      return null;
    } on ScrapClassifierException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// Send user correction to the backend.
  Future<void> reportCorrection(String correctClass) async {
    final xfile = _capturedXFile;
    if (xfile == null) return;
    
    // Convert display name to backend class key
    // For simplicity, we can search allSelectableMaterials to find the exact match or just pass it as is.
    // The backend expects keys like "PCB", "Keyboard", etc., or we can map them back.
    // wait, backend EWASTE_VALUATIONS uses keys like "PCB", "Keyboard".
    // but app_state uses displayLabels.
    // Actually, in `lib/mock_data.dart`, does it export keys?
    // For now we will just send the displayLabel and let the backend handle it, or find the key.
    // Let's pass the correct_class to the backend.
    await _apiService.correct(xfile, correctClass);
  }

  // ── Earnings ledger ────────────────────────────────────────────────────
  final List<HandoverTransaction> _transactions = [
    HandoverTransaction.seed(
      receiptId: 'KC-2026-00123',
      material: 'Copper Wire',
      weightKg: 8,
      ratePerKg: 600,
      recyclerName: 'Recycler A',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    HandoverTransaction.seed(
      receiptId: 'KC-2026-00122',
      material: 'Aluminium',
      weightKg: 8,
      ratePerKg: 180,
      recyclerName: 'Recycler B',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    HandoverTransaction.seed(
      receiptId: 'KC-2026-00121',
      material: 'Brass',
      weightKg: 5,
      ratePerKg: 420,
      recyclerName: 'Recycler A',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    HandoverTransaction.seed(
      receiptId: 'KC-2026-00120',
      material: 'Iron',
      weightKg: 30,
      ratePerKg: 35,
      recyclerName: 'Recycler B',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  List<HandoverTransaction> get transactions =>
      List.unmodifiable(_transactions);

  void addTransaction(HandoverTransaction tx) {
  _transactions.insert(0, tx);
  saveTransactions();
  notifyListeners();
}
  List<DetectedComponent> _detectedComponents = [];
    ValuationInfo? _valuation;
    List<DetectedComponent> get detectedComponents =>
    List.unmodifiable(_detectedComponents);

ValuationInfo? get valuation => _valuation;

  double get todayEarnings {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.timestamp.year == now.year &&
            t.timestamp.month == now.month &&
            t.timestamp.day == now.day)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get weekEarnings {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _transactions
        .where((t) => t.timestamp.isAfter(cutoff))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthEarnings {
  final now = DateTime.now();

  return _transactions
      .where((t) =>
          t.timestamp.year == now.year &&
          t.timestamp.month == now.month)
      .fold(0.0, (sum, t) => sum + t.amount);
}

String generateReceiptId() {
  final n = 124 + _transactions.length;
  return 'KC-2026-${n.toString().padLeft(5, '0')}';
}

Future<void> saveTransactions() async {
  final prefs = await SharedPreferences.getInstance();

  final data = _transactions.map((tx) {
    return {
      'receiptId': tx.receiptId,
      'material': tx.material,
      'weightKg': tx.weightKg,
      'ratePerKg': tx.ratePerKg,
      'amount': tx.amount,
      'recyclerName': tx.recyclerName,
      'timestamp': tx.timestamp.toIso8601String(),
      'syncedOnline': tx.syncedOnline,
    };
  }).toList();

  await prefs.setString(
    'handover_transactions',
    jsonEncode(data),
  );
}

Future<void> loadTransactions() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('handover_transactions');

  if (raw == null) return;

  final decoded = jsonDecode(raw) as List;

  _transactions
    ..clear()
    ..addAll(
      decoded.map((item) {
        return HandoverTransaction(
          receiptId: item['receiptId'],
          material: item['material'],
          weightKg: (item['weightKg'] as num).toDouble(),
          ratePerKg: (item['ratePerKg'] as num).toDouble(),
          amount: (item['amount'] as num).toDouble(),
          recyclerName: item['recyclerName'],
          timestamp: DateTime.parse(item['timestamp']),
          syncedOnline: item['syncedOnline'],
        );
      }),
    );

  notifyListeners();
}
}