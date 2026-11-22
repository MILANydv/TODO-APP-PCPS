import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';

/// Central definition of the app's named routes.
///
/// Use [AppRoutes.splash], [AppRoutes.login], [AppRoutes.register],
/// [AppRoutes.home], and [AppRoutes.profile] when navigating, rather than
/// hard-coded strings.
class AppRoutes {
  AppRoutes._();

  /// Initial splash / session-check screen.
  static const String splash = '/';

  /// Login screen for existing users.
  static const String login = '/login';

  /// Registration screen for new users.
  static const String register = '/register';

  /// Home / task list screen (requires authentication).
  static const String home = '/home';

  /// Profile screen for viewing and editing account details.
  static const String profile = '/profile';

  /// Map of route names to their corresponding widget builders, suitable for
  /// passing directly to `MaterialApp.routes`.
  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        home: (_) => const HomeScreen(),
        profile: (_) => const ProfileScreen(),
      };
}
