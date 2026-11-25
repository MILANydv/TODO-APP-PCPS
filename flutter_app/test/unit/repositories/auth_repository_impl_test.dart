import 'dart:convert';

import 'package:flutter_app/core/constants/app_constants.dart';
import 'package:flutter_app/core/network/api_client.dart';
import 'package:flutter_app/core/network/app_exception.dart';
import 'package:flutter_app/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_data.dart';

void main() {
  late http.Request lastRequest;
  late http.Response Function(http.Request) responder;
  late SharedPreferences prefs;
  late AuthRepositoryImpl repository;

  Future<void> buildRepository({
    Map<String, Object> initialValues = const <String, Object>{},
  }) async {
    SharedPreferences.setMockInitialValues(initialValues);
    prefs = await SharedPreferences.getInstance();
    final apiClient = ApiClient(
      MockClient((request) async {
        lastRequest = request;
        return responder(request);
      }),
      prefs,
    );
    repository = AuthRepositoryImpl(apiClient, prefs);
  }

  setUp(() {
    responder = (_) => http.Response('{}', 200);
  });

  group('register and login', () {
    test('register posts credentials and persists the session', () async {
      await buildRepository();
      responder = (_) => http.Response(
            jsonEncode(authJson(token: 'jwt-register')),
            201,
          );

      final result = await repository.register(
        name: 'Milan',
        email: 'milan@example.com',
        password: 'password123',
      );

      expect(result.token, 'jwt-register');
      expect(result.user.name, 'Test User');
      expect(lastRequest.url.path, AppConstants.registerEndpoint);
      expect(jsonDecode(lastRequest.body), <String, dynamic>{
        'name': 'Milan',
        'email': 'milan@example.com',
        'password': 'password123',
      });
      expect(prefs.getString(AppConstants.tokenKey), 'jwt-register');
      expect(repository.token, 'jwt-register');
      expect(repository.currentUser?.id, 'user-1');
      expect(repository.isLoggedIn, isTrue);
    });

    test('login posts credentials and caches the returned user', () async {
      await buildRepository();
      responder = (_) => http.Response(
            jsonEncode(authJson(
              token: 'jwt-login',
              user: testUser(id: 'u2', name: 'Logged In').toJson(),
            )),
            200,
          );

      final result = await repository.login(
        email: 'a@b.com',
        password: 'secret',
      );

      expect(result.user.name, 'Logged In');
      expect(lastRequest.url.path, AppConstants.loginEndpoint);
      expect(jsonDecode(lastRequest.body), <String, dynamic>{
        'email': 'a@b.com',
        'password': 'secret',
      });
      expect(
        jsonDecode(prefs.getString(AppConstants.userKey)!),
        result.user.toJson(),
      );
    });

    test('propagates API errors without storing a session', () async {
      await buildRepository();
      responder = (_) => http.Response(
            '{"message":"Invalid email or password"}',
            401,
          );

      expect(
        repository.login(email: 'a@b.com', password: 'wrong'),
        throwsA(isA<BadRequestException>()),
      );
      expect(repository.isLoggedIn, isFalse);
      expect(repository.currentUser, isNull);
    });
  });

  group('session state', () {
    test('currentUser is restored from storage on a fresh instance', () async {
      final user = testUser(id: 'stored-id', name: 'Stored');
      await buildRepository(<String, Object>{
        AppConstants.userKey: jsonEncode(user.toJson()),
      });

      final restored = AuthRepositoryImpl(
        ApiClient(MockClient((request) async {
          return http.Response('{}', 200);
        }), prefs),
        prefs,
      );

      expect(restored.currentUser?.id, 'stored-id');
      expect(restored.currentUser?.name, 'Stored');
    });

    test('currentUser returns null for corrupt cached JSON', () async {
      await buildRepository(<String, Object>{
        AppConstants.userKey: 'not json',
      });

      expect(repository.currentUser, isNull);
    });

    test('isLoggedIn is false when the stored token is empty', () async {
      await buildRepository(<String, Object>{AppConstants.tokenKey: ''});

      expect(repository.isLoggedIn, isFalse);
    });

    test('logout clears token, cached user, and in-memory state', () async {
      await buildRepository(<String, Object>{
        AppConstants.tokenKey: 'old-token',
        AppConstants.userKey: jsonEncode(testUser().toJson()),
      });
      expect(repository.isLoggedIn, isTrue);
      expect(repository.currentUser, isNotNull);

      await repository.logout();

      expect(repository.isLoggedIn, isFalse);
      expect(repository.currentUser, isNull);
      expect(prefs.getString(AppConstants.tokenKey), isNull);
      expect(prefs.getString(AppConstants.userKey), isNull);
    });
  });

  group('profile operations', () {
    test('getMe parses the nested user and refreshes the cache', () async {
      await buildRepository();
      responder = (_) => http.Response(
            jsonEncode(<String, dynamic>{
              'success': true,
              'user': testUser(id: 'me-id', name: 'Me').toJson(),
            }),
            200,
          );

      final user = await repository.getMe();

      expect(user.name, 'Me');
      expect(lastRequest.method, 'GET');
      expect(lastRequest.url.path, AppConstants.meEndpoint);
      expect(repository.currentUser?.id, 'me-id');
    });

    test('updateProfile sends only non-null fields and caches the result',
        () async {
      await buildRepository();
      responder = (_) => http.Response(
            jsonEncode(<String, dynamic>{
              'success': true,
              'user': testUser(name: 'Renamed', email: 'a@b.com').toJson(),
            }),
            200,
          );

      final updated = await repository.updateProfile(name: 'Renamed');

      expect(updated.name, 'Renamed');
      expect(lastRequest.method, 'PATCH');
      expect(jsonDecode(lastRequest.body), <String, dynamic>{
        'name': 'Renamed',
      });
      expect(repository.currentUser?.name, 'Renamed');
    });
  });
}
