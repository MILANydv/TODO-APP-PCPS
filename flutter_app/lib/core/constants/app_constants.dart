/// Central location for all application-wide constants.
///
/// Holds the backend base URL, API endpoint paths, and local storage keys.
/// Update [baseUrl] to point to your running Node.js Express server.
class AppConstants {
  AppConstants._();

  /// Base URL of the Node.js Express backend.
  ///
  /// - Android emulator: `http://10.0.2.2:5001` (default)
  /// - iOS simulator:    `http://localhost:5001`
  /// - Physical device:  your computer's LAN IP, e.g.
  ///   `http://192.168.x.x:5001`
  static const String baseUrl = 'http://10.0.2.2:5001';

  /// POST endpoint for user registration.
  static const String registerEndpoint = '/api/auth/register';

  /// POST endpoint for user login.
  static const String loginEndpoint = '/api/auth/login';

  /// GET endpoint for the current user's profile.
  static const String meEndpoint = '/api/auth/me';

  /// Base endpoint for task CRUD operations.
  static const String tasksEndpoint = '/api/tasks';

  /// SharedPreferences key under which the JWT token is stored.
  static const String tokenKey = 'auth_token';

  /// SharedPreferences key under which the cached user profile is stored.
  static const String userKey = 'cached_user';
}
