import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

/// Concrete implementation of [AuthRepository] backed by the Express API.
///
/// Persists the JWT token and user profile in [SharedPreferences] so the
/// session survives app restarts.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates an [AuthRepositoryImpl] with the given [apiClient] and [prefs].
  AuthRepositoryImpl(this._apiClient, this._prefs);

  /// API client used to make authenticated HTTP requests.
  final ApiClient _apiClient;

  /// SharedPreferences instance used to persist the auth token and user.
  final SharedPreferences _prefs;

  /// In-memory cache of the currently logged-in user, if loaded.
  UserModel? _cachedUser;

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      AppConstants.registerEndpoint,
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final authResponse = AuthResponse.fromJson(json);

    _cachedUser = authResponse.user;
    await _prefs.setString(AppConstants.tokenKey, authResponse.token);
    await _prefs.setString(
      AppConstants.userKey,
      jsonEncode(authResponse.user.toJson()),
    );

    return authResponse;
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      AppConstants.loginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final authResponse = AuthResponse.fromJson(json);

    _cachedUser = authResponse.user;
    await _prefs.setString(AppConstants.tokenKey, authResponse.token);
    await _prefs.setString(
      AppConstants.userKey,
      jsonEncode(authResponse.user.toJson()),
    );

    return authResponse;
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _apiClient.get(AppConstants.meEndpoint);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final user = UserModel.fromJson(json['user'] as Map<String, dynamic>);

    _cachedUser = user;
    await _prefs.setString(
      AppConstants.userKey,
      jsonEncode(user.toJson()),
    );
    return user;
  }

  @override
  UserModel? get currentUser {
    if (_cachedUser != null) return _cachedUser;
    final raw = _prefs.getString(AppConstants.userKey);
    if (raw == null) return null;
    try {
      _cachedUser = UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      return _cachedUser;
    } catch (_) {
      return null;
    }
  }

  @override
  String? get token => _prefs.getString(AppConstants.tokenKey);

  @override
  Future<void> logout() async {
    _cachedUser = null;
    await _prefs.remove(AppConstants.tokenKey);
    await _prefs.remove(AppConstants.userKey);
  }

  @override
  bool get isLoggedIn {
    final token = _prefs.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<UserModel> updateProfile({String? name, String? email}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;

    final response = await _apiClient.patch(
      AppConstants.meEndpoint,
      body: body,
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final updatedUser = UserModel.fromJson(json['user'] as Map<String, dynamic>);

    _cachedUser = updatedUser;
    await _prefs.setString(
      AppConstants.userKey,
      jsonEncode(updatedUser.toJson()),
    );

    return updatedUser;
  }
}
