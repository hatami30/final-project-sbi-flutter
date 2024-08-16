import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';
import '../providers/theme_provider.dart';
import '../models/todo_task.dart';
import '../utils/constants.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodoProvider>(context, listen: false).fetchTodos();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refreshTodos(BuildContext context) async {
    await Provider.of<TodoProvider>(context, listen: false).fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.nights_stay
                      : Icons.wb_sunny,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? Colors.yellow
                      : Colors.blueAccent,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refreshTodos(context),
              child: _buildTodoList(context),
            ),
          ),
          _buildAddTaskInput(context),
        ],
      ),
    );
  }

  Widget _buildTodoList(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        if (todoProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (todoProvider.error != null) {
          return Center(child: Text(todoProvider.error!));
        }

        if (todoProvider.tasks.isEmpty) {
          return const Center(
            child: Text('No tasks available. Add a task to get started!'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: todoProvider.tasks.length,
          itemBuilder: (context, index) {
            final task = todoProvider.tasks[index];
            final isDarkMode =
                Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

            return ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  decoration:
                      task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: Wrap(
                spacing: 12,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      task.isCompleted
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: kPrimaryColor,
                    ),
                    onPressed: () => _toggleTaskCompletion(context, task),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, task);
                    },
                  ),
                ],
              ),
              onTap: () => _editTask(context, task),
            );
          },
        );
      },
    );
  }

  Widget _buildAddTaskInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Add a new task',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addTask(context),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add),
            color: kPrimaryColor,
            onPressed: () => _addTask(context),
          ),
        ],
      ),
    );
  }

  void _addTask(BuildContext context) {
    final taskTitle = _controller.text.trim();
    if (taskTitle.isNotEmpty) {
      final todoProvider = Provider.of<TodoProvider>(context, listen: false);
      final isDuplicate = todoProvider.tasks
          .any((task) => task.title.toLowerCase() == taskTitle.toLowerCase());

      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task already exists'),
          ),
        );
      } else {
        final newTask = TodoTask(
          id: DateTime.now().toString(),
          title: taskTitle,
          isCompleted: false,
        );
        todoProvider.addTodoTask(newTask).then((_) {
          _controller.clear();
          FocusScope.of(context).unfocus();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task added successfully'),
            ),
          );
        }).catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add task: $e')),
          );
        });
      }
    }
  }

  void _toggleTaskCompletion(BuildContext context, TodoTask task) {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    Provider.of<TodoProvider>(context, listen: false)
        .updateTodoTask(updatedTask)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updatedTask.isCompleted
              ? 'Task marked as completed'
              : 'Task marked as incomplete'),
        ),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: $e')),
      );
    });
  }

  void _editTask(BuildContext context, TodoTask task) {
    _controller.text = task.title;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Enter new task title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _controller.clear();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newTitle = _controller.text.trim();
                if (newTitle.isNotEmpty) {
                  final updatedTask = task.copyWith(title: newTitle);
                  Provider.of<TodoProvider>(context, listen: false)
                      .updateTodoTask(updatedTask)
                      .then((_) {
                    Navigator.of(context).pop();
                    _controller.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task updated successfully'),
                      ),
                    );
                  }).catchError((e) {
                    Navigator.of(context).pop();
                    _controller.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update task: $e')),
                    );
                  });
                } else {
                  Navigator.of(context).pop();
                  _controller.clear();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, TodoTask task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<TodoProvider>(context, listen: false)
                    .deleteTodoTask(task.id ?? '')
                    .then((_) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task deleted successfully'),
                    ),
                  );
                }).catchError((e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete task: $e')),
                  );
                });
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
