import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../services/chat_service.dart';
import '../services/rate_limiter.dart';

class ChatProvider with ChangeNotifier {
  final RateLimiter _rateLimiter = RateLimiter(
    maxRequestsPerMinute: 15,
    maxTokensPerMinute: 1000000,
    maxRequestsPerDay: 1500,
  );

  final ChatService _chatService;

  ChatProvider()
      : _chatService = ChatService(
          chatRepository: ChatRepository(),
          rateLimiter: RateLimiter(
            maxRequestsPerMinute: 15,
            maxTokensPerMinute: 1000000,
            maxRequestsPerDay: 1500,
          ),
        );

  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> sendMessage(String message,
      {required String conversationId}) async {
    final userMessage = ChatMessage(
      sender: 'You',
      message: message,
      timestamp: DateTime.now(),
      status: 'sending',
      conversationId: conversationId,
    );

    _addMessage(userMessage);

    try {
      if (_rateLimiter.checkLimits(calculateTokenCount(message))) {
        final response = await _chatService.sendMessage(message,
            conversationId: conversationId);
        _updateMessageStatus(userMessage, 'sent');

        final aiMessage = ChatMessage(
          sender: 'AI',
          message: response,
          timestamp: DateTime.now(),
          conversationId: conversationId,
        );

        _addMessage(aiMessage);
      } else {
        _updateMessageStatus(userMessage, 'failed');
        throw Exception('Rate limit exceeded');
      }
    } catch (error) {
      _updateMessageStatus(userMessage, 'failed');
      print('Failed to send message: $error');
      rethrow;
    }
  }

  Future<void> loadConversationHistory(String conversationId) async {
    try {
      final history =
          await _chatService.fetchConversationHistory(conversationId);
      _setMessages(history);
    } catch (error) {
      print('Failed to load conversation history: $error');
    }
  }

  void _addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void _updateMessageStatus(ChatMessage message, String status) {
    final messageIndex = _messages.indexWhere((msg) =>
        msg.conversationId == message.conversationId &&
        msg.timestamp == message.timestamp);
    if (messageIndex != -1) {
      _messages[messageIndex] = message.copyWith(status: status);
      notifyListeners();
    }
  }

  void _setMessages(List<ChatMessage> messages) {
    _messages.clear();
    _messages.addAll(messages);
    notifyListeners();
  }

  int calculateTokenCount(String message) {
    return message.length;
  }
}
