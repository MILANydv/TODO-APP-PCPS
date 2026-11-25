/// Shared model fixtures used by unit, widget, and integration tests.
library;

import 'package:flutter_app/data/models/task_model.dart';
import 'package:flutter_app/data/models/user_model.dart';

/// Builds a [TaskModel] with sensible defaults; override only what matters.
TaskModel testTask({
  int id = 1,
  String userId = 'user-1',
  String title = 'Test task',
  String description = 'Test description',
  bool isCompleted = false,
  String createdAt = '2026-11-21T14:23:09.280Z',
}) =>
    TaskModel(
      id: id,
      userId: userId,
      title: title,
      description: description,
      isCompleted: isCompleted,
      createdAt: createdAt,
    );

/// Builds a [UserModel] with sensible defaults; override only what matters.
UserModel testUser({
  String id = 'user-1',
  String name = 'Test User',
  String email = 'test@example.com',
}) =>
    UserModel(id: id, name: name, email: email);

/// Builds an [AuthResponse] with a fake JWT and [testUser].
AuthResponse testAuthResponse({
  String token = 'test-jwt-token',
  UserModel? user,
}) =>
    AuthResponse(token: token, user: user ?? testUser());

/// JSON payload matching the Express `/api/auth/register|login` response.
Map<String, dynamic> authJson({
  String token = 'test-jwt-token',
  Map<String, dynamic>? user,
}) =>
    <String, dynamic>{
      'success': true,
      'token': token,
      'user': user ?? testUser().toJson(),
    };

/// JSON payload matching the Express `/api/tasks` list response.
Map<String, dynamic> tasksJson(List<TaskModel> tasks) => <String, dynamic>{
      'success': true,
      'count': tasks.length,
      'data': tasks.map((task) => task.toJson()).toList(),
    };

/// JSON payload matching the Express single-task responses.
Map<String, dynamic> taskJson(TaskModel task) => <String, dynamic>{
      'success': true,
      'data': task.toJson(),
    };
