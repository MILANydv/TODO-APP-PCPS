/// A single task belonging to a user.
///
/// Tasks are created, listed, updated, and deleted through the
/// `/api/tasks` endpoints on the Express backend.
class TaskModel {
  /// Unique identifier of the task.
  final int id;

  /// Identifier of the user who owns this task.
  final String userId;

  /// Short title of the task.
  final String title;

  /// Optional longer description of the task.
  final String description;

  /// Whether the task has been marked as completed.
  final bool isCompleted;

  /// ISO-8601 timestamp indicating when the task was created.
  final String createdAt;

  /// Creates a [TaskModel] with all required fields.
  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
  });

  /// Creates a [TaskModel] from a JSON map as returned by the API.
  ///
  /// Expects keys: `id`, `userId`, `title`, `description`, `isCompleted`,
  /// `createdAt`.
  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
        userId: json['userId'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
        createdAt: json['createdAt'] as String,
      );

  /// Converts this [TaskModel] into a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'createdAt': createdAt,
      };

  /// Returns a copy of this [TaskModel] with the given fields replaced.
  ///
  /// Any parameter left as `null` retains the existing value.
  TaskModel copyWith({
    int? id,
    String? userId,
    String? title,
    String? description,
    bool? isCompleted,
    String? createdAt,
  }) =>
      TaskModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description ?? this.description,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
      );
}
