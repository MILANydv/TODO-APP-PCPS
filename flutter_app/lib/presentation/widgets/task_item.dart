import 'package:flutter/material.dart';

import '../../data/models/task_model.dart';

/// A single task row displayed in the task list.
///
/// Shows the task title, optional description, a checkbox for toggling
/// completion, and a delete button. Swiping dismisses the task (delete).
/// Tapping the row opens the edit dialog.
class TaskItem extends StatelessWidget {
  /// The task to display.
  final TaskModel task;

  /// Callback invoked when the completion checkbox is toggled.
  final VoidCallback onToggle;

  /// Callback invoked when the task is deleted (swipe or delete icon).
  final VoidCallback onDelete;

  /// Callback invoked when the task row is tapped.
  final VoidCallback onTap;

  /// Creates a [TaskItem] for the given [task] with the required callbacks.
  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      // Background shown while swiping to delete.
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle(),
          activeColor: Colors.indigo,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            // Strikethrough applied when completed.
            decoration:
                task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: task.description.isNotEmpty
            ? Text(
                task.description,
                style: TextStyle(
                  fontSize: 13,
                  color: task.isCompleted ? Colors.grey : Colors.grey.shade600,
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
