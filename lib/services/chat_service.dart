import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../services/rate_limiter.dart';

class ChatService {
  final ChatRepository _chatRepository;
  final RateLimiter _rateLimiter;

  ChatService({
    required ChatRepository chatRepository,
    required RateLimiter rateLimiter,
  })  : _chatRepository = chatRepository,
        _rateLimiter = rateLimiter;

  Future<String> sendMessage(String message,
      {required String conversationId}) async {
    final tokenCount = calculateTokenCount(message);

    if (_rateLimiter.checkLimits(tokenCount)) {
      try {
        final response = await _chatRepository.sendMessage(message);
        return response;
      } catch (error) {
        throw Exception('Failed to send message: $error');
      }
    } else {
      throw Exception('Rate limit exceeded');
    }
  }

  Future<List<ChatMessage>> fetchConversationHistory(
      String conversationId) async {
    if (_rateLimiter.checkLimits(0)) {
      try {
        final history =
            await _chatRepository.fetchConversationHistory(conversationId);
        return history;
      } catch (error) {
        throw Exception('Failed to fetch conversation history: $error');
      }
    } else {
      throw Exception('Rate limit exceeded');
    }
  }

  int calculateTokenCount(String message) {
    return message.length;
  }
}
