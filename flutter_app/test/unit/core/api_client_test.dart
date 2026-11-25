import 'dart:convert';

import 'package:flutter_app/core/constants/app_constants.dart';
import 'package:flutter_app/core/network/api_client.dart';
import 'package:flutter_app/core/network/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late http.Request lastRequest;
  late http.Response Function(http.Request) responder;

  setUp(() {
    responder = (_) => http.Response('{}', 200);
  });

  Future<ApiClient> createClient({String? token}) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      if (token != null) AppConstants.tokenKey: token,
    });
    final prefs = await SharedPreferences.getInstance();
    return ApiClient(
      MockClient((request) async {
        lastRequest = request;
        return responder(request);
      }),
      prefs,
    );
  }

  group('request construction', () {
    test('GET uses the base URL and sends JSON headers plus bearer token',
        () async {
      final client = await createClient(token: 'jwt-123');

      final response = await client.get('/api/tasks');

      expect(response.statusCode, 200);
      expect(lastRequest.method, 'GET');
      expect(
        lastRequest.url.toString(),
        '${AppConstants.baseUrl}/api/tasks',
      );
      expect(lastRequest.headers['Content-Type'], 'application/json');
      expect(lastRequest.headers['Accept'], 'application/json');
      expect(lastRequest.headers['Authorization'], 'Bearer jwt-123');
    });

    test('omits Authorization when no token is stored', () async {
      final client = await createClient();

      await client.get('/api/auth/me');

      expect(lastRequest.headers.containsKey('Authorization'), isFalse);
    });

    test('POST JSON-encodes the body', () async {
      final client = await createClient();

      await client.post(
        '/api/auth/login',
        body: <String, dynamic>{'email': 'a@b.com', 'password': 'secret'},
      );

      expect(lastRequest.method, 'POST');
      expect(jsonDecode(lastRequest.body), <String, dynamic>{
        'email': 'a@b.com',
        'password': 'secret',
      });
    });

    test('PATCH JSON-encodes the body and targets the given path', () async {
      final client = await createClient();

      await client.patch('/api/tasks/9', body: <String, dynamic>{
        'isCompleted': true,
      });

      expect(lastRequest.method, 'PATCH');
      expect(lastRequest.url.path, '/api/tasks/9');
      expect(jsonDecode(lastRequest.body), <String, dynamic>{
        'isCompleted': true,
      });
    });

    test('DELETE sends no body', () async {
      final client = await createClient();

      await client.delete('/api/tasks/9');

      expect(lastRequest.method, 'DELETE');
      expect(lastRequest.body, isEmpty);
    });
  });

  group('response handling', () {
    test('returns 200 and 201 responses unchanged', () async {
      final client = await createClient();
      responder = (_) => http.Response('{"success":true}', 201);

      final created = await client.post('/api/tasks');

      expect(created.statusCode, 201);
      expect(created.body, '{"success":true}');
    });

    test('maps 400/401/403/404 to BadRequestException with message', () async {
      final client = await createClient();
      for (final statusCode in <int>[400, 401, 403, 404]) {
        responder = (_) => http.Response(
              jsonEncode(<String, dynamic>{'message': 'Request rejected'}),
              statusCode,
            );

        expect(
          client.get('/api/tasks'),
          throwsA(
            isA<BadRequestException>()
                .having((e) => e.message, 'message', 'Request rejected')
                .having((e) => e.statusCode, 'statusCode', statusCode),
          ),
        );
      }
    });

    test('falls back to the raw body when the error is not JSON', () async {
      final client = await createClient();
      responder = (_) => http.Response('Gateway unavailable', 502);

      expect(
        client.get('/api/tasks'),
        throwsA(
          isA<UnauthorisedException>()
              .having((e) => e.message, 'message', 'Gateway unavailable')
              .having((e) => e.statusCode, 'statusCode', 502),
        ),
      );
    });

    test('maps 5xx responses to UnauthorisedException', () async {
      final client = await createClient();
      responder = (_) => http.Response('{"message":"Server error"}', 500);

      expect(
        client.get('/api/tasks'),
        throwsA(
          isA<UnauthorisedException>()
              .having((e) => e.message, 'message', 'Server error')
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('maps unexpected statuses to FetchDataException', () async {
      final client = await createClient();
      responder = (_) => http.Response('teapot', 418);

      expect(
        client.get('/api/tasks'),
        throwsA(
          isA<FetchDataException>()
              .having((e) => e.message, 'message', 'Unexpected error (418)')
              .having((e) => e.statusCode, 'statusCode', 418),
        ),
      );
    });

    test('wraps transport failures in FetchDataException', () async {
      final client = await createClient();
      responder = (_) => throw Exception('connection refused');

      expect(
        client.get('/api/tasks'),
        throwsA(
          isA<FetchDataException>().having(
            (e) => e.message,
            'message',
            contains('Network error:'),
          ),
        ),
      );
    });
  });
}
