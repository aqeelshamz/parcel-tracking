import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import 'storage_service.dart';

/// Thrown on non-2xx responses.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// JSON HTTP client. Attaches the auth token from [StorageService] and throws
/// [ApiException] on failure.
///
/// NOTE: Not yet wired into the UI — the app currently runs on mock data in
/// `ShipmentsProvider`. This is the seam for a real tracking backend later.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> _headers() {
    final token = StorageService.getString(StorageService.kAuthToken);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) async {
    final res = await _client
        .get(Uri.parse('${Constants.apiBaseUrl}$path'), headers: _headers())
        .timeout(Constants.apiTimeout);
    return _decode(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await _client
        .post(
          Uri.parse('${Constants.apiBaseUrl}$path'),
          headers: _headers(),
          body: jsonEncode(body),
        )
        .timeout(Constants.apiTimeout);
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    final body = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final message = body is Map && body['message'] is String
          ? body['message'] as String
          : 'Request failed';
      throw ApiException(res.statusCode, message);
    }
    return body;
  }
}
