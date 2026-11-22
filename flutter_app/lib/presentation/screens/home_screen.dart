import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/task_model.dart';
import '../../presentation/viewmodels/auth_viewmodel.dart';
import '../../presentation/viewmodels/task_viewmodel.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_button.dart';
import '../widgets/task_item.dart';

/// Home screen displaying the authenticated user's task list.
///
/// Responsibilities:
/// - Guards the route: redirects to login if no session exists.
/// - Observes [TaskViewModel] to show loading, error, and task-list states.
/// - Provides UI for adding, editing, toggling, and deleting tasks.
/// - Displays summary statistics (total / done / pending).
class HomeScreen extends StatefulWidget {
  /// Creates a [HomeScreen] with an optional [key].
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Controller for the task title input field.
  final _titleController = TextEditingController();

  /// Controller for the task description input field.
  final _descController = TextEditingController();

  /// Whether the "add task" form is currently visible.
  bool _showAddForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authViewModel = context.read<AuthViewModel>();
      // Redirect unauthenticated users to the login screen.
      if (!authViewModel.isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }
      // Load the user's tasks once the frame is rendered.
      context.read<TaskViewModel>().loadTasks();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Creates a new task from the form input and resets the form on success.
  Future<void> _addTask() async {
    if (_titleController.text.trim().isEmpty) return;
    final viewModel = context.read<TaskViewModel>();
    final success = await viewModel.createTask(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
    );
    if (success && mounted) {
      _titleController.clear();
      _descController.clear();
      setState(() => _showAddForm = false);
    }
  }

  /// Logs the user out and redirects to the login screen.
  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.profile),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Consumer<TaskViewModel>(
        builder: (context, taskViewModel, child) {
          // Show a spinner while tasks are being loaded.
          if (taskViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Show an error banner with a retry button if loading failed.
          if (taskViewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    taskViewModel.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Retry',
                    onPressed: () => taskViewModel.loadTasks(),
                  ),
                ],
              ),
            );
          }
          final tasks = taskViewModel.tasks;
          return Column(
            children: [
              // Stats bar showing total / done / pending counts.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.indigo.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBox(
                      label: 'Total',
                      value: taskViewModel.taskCount.toString(),
                    ),
                    _StatBox(
                      label: 'Done',
                      value: taskViewModel.completedCount.toString(),
                      color: Colors.green,
                    ),
                    _StatBox(
                      label: 'Pending',
                      value: taskViewModel.incompleteTasks.length.toString(),
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Add task form (animated in/out).
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _AddTaskForm(
                  titleController: _titleController,
                  descController: _descController,
                  onAdd: _addTask,
                  onCancel: () =>
                      setState(() => _showAddForm = false),
                ),
                crossFadeState: _showAddForm
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
              if (!_showAddForm)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextButton.icon(
                      icon: const Icon(Icons.add, color: Colors.indigo),
                      label: const Text(
                        'Add Task',
                        style: TextStyle(color: Colors.indigo),
                      ),
                      onPressed: () =>
                          setState(() => _showAddForm = true),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              // Task list.
              Expanded(
                child: tasks.isEmpty
                    ? const Center(
                        child: Text(
                          'No tasks yet. Add one above!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: TaskItem(
                              task: task,
                              onToggle: () =>
                                  taskViewModel.toggleTask(task),
                              onDelete: () =>
                                  taskViewModel.deleteTask(task.id),
                              onTap: () {
                                // Open the edit task dialog.
                                _editTaskDialog(task, taskViewModel);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Shows a dialog to edit the given [task]'s title and description.
  ///
  /// On save, calls [TaskViewModel.updateTask] with the edited values.
  void _editTaskDialog(
      TaskModel task, TaskViewModel viewModel) {
    final tCtrl = TextEditingController(text: task.title);
    final dCtrl = TextEditingController(text: task.description);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await viewModel.updateTask(
                task: task,
                title: tCtrl.text.trim().isEmpty ? null : tCtrl.text.trim(),
                description: dCtrl.text.trim(),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/// A small stat box displaying a [label] and a large [value].
class _StatBox extends StatelessWidget {
  /// Label shown below the value (e.g. "Total").
  final String label;

  /// Large numeric value shown at the top (e.g. "5").
  final String value;

  /// Optional accent color for the value text.
  final Color? color;

  const _StatBox({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.indigo,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

/// The "Add Task" form shown below the stats bar.
///
/// Contains title and description input fields plus Add/Cancel buttons.
class _AddTaskForm extends StatelessWidget {
  /// Controller for the task title input.
  final TextEditingController titleController;

  /// Controller for the task description input.
  final TextEditingController descController;

  /// Callback invoked when the user taps Add.
  final VoidCallback onAdd;

  /// Callback invoked when the user taps Cancel.
  final VoidCallback onCancel;

  const _AddTaskForm({
    required this.titleController,
    required this.descController,
    required this.onAdd,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'New Task',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Add',
                    onPressed: onAdd,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
