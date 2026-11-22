import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import 'base_viewmodel.dart';

/// ViewModel for the task list / task management screen.
///
/// Holds the list of [TaskModel] objects and derived collections (completed /
//  incomplete). Delegates all data operations to the [TaskRepository] and
/// exposes loading/error state via [BaseViewModel].
class TaskViewModel extends BaseViewModel {
  /// Creates a [TaskViewModel] backed by [taskRepository].
  TaskViewModel(this._taskRepository);

  /// Repository used to perform task CRUD operations.
  final TaskRepository _taskRepository;

  /// The full list of tasks for the current user.
  List<TaskModel> _tasks = [];

  /// The full list of tasks for the current user.
  List<TaskModel> get tasks => _tasks;

  /// Tasks that are not yet completed.
  List<TaskModel> get incompleteTasks =>
      _tasks.where((t) => !t.isCompleted).toList();

  /// Tasks that are marked as completed.
  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();

  /// Total number of tasks.
  int get taskCount => _tasks.length;

  /// Number of completed tasks.
  int get completedCount => completedTasks.length;

  /// Fetches all tasks for the current user from the server.
  ///
  /// Sets [isLoading] to true during the request and captures any error via
  /// [setError]. Returns `true` on success, `false` on failure.
  Future<bool> loadTasks() async {
    setBusy(true);
    try {
      _tasks = await _taskRepository.getTasks();
      setBusy(false);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  /// Creates a new task with the given [title] and [description].
  ///
  /// On success the new task is inserted at the top of the local list.
  /// Returns `true` on success, `false` on failure.
  Future<bool> createTask({
    required String title,
    required String description,
  }) async {
    setBusy(true);
    try {
      final newTask = await _taskRepository.createTask(
        title: title,
        description: description,
      );
      _tasks.insert(0, newTask);
      setBusy(false);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  /// Toggles the completion status of the given [task].
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> toggleTask(TaskModel task) async {
    try {
      final updated = await _taskRepository.updateTask(
        id: task.id,
        isCompleted: !task.isCompleted,
      );
      _tasks = _tasks
          .map((t) => t.id == updated.id ? updated : t)
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  /// Updates a task's [title] and/or [description].
  ///
  /// Only non-null parameters are sent to the server (partial update).
  /// Returns `true` on success, `false` on failure.
  Future<bool> updateTask({
    required TaskModel task,
    String? title,
    String? description,
  }) async {
    setBusy(true);
    try {
      final updated = await _taskRepository.updateTask(
        id: task.id,
        title: title,
        description: description,
      );
      _tasks = _tasks
          .map((t) => t.id == updated.id ? updated : t)
          .toList();
      setBusy(false);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  /// Deletes the task with the given [id] from the server and the local list.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> deleteTask(int id) async {
    setBusy(true);
    try {
      await _taskRepository.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      setBusy(false);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  /// Clears any existing error message without changing loading state.
  @override
  void clearError() {
    super.clearError();
  }
}
