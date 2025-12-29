class FeedbackModel {
  final String id;
  final String username;
  final String productName;
  final String serviceName;
  final int rating;
  final String comment;
  final String status;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.username,
    required this.productName,
    required this.serviceName,
    required this.rating,
    required this.comment,
    required this.status,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    // Xử lý populate user_id
    String uName = 'Ẩn danh';
    if (json['user_id'] is Map) {
      uName = json['user_id']['username'] ?? 'Ẩn danh';
    }

    // Xử lý populate product_id
    String pName = '';
    if (json['product_id'] != null) {
      if (json['product_id'] is Map) {
        pName = json['product_id']['product_name'] ?? '';
      } else {
        pName = "Sản phẩm #${json['product_id'].toString().substring(0, 4)}";
      }
    }

    // Xử lý populate service_id
    String sName = '';
    if (json['service_id'] != null) {
      if (json['service_id'] is Map) {
        sName = json['service_id']['service_name'] ?? '';
      } else {
        sName = "Dịch vụ #${json['service_id'].toString().substring(0, 4)}";
      }
    }

    return FeedbackModel(
      id: json['_id'] ?? '',
      username: uName,
      productName: pName,
      serviceName: sName,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}