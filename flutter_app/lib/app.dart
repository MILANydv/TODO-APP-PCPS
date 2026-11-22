import 'package:flutter/material.dart';

import 'presentation/routes/app_routes.dart';

/// Root [StatelessWidget] of the Task Manager app.
///
/// Configures [MaterialApp] with the app theme, initial route, and the named
/// route table defined in [AppRoutes].
class TaskManagerApp extends StatelessWidget {
  /// Creates a [TaskManagerApp] with an optional [key].
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      // The splash screen performs the session check and redirects to login or
      // home accordingly.
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      // Fallback for any route not declared in [AppRoutes.routes].
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
      },
    );
  }
}
