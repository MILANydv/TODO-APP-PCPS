import 'dart:convert';

import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../models/task_model.dart';
import 'task_repository.dart';

/// Concrete implementation of [TaskRepository] backed by the Express API.
///
/// All task endpoints require an authenticated session; the [ApiClient]
/// automatically attaches the stored JWT bearer token.
class TaskRepositoryImpl implements TaskRepository {
  /// Creates a [TaskRepositoryImpl] with the given [apiClient].
  TaskRepositoryImpl(this._apiClient);

  /// API client used to make authenticated HTTP requests.
  final ApiClient _apiClient;

  @override
  Future<List<TaskModel>> getTasks() async {
    final response = await _apiClient.get(AppConstants.tasksEndpoint);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> data = json['data'] as List<dynamic>;
    return data
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TaskModel> createTask({
    required String title,
    required String description,
  }) async {
    final response = await _apiClient.post(
      AppConstants.tasksEndpoint,
      body: {
        'title': title,
        'description': description,
      },
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TaskModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<TaskModel> updateTask({
    required int id,
    String? title,
    String? description,
    bool? isCompleted,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (isCompleted != null) body['isCompleted'] = isCompleted;

    final response = await _apiClient.patch(
      '${AppConstants.tasksEndpoint}/$id',
      body: body,
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TaskModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTask(int id) async {
    await _apiClient.delete('${AppConstants.tasksEndpoint}/$id');
  }
}
