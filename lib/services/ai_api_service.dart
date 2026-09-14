// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';

// ── Response model ────────────────────────────────────────────────────────────

/// Parsed response from POST /predict.
class PredictResponse {
  /// Whether the API confidently detected a material.
  final bool detected;

  /// Non-null when [detected] is true.
  final PredictedMaterial? prediction;

  /// Optional component-level detections from the e-waste model.
  final List<DetectedComponent> components;

  /// Optional valuation / grading info.
  final ValuationInfo? valuation;

  const PredictResponse({
    required this.detected,
    this.prediction,
    this.components = const [],
    this.valuation,
  });

  factory PredictResponse.fromJson(Map<String, dynamic> json) {
    return PredictResponse(
      detected: json['detected'] as bool? ?? false,
      prediction: json['prediction'] != null
          ? PredictedMaterial.fromJson(
              json['prediction'] as Map<String, dynamic>,
            )
          : null,
      components: (json['components'] as List<dynamic>? ?? [])
          .map(
            (item) => DetectedComponent.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      valuation: json['valuation'] != null
          ? ValuationInfo.fromJson(json['valuation'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PredictedMaterial {
  /// Raw class key from the model, e.g. "PCB".
  final String className;

  /// Human-readable name, e.g. "PCB / E-Waste".
  final String displayName;

  /// Confidence score 0.0 – 1.0.
  final double confidence;

  const PredictedMaterial({
    required this.className,
    required this.displayName,
    required this.confidence,
  });

  factory PredictedMaterial.fromJson(Map<String, dynamic> json) {
    return PredictedMaterial(
      className: json['class'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DetectedComponent {
  final String name;
  final int count;

  const DetectedComponent({required this.name, required this.count});

  factory DetectedComponent.fromJson(Map<String, dynamic> json) {
    return DetectedComponent(
      name: json['name'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class ValuationInfo {
  final String grade;
  final double rateMinPerKg;
  final double rateMaxPerKg;
  final String currency;
  final String note;

  const ValuationInfo({
    required this.grade,
    required this.rateMinPerKg,
    required this.rateMaxPerKg,
    required this.currency,
    required this.note,
  });

  factory ValuationInfo.fromJson(Map<String, dynamic> json) {
    return ValuationInfo(
      grade: json['grade'] as String? ?? '',
      rateMinPerKg: (json['rate_min_per_kg'] as num?)?.toDouble() ?? 0.0,
      rateMaxPerKg: (json['rate_max_per_kg'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      note: json['note'] as String? ?? '',
    );
  }
}

// ── Typed errors ──────────────────────────────────────────────────────────────

sealed class PredictError {
  const PredictError();
}

/// Network failure, timeout, or server unreachable.
final class NetworkError extends PredictError {
  final String message;
  const NetworkError(this.message);
}

/// Server returned a non-200 status.
final class ServerError extends PredictError {
  final int statusCode;
  final String body;
  const ServerError(this.statusCode, this.body);
}

/// Response body could not be parsed.
final class ParseError extends PredictError {
  final String message;
  const ParseError(this.message);
}

// ── Result wrapper ────────────────────────────────────────────────────────────

sealed class PredictResult {
  const PredictResult();
}

final class PredictSuccess extends PredictResult {
  final PredictResponse response;
  const PredictSuccess(this.response);
}

final class PredictFailure extends PredictResult {
  final PredictError error;
  const PredictFailure(this.error);
}

// ── Service ───────────────────────────────────────────────────────────────────

/// Sends an image to the FastAPI /predict endpoint and returns a typed result.
///
/// All HTTP logic lives here — UI widgets only see [PredictResult].
class AiApiService {
  final http.Client _client;

  AiApiService({http.Client? client}) : _client = client ?? http.Client();

  /// POST the [image] to [ApiConfig.predictEndpoint] as multipart/form-data.
  /// Field name is "file" as required by the backend.
  Future<PredictResult> predict(XFile image) async {
    try {
      final uri = Uri.parse(ApiConfig.predictEndpoint);
      final request = http.MultipartRequest('POST', uri);

      final bytes = await image.readAsBytes();
      final filename = image.name.isNotEmpty ? image.name : 'scrap.jpg';
      final contentType = _guessContentType(filename);

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
          contentType: contentType,
        ),
      );

      print(
        '[AiApiService] POST ${ApiConfig.predictEndpoint} '
        '(${bytes.length} bytes, file: $filename)',
      );

      final streamed = await request.send().timeout(
        ApiConfig.requestTimeout,
        onTimeout: () => throw const NetworkError(
          'Request timed out. Check your connection.',
        ),
      );
      final response = await http.Response.fromStream(streamed);

      print('[AiApiService] ${response.statusCode}: ${response.body}');

      if (response.statusCode != 200) {
        return PredictFailure(ServerError(response.statusCode, response.body));
      }

      final Map<String, dynamic> json;
      try {
        json = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return const PredictFailure(
          ParseError('Could not parse server response.'),
        );
      }

      return PredictSuccess(PredictResponse.fromJson(json));
    } on NetworkError catch (e) {
      return PredictFailure(e);
    } catch (e) {
      return PredictFailure(NetworkError(e.toString()));
    }
  }

  MediaType _guessContentType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => MediaType('image', 'png'),
      'gif' => MediaType('image', 'gif'),
      'webp' => MediaType('image', 'webp'),
      _ => MediaType('image', 'jpeg'),
    };
  }

  void dispose() => _client.close();
}
