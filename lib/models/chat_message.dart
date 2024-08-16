class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;
  final String conversationId;
  final String status;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.conversationId,
    this.status = 'sent',
  });

  ChatMessage copyWith({
    String? sender,
    String? message,
    DateTime? timestamp,
    String? conversationId,
    String? status,
  }) {
    return ChatMessage(
      sender: sender ?? this.sender,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      conversationId: conversationId ?? this.conversationId,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'conversationId': conversationId,
      'status': status,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    if (json['sender'] == null ||
        json['message'] == null ||
        json['timestamp'] == null ||
        json['conversationId'] == null) {
      throw ArgumentError('Invalid or incomplete JSON data');
    }

    return ChatMessage(
      sender: json['sender'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      conversationId: json['conversationId'] as String,
      status: json['status'] as String? ?? 'sent',
    );
  }
}
