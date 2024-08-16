import '../models/todo_task.dart';
import '../repositories/todo_repository.dart';

class TodoApiService {
  final TodoRepository _todoRepository;
  final List<TodoTask> _tasks = [];

  TodoApiService({required TodoRepository todoRepository})
      : _todoRepository = todoRepository;

  Future<List<TodoTask>> fetchTodos() async {
    try {
      return await _todoRepository.fetchTodoTasks();
    } catch (e) {
      print('Error fetching todos: $e');
      rethrow;
    }
  }

  Future<TodoTask> createTodoTask(TodoTask task) async {
    try {
      return await _todoRepository.createTodoTask(task);
    } catch (e) {
      print('Error creating todo: $e');
      rethrow;
    }
  }

  Future<TodoTask> updateTodoTask(TodoTask task) async {
    try {
      return await _todoRepository.updateTodoTask(task);
    } catch (e) {
      print('Error updating todo: $e');
      rethrow;
    }
  }

  Future<void> deleteTodoTask(String id) async {
    try {
      await _todoRepository.deleteTodoTask(id);
      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting todo: $e');
      rethrow;
    }
  }

  void notifyListeners() {
    print('Notifying listeners');
  }
}
