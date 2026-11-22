import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../core/network/app_exception.dart';

/// Thin wrapper over [http.Client] that communicates with the Node.js Express
/// backend.
///
/// Responsibilities:
/// - Builds request headers (JSON content type + optional JWT bearer token)
/// - Executes GET / POST / PATCH / DELETE requests against [AppConstants.baseUrl]
/// - Maps HTTP status codes to typed [AppException] subclasses
/// - Extracts error messages from JSON error bodies
class ApiClient {
  /// Creates an [ApiClient] with the given HTTP client and preferences store.
  ///
  /// The [prefs] instance is used to read the stored JWT token for authenticated
  /// requests.
  ApiClient(this._client, this._prefs);

  /// Underlying HTTP client used to make network requests.
  final http.Client _client;

  /// SharedPreferences instance used to retrieve the stored authentication token.
  final _prefs;

  /// Builds the headers map for a request.
  ///
  /// Includes `Content-Type: application/json`, `Accept: application/json`, and,
  /// when a token is present in [SharedPreferences], an `Authorization: Bearer`
  /// header.
  Future<Map<String, String>> _headers() async {
    final token = _prefs.getString(AppConstants.tokenKey) ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Sends a GET request to `[baseUrl]$path`.
  ///
  /// Returns the [http.Response] on success (2xx). Throws a typed
  /// [AppException] on client or server errors, and [FetchDataException] on
  /// network failures.
  Future<http.Response> get(String path) async {
    final headers = await _headers();
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}$path'),
        headers: headers,
      );
      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FetchDataException('Network error: $e');
    }
  }

  /// Sends a POST request to `[baseUrl]$path` with an optional JSON [body].
  ///
  /// Returns the [http.Response] on success (2xx). Throws a typed
  /// [AppException] on client or server errors, and [FetchDataException] on
  /// network failures.
  Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    final headers = await _headers();
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseUrl}$path'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FetchDataException('Network error: $e');
    }
  }

  /// Sends a PATCH request to `[baseUrl]$path` with an optional JSON [body].
  ///
  /// Returns the [http.Response] on success (2xx). Throws a typed
  /// [AppException] on client or server errors, and [FetchDataException] on
  /// network failures.
  Future<http.Response> patch(String path, {Map<String, dynamic>? body}) async {
    final headers = await _headers();
    try {
      final response = await _client.patch(
        Uri.parse('${AppConstants.baseUrl}$path'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FetchDataException('Network error: $e');
    }
  }

  /// Sends a DELETE request to `[baseUrl]$path`.
  ///
  /// Returns the [http.Response] on success (2xx). Throws a typed
  /// [AppException] on client or server errors, and [FetchDataException] on
  /// network failures.
  Future<http.Response> delete(String path) async {
    final headers = await _headers();
    try {
      final response = await _client.delete(
        Uri.parse('${AppConstants.baseUrl}$path'),
        headers: headers,
      );
      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FetchDataException('Network error: $e');
    }
  }

  /// Inspects an [http.Response] and either returns it (for 200/201) or throws
  /// the appropriate [AppException] subclass based on the status code.
  ///
  /// - 200, 201: returns the response
  /// - 400, 401, 403, 404: throws [BadRequestException]
  /// - 500, 502, 503, 504: throws [UnauthorisedException]
  /// - anything else: throws [FetchDataException]
  http.Response _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return response;
      case 400:
      case 401:
      case 403:
      case 404:
        throw BadRequestException(
          _extractMessage(response.body),
          response.statusCode,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        throw UnauthorisedException(
          _extractMessage(response.body),
          response.statusCode,
        );
      default:
        throw FetchDataException(
          'Unexpected error (${response.statusCode})',
          response.statusCode,
        );
    }
  }

  /// Attempts to extract a human-readable `message` field from a JSON response
  /// [body].
  ///
  /// Falls back to returning the raw [body] string if parsing fails or no
  /// `message` field is present.
  String _extractMessage(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map && json['message'] is String) {
        return json['message'] as String;
      }
    } catch (_) {}
    return body;
  }
}
