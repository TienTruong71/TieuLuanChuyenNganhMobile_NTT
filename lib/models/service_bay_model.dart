class ServiceBay {
  final String id;
  final String bayNumber;
  final String status; // available, occupied, maintenance
  final String? currentBookingId;
  final String notes;

  // Các trường helper để hiển thị UI (Flatten Data)
  final String? bookingUserName;
  final String? bookingServiceName;

  ServiceBay({
    required this.id,
    required this.bayNumber,
    required this.status,
    this.currentBookingId,
    this.notes = '',
    this.bookingUserName,
    this.bookingServiceName,
  });

  factory ServiceBay.fromJson(Map<String, dynamic> json) {
    // Xử lý nested object từ populate 'current_booking'
    String? bId;
    String? bUserName;
    String? bServiceName;

    if (json['current_booking'] != null) {
      if (json['current_booking'] is String) {
        bId = json['current_booking'];
      } else if (json['current_booking'] is Map) {
        // Nếu đã populate
        final bookingObj = json['current_booking'];
        bId = bookingObj['_id'];

        // Lấy tên User
        if (bookingObj['user_id'] is Map) {
          bUserName = bookingObj['user_id']['full_name'];
        }

        // Lấy tên Service
        if (bookingObj['service_id'] is Map) {
          bServiceName = bookingObj['service_id']['service_name'];
        }
      }
    }

    return ServiceBay(
      id: json['_id'] ?? '',
      bayNumber: json['bay_number'] ?? '',
      status: json['status'] ?? 'available',
      currentBookingId: bId,
      notes: json['notes'] ?? '',
      bookingUserName: bUserName,
      bookingServiceName: bServiceName,
    );
  }
}