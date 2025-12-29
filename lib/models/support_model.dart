class SupportRequest {
  final String id;
  final String username;
  final String email;
  final String message;
  final String status;
  final String reply;
  final DateTime createdAt;
  final List<SupportMessage> messages;

  SupportRequest({
    required this.id,
    required this.username,
    required this.email,
    required this.message,
    required this.status,
    this.reply = '',
    required this.createdAt,
    this.messages = const [],
  });

  factory SupportRequest.fromJson(Map<String, dynamic> json) {
    String uName = 'Khách';
    String uEmail = '';

    // Xử lý populate user
    if (json['user'] is Map) {
      uName = json['user']['username'] ?? 'Khách';
      uEmail = json['user']['email'] ?? '';
    }

    String replyText = json['reply'] ?? '';
    List<SupportMessage> parsedMessages = [];

    if (json['messages'] is List) {
      parsedMessages = (json['messages'] as List)
          .map((m) => SupportMessage.fromJson(m))
          .toList();
    }
    
    if (replyText.isEmpty && parsedMessages.isNotEmpty) {
      final staffMsg = parsedMessages.lastWhere(
        (m) => m.senderRole == 'staff' || m.senderRole == 'admin',
        orElse: () => SupportMessage(senderRole: '', text: '', timestamp: DateTime.now()),
      );
      if (staffMsg.senderRole.isNotEmpty) {
        replyText = staffMsg.text;
      }
    }

    return SupportRequest(
      id: json['_id'] ?? '',
      username: uName,
      email: uEmail,
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      reply: replyText,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      messages: parsedMessages,
    );
  }
}

class SupportMessage {
  final String senderRole;
  final String senderName;
  final String text;
  final DateTime timestamp;

  SupportMessage({
    required this.senderRole,
    this.senderName = '',
    required this.text,
    required this.timestamp,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      senderRole: json['senderRole'] ?? 'customer',
      senderName: json['senderName'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}