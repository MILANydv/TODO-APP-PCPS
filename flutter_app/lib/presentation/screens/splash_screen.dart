import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

/// Splash screen shown while the app performs its initial session check.
///
/// After a short delay the app navigates to the login screen. The
/// [HomeScreen] performs the final auth guard, so this screen always defers
/// to login and lets HomeScreen redirect to home if a valid session already
/// exists.
class SplashScreen extends StatefulWidget {
  /// Creates a [SplashScreen] with an optional [key].
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  /// Waits briefly (to show the splash branding), then navigates to login.
  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    // Always route to login; HomeScreen redirects to home if a valid session
    // already exists.
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 80, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'Task Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Node.js Express + Flutter MVVM',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
