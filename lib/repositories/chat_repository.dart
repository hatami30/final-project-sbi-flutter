import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/chat_message.dart';

class ChatRepository {
  late final GenerativeModel _model;
  static const String _historyKey = 'chat_history';

  ChatRepository() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key is not set in .env file');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
  }

  Future<String> sendMessage(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final userMessage = ChatMessage(
        sender: 'You',
        message: prompt,
        timestamp: DateTime.now(),
        conversationId: 'default',
      );
      final aiMessage = ChatMessage(
        sender: 'AI',
        message: response.text ?? 'No response text available.',
        timestamp: DateTime.now(),
        conversationId: 'default',
      );

      await _saveMessage(userMessage);
      await _saveMessage(aiMessage);

      return response.text ?? 'No response text available.';
    } catch (error) {
      throw Exception('Failed to send message: ${error.toString()}');
    }
  }

  Future<List<ChatMessage>> fetchConversationHistory(
      String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];
      final history = historyJson
          .map((json) => ChatMessage.fromJson(jsonDecode(json)))
          .toList();

      return history
          .where((message) => message.conversationId == conversationId)
          .toList();
    } catch (error) {
      throw Exception(
          'Failed to fetch conversation history: ${error.toString()}');
    }
  }

  Future<void> _saveMessage(ChatMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];
      historyJson.add(jsonEncode(message.toJson()));
      await prefs.setStringList(_historyKey, historyJson);
    } catch (error) {
      throw Exception('Failed to save message: ${error.toString()}');
    }
  }
}
