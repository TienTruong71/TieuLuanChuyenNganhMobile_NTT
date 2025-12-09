class RepairProgress {
  final String id;
  final String bookingId;
  final String bookingServiceName;
  final String bookingUserName;
  final String staffId;
  final String staffName;
  final String status; // in_progress, waiting_parts, testing, completed
  final String notes;
  final DateTime? estimatedCompletion;

  RepairProgress({
    required this.id,
    required this.bookingId,
    required this.bookingServiceName,
    required this.bookingUserName,
    required this.staffId,
    required this.staffName,
    required this.status,
    this.notes = '',
    this.estimatedCompletion,
  });

  factory RepairProgress.fromJson(Map<String, dynamic> json) {
    // Safe parse populate booking
    String bId = '';
    String bService = 'Dịch vụ';
    String bUser = 'Khách hàng';

    if (json['booking_id'] is Map) {
      final bObj = json['booking_id'];
      bId = bObj['_id'] ?? '';

      if (bObj['service_id'] is Map) {
        bService = bObj['service_id']['service_name'] ?? '';
      }
      if (bObj['user_id'] is Map) {
        bUser = bObj['user_id']['full_name'] ?? '';
      }
    } else {
      bId = json['booking_id'] ?? '';
    }

    // Safe parse populate staff
    String sId = '';
    String sName = 'KTV';
    if (json['staff_id'] is Map) {
      sId = json['staff_id']['_id'] ?? '';
      sName = json['staff_id']['full_name'] ?? '';
    } else {
      sId = json['staff_id'] ?? '';
    }

    return RepairProgress(
      id: json['_id'] ?? '',
      bookingId: bId,
      bookingServiceName: bService,
      bookingUserName: bUser,
      staffId: sId,
      staffName: sName,
      status: json['status'] ?? 'in_progress',
      notes: json['notes'] ?? '',
      estimatedCompletion: json['estimated_completion'] != null
          ? DateTime.tryParse(json['estimated_completion'])
          : null,
    );
  }
}