import '../models/index.dart';
import 'api_config.dart';

class StaffService {
  static const String _appointmentUrl = '/staff/service/appointments';
  static const String _serviceBayUrl = '/staff/service/service-bays';
  static const String _repairProgressUrl = '/staff/service/repair-progress';

  // ---------------------------------------------------------------------------
  // 1. APPOINTMENTS (Bookings)
  // ---------------------------------------------------------------------------

  Future<List<Booking>> getBookings({
    String? status,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? singleDate, // Thêm tham số lọc theo ngày đơn lẻ
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
      if (singleDate != null) 'date': singleDate.toIso8601String().split('T')[0], // YYYY-MM-DD
    };

    // API GET /api/staff/service/appointments
    final res = await ApiConfig.dio.get(_appointmentUrl, queryParameters: queryParams);

    List<dynamic> list = res.data['appointments'] is List ? res.data['appointments'] : [];

    return list.map((e) {
      try {
        return Booking.fromJson(e);
      } catch (err) {
        return null;
      }
    }).whereType<Booking>().toList();
  }

  Future<Booking> updateBookingStatus(String id, String status, {String? note}) async {
    // API PUT /api/staff/service/appointments/:id
    final Map<String, dynamic> data = {'status': status};
    if (note != null && note.isNotEmpty) {
      data['note'] = note;
    }
    final res = await ApiConfig.dio.put('$_appointmentUrl/$id', data: data);
    return Booking.fromJson(res.data['appointment']);
  }

  // ---------------------------------------------------------------------------
  // 2. SERVICE BAYS (Khoang xe)
  // ---------------------------------------------------------------------------

  Future<List<ServiceBay>> getServiceBays({String? status}) async {
    final Map<String, dynamic> queryParams = {
      if (status != null && status.isNotEmpty) 'status': status,
    };
    // API GET /api/staff/service/service-bays
    final res = await ApiConfig.dio.get(_serviceBayUrl, queryParameters: queryParams);

    List<dynamic> list = res.data['serviceBays'] is List ? res.data['serviceBays'] : [];

    return list.map((e) {
      try {
        return ServiceBay.fromJson(e);
      } catch (err) {
        return null;
      }
    }).whereType<ServiceBay>().toList();
  }

  Future<ServiceBay> createServiceBay(String bayNumber, String notes) async {
    // API POST /api/staff/service/service-bays
    final res = await ApiConfig.dio.post(_serviceBayUrl, data: {
      'bay_number': bayNumber,
      'notes': notes,
    });
    return ServiceBay.fromJson(res.data['serviceBay']);
  }

  Future<ServiceBay> updateServiceBayInfo(String id, String notes, String status) async {
    final data = {
      'notes': notes,
      'status': status,
    };
    // API PUT /api/staff/service/service-bays/:id
    final res = await ApiConfig.dio.put('$_serviceBayUrl/$id', data: data);
    return ServiceBay.fromJson(res.data['serviceBay']);
  }

  Future<ServiceBay> assignBookingToBay(String bayId, String bookingId) async {
    // API PUT /api/staff/service/service-bays/:id
    // Logic Backend: Gán booking và tự động tạo RepairProgress, chuyển Booking sang in_progress
    final res = await ApiConfig.dio.put('$_serviceBayUrl/$bayId', data: {
      'current_booking': bookingId,
      'status': 'occupied'
    });
    return ServiceBay.fromJson(res.data['serviceBay']);
  }

  Future<ServiceBay> checkoutBay(String bayId) async {
    // API PUT /api/staff/service/service-bays/:id
    // Frontend logic: Reset current_booking và status
    final res = await ApiConfig.dio.put('$_serviceBayUrl/$bayId', data: {
      "current_booking": null,
      "status": "available"
    });
    return ServiceBay.fromJson(res.data['serviceBay']);
  }

  Future<void> deleteServiceBay(String id) async {
    // API DELETE /api/staff/service/service-bays/:id
    await ApiConfig.dio.delete('$_serviceBayUrl/$id');
  }

  // ---------------------------------------------------------------------------
  // 3. REPAIR PROGRESS (Tiến độ sửa chữa)
  // ---------------------------------------------------------------------------

  Future<List<RepairProgress>> getRepairProgresses({String? status, String? search}) async {
    final Map<String, dynamic> queryParams = {
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    // API GET /api/staff/service/repair-progress
    final res = await ApiConfig.dio.get(_repairProgressUrl, queryParameters: queryParams);

    List<dynamic> list = res.data['repairProgresses'] is List ? res.data['repairProgresses'] : [];

    return list.map((e) {
      try {
        return RepairProgress.fromJson(e);
      } catch (err) {
        return null;
      }
    }).whereType<RepairProgress>().toList();
  }

  Future<RepairProgress> updateRepairProgressFull(String id, {
    required String status,
    String? notes,
    DateTime? estimatedCompletion,
    bool freeBay = false
  }) async {
    // API PUT /api/staff/service/repair-progress/:id
    // Logic Backend: Nếu status=completed và freeBay=true, nó sẽ giải phóng ServiceBay
    final data = {
      'status': status,
      'notes': notes,
      if (estimatedCompletion != null) 'estimated_completion': estimatedCompletion.toIso8601String(),
      'free_bay': freeBay,
    };
    final res = await ApiConfig.dio.put('$_repairProgressUrl/$id', data: data);
    return RepairProgress.fromJson(res.data['repairProgress']);
  }

  Future<void> deleteRepairProgress(String id) async {
    // API DELETE /api/staff/service/repair-progress/:id
    await ApiConfig.dio.delete('$_repairProgressUrl/$id');
  }
}