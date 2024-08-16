import 'package:flutter/material.dart';

import '../services/todo_api_service.dart';
import '../repositories/todo_repository.dart';
import '../models/todo_task.dart';

class TodoProvider with ChangeNotifier {
  final TodoApiService _todoApiService =
      TodoApiService(todoRepository: TodoRepository());

  List<TodoTask> _tasks = [];
  List<TodoTask> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _todoApiService.fetchTodos();
    } catch (e) {
      _error = 'Failed to load todos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodoTask(TodoTask task) async {
    try {
      final newTask = await _todoApiService.createTodoTask(task);
      _tasks.add(newTask);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add task: $e';
      notifyListeners();
    }
  }

  Future<void> updateTodoTask(TodoTask task) async {
    try {
      final updatedTask = await _todoApiService.updateTodoTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update task: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTodoTask(String id) async {
    try {
      await _todoApiService.deleteTodoTask(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete task: $e';
      notifyListeners();
    }
  }
}
