import '../models/user_model.dart';

/// Abstract contract for authentication data access.
///
/// The ViewModel depends on this interface rather than a concrete
/// implementation, which makes it easy to swap the backing store (e.g. for
/// unit tests with a mock repository) without changing the UI layer.
abstract class AuthRepository {
  /// Registers a new user with the given [name], [email], and [password].
  ///
  /// Returns an [AuthResponse] containing the JWT token and user profile.
  /// Throws an [AppException] if registration fails (e.g. duplicate email).
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  });

  /// Logs in a user with the given [email] and [password].
  ///
  /// Returns an [AuthResponse] containing the JWT token and user profile.
  /// Throws an [AppException] if credentials are invalid.
  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  /// Fetches the logged-in user's profile from the server.
  ///
  /// Requires a valid session. Throws an [AppException] if the request fails.
  Future<UserModel> getMe();

  /// Returns the currently cached [UserModel], if one exists locally.
  ///
  /// Does not make a network request; reads from memory or SharedPreferences.
  UserModel? get currentUser;

  /// Returns the stored JWT token, if any.
  String? get token;

  /// Clears all stored session data (token and user profile).
  ///
  /// Called when the user logs out.
  Future<void> logout();

  /// Returns `true` if a valid session token is currently stored.
  bool get isLoggedIn;

  /// Updates the logged-in user's [name] and/or [email].
  ///
  /// Only non-null parameters are sent to the server (partial update).
  /// Returns the updated [UserModel] on success.
  /// Throws an [AppException] if the update fails.
  Future<UserModel> updateProfile({String? name, String? email});
}
