/// Hand-rolled repository fakes.
///
/// The ViewModels depend on the abstract repository interfaces, so tests can
/// inject these fakes without any mocking package or network access.
library;

import 'dart:async';

import 'package:flutter_app/data/models/task_model.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';
import 'package:flutter_app/data/repositories/task_repository.dart';

import 'test_data.dart';

/// Configurable fake implementation of [AuthRepository].
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    UserModel? user,
    String? token,
    AuthResponse? registerResponse,
    AuthResponse? loginResponse,
    UserModel? meResponse,
    UserModel? updateResponse,
    this.registerError,
    this.loginError,
    this.getMeError,
    this.updateProfileError,
    this.logoutError,
    this.delay = Duration.zero,
  })  : _user = user,
        _token = token,
        _registerResponse = registerResponse ?? testAuthResponse(),
        _loginResponse = loginResponse ?? testAuthResponse(),
        _meResponse = meResponse ?? user ?? testUser(),
        _updateResponse = updateResponse ?? user ?? testUser();

  UserModel? _user;
  String? _token;
  final AuthResponse _registerResponse;
  final AuthResponse _loginResponse;
  final UserModel _meResponse;
  final UserModel _updateResponse;

  Object? registerError;
  Object? loginError;
  Object? getMeError;
  Object? updateProfileError;
  Object? logoutError;

  /// Optional artificial latency (useful for verifying loading states).
  Duration delay;

  /// Names of repository methods invoked so far, in order.
  final List<String> calls = <String>[];

  String? lastName;
  String? lastEmail;
  String? lastPassword;
  String? lastUpdatedName;
  String? lastUpdatedEmail;

  @override
  UserModel? get currentUser => _user;

  @override
  String? get token => _token;

  @override
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  /// Seeds a session without going through register/login.
  void setSession({required String token, UserModel? user}) {
    _token = token;
    if (user != null) _user = user;
  }

  Future<void> _wait() => delay == Duration.zero
      ? Future<void>.value()
      : Future<void>.delayed(delay);

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    calls.add('register');
    lastName = name;
    lastEmail = email;
    lastPassword = password;
    await _wait();
    if (registerError != null) throw registerError!;
    _user = _registerResponse.user;
    _token = _registerResponse.token;
    return _registerResponse;
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    calls.add('login');
    lastEmail = email;
    lastPassword = password;
    await _wait();
    if (loginError != null) throw loginError!;
    _user = _loginResponse.user;
    _token = _loginResponse.token;
    return _loginResponse;
  }

  @override
  Future<UserModel> getMe() async {
    calls.add('getMe');
    await _wait();
    if (getMeError != null) throw getMeError!;
    _user = _meResponse;
    return _meResponse;
  }

  @override
  Future<UserModel> updateProfile({String? name, String? email}) async {
    calls.add('updateProfile');
    lastUpdatedName = name;
    lastUpdatedEmail = email;
    await _wait();
    if (updateProfileError != null) throw updateProfileError!;
    _user = _updateResponse;
    return _updateResponse;
  }

  @override
  Future<void> logout() async {
    calls.add('logout');
    await _wait();
    if (logoutError != null) throw logoutError!;
    _user = null;
    _token = null;
  }
}

/// Configurable fake implementation of [TaskRepository].
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({
    List<TaskModel>? tasks,
    this.getTasksError,
    this.createTaskError,
    this.updateTaskError,
    this.deleteTaskError,
    this.delay = Duration.zero,
    this.getTasksGate,
  }) : _tasks = <TaskModel>[...?tasks];

  final List<TaskModel> _tasks;

  Object? getTasksError;
  Object? createTaskError;
  Object? updateTaskError;
  Object? deleteTaskError;

  /// Optional artificial latency (useful for verifying loading states).
  Duration delay;

  /// When set, `getTasks` waits on this completer before returning.
  Completer<void>? getTasksGate;

  /// Names of repository methods invoked so far, in order.
  final List<String> calls = <String>[];

  String? lastCreatedTitle;
  String? lastCreatedDescription;
  int? lastUpdatedId;
  String? lastUpdatedTitle;
  String? lastUpdatedDescription;
  bool? lastUpdatedIsCompleted;
  int? lastDeletedId;

  Future<void> _wait() => delay == Duration.zero
      ? Future<void>.value()
      : Future<void>.delayed(delay);

  @override
  Future<List<TaskModel>> getTasks() async {
    calls.add('getTasks');
    await getTasksGate?.future;
    await _wait();
    if (getTasksError != null) throw getTasksError!;
    return List<TaskModel>.unmodifiable(_tasks);
  }

  @override
  Future<TaskModel> createTask({
    required String title,
    required String description,
  }) async {
    calls.add('createTask');
    lastCreatedTitle = title;
    lastCreatedDescription = description;
    await _wait();
    if (createTaskError != null) throw createTaskError!;
    final task = testTask(
      id: _tasks.isEmpty ? 1 : _tasks.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1,
      title: title,
      description: description,
    );
    _tasks.insert(0, task);
    return task;
  }

  @override
  Future<TaskModel> updateTask({
    required int id,
    String? title,
    String? description,
    bool? isCompleted,
  }) async {
    calls.add('updateTask');
    lastUpdatedId = id;
    lastUpdatedTitle = title;
    lastUpdatedDescription = description;
    lastUpdatedIsCompleted = isCompleted;
    await _wait();
    if (updateTaskError != null) throw updateTaskError!;
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) throw StateError('Task $id not found');
    final updated = _tasks[index].copyWith(
      title: title,
      description: description,
      isCompleted: isCompleted,
    );
    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteTask(int id) async {
    calls.add('deleteTask');
    lastDeletedId = id;
    await _wait();
    if (deleteTaskError != null) throw deleteTaskError!;
    _tasks.removeWhere((t) => t.id == id);
  }
}
