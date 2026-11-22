import '../models/task_model.dart';

/// Abstract contract for task data access.
///
/// The ViewModel depends on this interface so the data source can be swapped
/// (e.g. mocked for tests) without touching the presentation layer.
abstract class TaskRepository {
  /// Fetches all tasks belonging to the currently logged-in user.
  ///
  /// Returns a list of [TaskModel] objects. Throws an [AppException] on
  /// failure.
  Future<List<TaskModel>> getTasks();

  /// Creates a new task with the given [title] and optional [description].
  ///
  /// Returns the newly created [TaskModel] as persisted by the server.
  Future<TaskModel> createTask({
    required String title,
    required String description,
  });

  /// Partially updates an existing task identified by [id].
  ///
  /// Only non-null parameters are sent to the server, allowing partial updates
  /// such as toggling only `isCompleted`. Returns the updated [TaskModel].
  Future<TaskModel> updateTask({
    required int id,
    String? title,
    String? description,
    bool? isCompleted,
  });

  /// Deletes the task with the given [id].
  ///
  /// Throws an [AppException] if the task does not exist or the request fails.
  Future<void> deleteTask(int id);
}
