import '../models/index.dart';
import 'api_config.dart';

class StaffService {
  // Định nghĩa các Endpoint gốc khớp với Backend Routes
  static const String _appointmentUrl = '/staff/service/appointments';
  static const String _serviceBayUrl = '/staff/service/service-bays';
  static const String _repairProgressUrl = '/staff/service/repair-progress';

  // ---------------------------------------------------------------------------
  // 1. APPOINTMENTS (Bookings)
  // ---------------------------------------------------------------------------
  Future<List<Booking>> getBookings() async {
    final res = await ApiConfig.dio.get(_appointmentUrl);

    List<dynamic> list = [];
    if (res.data is Map && res.data['appointments'] != null) {
      list = res.data['appointments'];
    } else if (res.data is List) {
      list = res.data;
    }

    return list.map((e) {
      try {
        return Booking.fromJson(e);
      } catch (err) {
        print("Lỗi parse booking: $err");
        return null;
      }
    }).whereType<Booking>().toList();
  }

  Future<void> updateBookingStatus(String id, String status) async {
    // PUT /api/staff/service/appointments/:id
    await ApiConfig.dio.put('$_appointmentUrl/$id', data: { "status": status });
  }

  // ---------------------------------------------------------------------------
  // 2. SERVICE BAYS (Khoang xe)
  // ---------------------------------------------------------------------------

  Future<List<ServiceBay>> getServiceBays() async {
    final res = await ApiConfig.dio.get(_serviceBayUrl);

    // --- SỬA LOGIC PARSE JSON TẠI ĐÂY ---
    // Backend trả về: { "serviceBays": [...], "pagination": {...} }
    List<dynamic> list = [];

    if (res.data is Map) {
      // Ưu tiên lấy từ key 'serviceBays'
      if (res.data['serviceBays'] != null) {
        list = res.data['serviceBays'];
      } else if (res.data['data'] != null) {
        list = res.data['data'];
      }
    } else if (res.data is List) {
      list = res.data;
    }

    return list.map((e) {
      try {
        return ServiceBay.fromJson(e);
      } catch (err) {
        print("Lỗi parse bay: $err");
        return null;
      }
    }).whereType<ServiceBay>().toList();
  }

  Future<void> createBay(String number, String notes) async {
    // POST /api/staff/service/service-bays
    await ApiConfig.dio.post(_serviceBayUrl, data: {
      "bay_number": number,
      "notes": notes,
      "status": "available" // Mặc định tạo mới là trống
    });
  }

  Future<void> updateBay(String id, String notes, String status) async {
    // PUT /api/staff/service/service-bays/:id
    await ApiConfig.dio.put('$_serviceBayUrl/$id', data: {
      "notes": notes,
      "status": status
    });
  }

  // Gán xe vào khoang (Gọi PUT update khoang)
  Future<void> assignBay(String bayId, String bookingId) async {
    // Backend không có route /assign riêng, nên ta dùng PUT để update trạng thái
    await ApiConfig.dio.put('$_serviceBayUrl/$bayId', data: {
      "current_booking": bookingId, // Gán ID booking vào khoang
      "status": "occupied"          // Chuyển trạng thái thành Đang có xe
    });
  }

  // Trả xe / Giải phóng khoang (Gọi PUT update khoang)
  Future<void> checkoutBay(String bayId) async {
    // Backend không có route /checkout riêng, dùng PUT để reset
    await ApiConfig.dio.put('$_serviceBayUrl/$bayId', data: {
      "current_booking": null,      // Xóa booking khỏi khoang
      "status": "available"         // Chuyển về trạng thái Trống
    });
  }

  Future<void> deleteBay(String id) async {
    // DELETE /api/staff/service/service-bays/:id
    await ApiConfig.dio.delete('$_serviceBayUrl/$id');
  }

  // ---------------------------------------------------------------------------
  // 3. REPAIR PROGRESS (Tiến độ sửa chữa)
  // ---------------------------------------------------------------------------

  Future<List<RepairProgress>> getRepairProgress() async {
    final res = await ApiConfig.dio.get(_repairProgressUrl);

    // --- SỬA PARSE JSON ---
    // Backend trả về: { "repairProgresses": [...], "pagination": {...} }
    List<dynamic> list = [];

    if (res.data is Map) {
      if (res.data['repairProgresses'] != null) {
        list = res.data['repairProgresses'];
      } else if (res.data['data'] != null) {
        list = res.data['data'];
      }
    } else if (res.data is List) {
      list = res.data;
    }

    return list.map((e) {
      try {
        return RepairProgress.fromJson(e);
      } catch (err) {
        print("Lỗi parse progress: $err");
        return null;
      }
    }).whereType<RepairProgress>().toList();
  }

  // Tạo tiến độ mới (Thường được gọi tự động khi Gán xe, nhưng backend có route POST thì ta cứ define)
  Future<void> createProgress(Map<String, dynamic> data) async {
    // POST /api/staff/service/repair-progress
    await ApiConfig.dio.post(_repairProgressUrl, data: data);
  }

  Future<void> updateProgress(String id, Map<String, dynamic> data) async {
    // PUT /api/staff/service/repair-progress/:id
    await ApiConfig.dio.put('$_repairProgressUrl/$id', data: data);
  }

  Future<void> deleteProgress(String id) async {
    // DELETE /api/staff/service/repair-progress/:id
    await ApiConfig.dio.delete('$_repairProgressUrl/$id');
  }
}