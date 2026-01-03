class Booking {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String serviceId;
  final String serviceName;
  final String productId;
  final String productName;
  final String productImage;
  final DateTime bookingDate;
  final String timeSlot;
  final String status; // pending, confirmed, in_progress, completed, cancelled

  Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.serviceId,
    required this.serviceName,
    this.productId = '',
    this.productName = '',
    this.productImage = '',
    required this.bookingDate,
    required this.timeSlot,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Xử lý nested object user_id, service_id và product_id nếu API trả về populate
    final userObj = json['user_id'] is Map ? json['user_id'] : {};
    final serviceObj = json['service_id'] is Map ? json['service_id'] : {};
    final productObj = json['product_id'] is Map ? json['product_id'] : {};

    return Booking(
      id: json['_id'] ?? '',
      userId: userObj['_id'] ?? (json['user_id'] is String ? json['user_id'] : ''),
      userName: userObj['full_name'] ?? 'Unknown User',
      userPhone: userObj['phone'] ?? '',
      serviceId: serviceObj['_id'] ?? (json['service_id'] is String ? json['service_id'] : ''),
      serviceName: serviceObj['service_name'] ?? 'Unknown Service',
      productId: productObj['_id'] ?? (json['product_id'] is String ? json['product_id'] : ''),
      productName: productObj['name'] ?? '',
      productImage: productObj['image'] ?? '',
      bookingDate: DateTime.tryParse(json['booking_date'] ?? '') ?? DateTime.now(),
      timeSlot: json['time_slot'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }
}    