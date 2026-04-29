import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiClient {
  const ApiClient({required this.config, http.Client? client})
    : _client = client;

  final AppConfig config;
  final http.Client? _client;

  Uri phpEndpoint(String scriptName) {
    return config.endpoint(scriptName);
  }

  Future<Object?> postJson({
    required String scriptName,
    required Map<String, Object?> body,
    required String failureMessage,
    String? invalidMessage,
    bool allowEmptyResponse = true,
  }) async {
    final client = _client ?? http.Client();

    try {
      final response = await client
          .post(
            phpEndpoint(scriptName),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=utf-8',
              'Connection': 'Close',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      final responseBody = utf8.decode(
        response.bodyBytes,
        allowMalformed: true,
      );

      final decoded = decodeResponse(
        responseBody,
        invalidMessage: invalidMessage ?? 'Resposta invalida do servidor.',
        allowEmptyResponse: allowEmptyResponse,
      );

      if (decoded is Map<String, dynamic>) {
        final success = decoded['sucesso'];
        if (success == false) {
          final message = decoded['mensagem']?.toString().trim();
          throw ApiClientException(
            message == null || message.isEmpty ? failureMessage : message,
          );
        }
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiClientException('$failureMessage (${response.statusCode}).');
      }

      return decoded;
    } on ApiClientException {
      rethrow;
    } catch (error) {
      throw ApiClientException('$failureMessage: $error');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  Object? decodeResponse(
    String responseBody, {
    required String invalidMessage,
    bool allowEmptyResponse = true,
  }) {
    final trimmedBody = responseBody.trim();
    if (trimmedBody.isEmpty) {
      if (allowEmptyResponse) {
        return null;
      }

      throw ApiClientException(invalidMessage);
    }

    try {
      return jsonDecode(trimmedBody);
    } on FormatException {
      final jsonSlice = _extractJsonSlice(trimmedBody);
      if (jsonSlice != null) {
        try {
          return jsonDecode(jsonSlice);
        } on FormatException {
          // Use the diagnostic message below with a preview of the raw body.
        }
      }

      throw ApiClientException(
        '$invalidMessage Trecho recebido: ${_previewResponse(trimmedBody)}',
      );
    }
  }

  String? _extractJsonSlice(String responseBody) {
    final firstArray = responseBody.indexOf('[');
    final firstObject = responseBody.indexOf('{');

    final starts = [firstArray, firstObject].where((index) => index >= 0);
    if (starts.isEmpty) {
      return null;
    }

    final start = starts.reduce((a, b) => a < b ? a : b);
    final end = responseBody[start] == '['
        ? responseBody.lastIndexOf(']')
        : responseBody.lastIndexOf('}');

    if (end <= start) {
      return null;
    }

    return responseBody.substring(start, end + 1);
  }

  String _previewResponse(String responseBody) {
    final normalized = responseBody.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 180) {
      return normalized;
    }
    return '${normalized.substring(0, 180)}...';
  }
}

class ApiClientException implements Exception {
  const ApiClientException(this.message);

  final String message;

  @override
  String toString() => message;
}
