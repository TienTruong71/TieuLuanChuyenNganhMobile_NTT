class SupportRequest {
  final String id;
  final String username;
  final String email;
  final String message;
  final String status;
  final String reply; // Backend không trả về trong schema nhưng controller có lưu
  final DateTime createdAt;

  SupportRequest({
    required this.id,
    required this.username,
    required this.email,
    required this.message,
    required this.status,
    this.reply = '',
    required this.createdAt,
  });

  factory SupportRequest.fromJson(Map<String, dynamic> json) {
    String uName = 'Khách';
    String uEmail = '';

    // Xử lý populate user
    if (json['user'] is Map) {
      uName = json['user']['username'] ?? 'Khách';
      uEmail = json['user']['email'] ?? '';
    }

    return SupportRequest(
      id: json['_id'] ?? '',
      username: uName,
      email: uEmail,
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      reply: json['reply'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}