import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/todo_task.dart';

class TodoRepository {
  final String _apiUrl;

  TodoRepository() : _apiUrl = dotenv.env['MOCK_API_URL'] ?? '';

  Future<List<TodoTask>> fetchTodoTasks() async {
    if (_apiUrl.isEmpty) {
      throw Exception('API URL is not set in .env file');
    }

    final response = await http.get(Uri.parse(_apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> todosJson = json.decode(response.body);
      return todosJson.map((json) => TodoTask.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load todos. Status code: ${response.statusCode}');
    }
  }

  Future<TodoTask> createTodoTask(TodoTask task) async {
    if (_apiUrl.isEmpty) {
      throw Exception('API URL is not set in .env file');
    }

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 201) {
      return TodoTask.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to create todo. Status code: ${response.statusCode}');
    }
  }

  Future<TodoTask> updateTodoTask(TodoTask task) async {
    if (_apiUrl.isEmpty) {
      throw Exception('API URL is not set in .env file');
    }

    final url = '$_apiUrl/${task.id}';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 200) {
      return TodoTask.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to update todo. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteTodoTask(String id) async {
    if (_apiUrl.isEmpty) {
      throw Exception('API URL is not set in .env file');
    }

    final url = '$_apiUrl/$id';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode != 204) {
      throw Exception(
          'Failed to delete todo. Status code: ${response.statusCode}');
    }
  }
}
