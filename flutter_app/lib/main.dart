import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/task_viewmodel.dart';

/// Entry point of the Task Manager Flutter application.
///
/// Sets up the dependency injection graph and runs the app with [Provider].
///
/// Steps:
/// 1. Ensures Flutter bindings are initialized (required before using async
///    APIs that touch the framework).
/// 2. Creates a [SharedPreferences] instance for persisting the auth token.
/// 3. Creates an [ApiClient] wrapping [http.Client].
/// 4. Creates the repository implementations.
/// 5. Provides [AuthViewModel] and [TaskViewModel] via [MultiProvider].
/// 6. Runs [TaskManagerApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences is used to persist the JWT token across app restarts.
  final prefs = await SharedPreferences.getInstance();

  // API client handles HTTP requests and automatically attaches the Bearer token.
  final apiClient = ApiClient(http.Client(), prefs);

  // Repository implementations backed by the Express API.
  final authRepository = AuthRepositoryImpl(apiClient, prefs);
  final taskRepository = TaskRepositoryImpl(apiClient);

  runApp(
    MultiProvider(
      providers: [
        // AuthViewModel manages login/register/logout state.
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository),
        ),
        // TaskViewModel manages the task list and task mutations.
        ChangeNotifierProvider(
          create: (_) => TaskViewModel(taskRepository),
        ),
      ],
      child: const TaskManagerApp(),
    ),
  );
}
