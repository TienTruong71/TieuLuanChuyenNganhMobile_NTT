import 'package:dio/dio.dart';

import '../models/contract_model.dart';
import '../models/feedback_model.dart';
import '../models/support_model.dart';
import '../models/booking_model.dart';
import 'api_config.dart';

class SaleService {
  static const String _contractUrl = '/staff/sale/contracts';
  static const String _feedbackUrl = '/staff/sale/feedbacks';
  static const String _supportUrl = '/staff/sale/support';
  static const String _appointmentUrl = '/staff/sale/appointments';

  // ================= APPOINTMENT (TEST DRIVE) =================
  Future<List<Booking>> getTestDriveBookings({String status = '', String? date}) async {
    final query = <String, dynamic>{};
    if (status.isNotEmpty) query['status'] = status;
    if (date != null && date.isNotEmpty) query['date'] = date;

    final res = await ApiConfig.dio.get(_appointmentUrl, queryParameters: query);
    
    final data = res.data;
    List<dynamic> list = [];

    if (data is Map && data.containsKey('appointments')) {
      list = data['appointments'];
    } else if (data['data'] != null) {
      list = data['data'];
    } else {
        // Fallback or empty
    }

    return list.map((e) => Booking.fromJson(e)).toList();
  }

  Future<void> updateTestDriveStatus(String id, String status, {String? note}) async {
    final data = {'status': status};
    if (note != null && note.isNotEmpty) {
      data['note'] = note;
    }
    await ApiConfig.dio.put('$_appointmentUrl/$id', data: data);
  }

  // ================= FEEDBACK =================
  Future<List<FeedbackModel>> getFeedbacks() async {
    final res = await ApiConfig.dio.get(_feedbackUrl);
    
    // Fix: Handle both List and Map response structure
    dynamic list;
    if (res.data is Map && res.data['data'] != null) {
      list = res.data['data'];
    } else {
      list = res.data;
    }

    if (list is! List) return [];

    return List.from(list).map((e) => FeedbackModel.fromJson(e)).toList();
  }

  Future<void> approveFeedback(String id) async {
    await ApiConfig.dio.put('$_feedbackUrl/$id/approve');
  }

  Future<void> deleteFeedback(String id) async {
    await ApiConfig.dio.delete('$_feedbackUrl/$id');
  }

  // ================= SUPPORT =================
  Future<List<SupportRequest>> getSupportRequests() async {
    final res = await ApiConfig.dio.get(_supportUrl);
    // Backend returns { supportRequests: [...], pagination: {...} }
    final data = res.data;
    List<dynamic> list = [];

    if (data is Map && data.containsKey('supportRequests')) {
      list = data['supportRequests'];
    } else if (data is List) {
      list = data;
    } else if (data['data'] != null) {
      list = data['data'];
    }

    return list.map((e) => SupportRequest.fromJson(e)).toList();
  }

  Future<SupportRequest> getSupportRequestById(String id) async {
    final res = await ApiConfig.dio.get('$_supportUrl/$id');
    return SupportRequest.fromJson(res.data);
  }

  Future<void> replySupport(String id, String message) async {
    await ApiConfig.dio.put(
      '$_supportUrl/$id/reply',
      data: {"text": message},
    );
  }

  Future<void> resolveSupport(String id) async {
    await ApiConfig.dio.put(
      '$_supportUrl/$id/reply',
      data: {"status": "resolved"},
    );
  }

  // ================= CONTRACT =================
  Future<List<Contract>> getContracts() async {
    final res = await ApiConfig.dio.get(_contractUrl);
    final list = res.data['data'] ?? res.data;
    return List.from(list).map((e) => Contract.fromJson(e)).toList();
  }

  Future<Contract> createContract(Map<String, dynamic> data) async {
    final res = await ApiConfig.dio.post(_contractUrl, data: data);
    return Contract.fromJson(res.data['data']);
  }

  // ================= ORDER - NO CONTRACT =================
  /// Lấy danh sách order chưa có hợp đồng
  Future<List<Map<String, dynamic>>> getOrdersNoContract() async {
    final res = await ApiConfig.dio.get('/staff/sale/contracts/pending-orders');
    final list = res.data['data'] ?? res.data;
    return List<Map<String, dynamic>>.from(list);
  }

  // ================= CREATE CONTRACT FROM ORDER =================
  /// Tạo hợp đồng từ order có sẵn
  Future<Contract> createContractFromOrder(String orderId) async {
    final res = await ApiConfig.dio.post(
      _contractUrl,
      data: {"order_id": orderId},
    );
    return Contract.fromJson(res.data['data']);
  }

  // ================= DOWNLOAD PDF =================
  Future<void> downloadContract(String id, String savePath) async {
    await ApiConfig.dio.download(
      '$_contractUrl/$id/print',
      savePath,
      options: Options(responseType: ResponseType.bytes),
    );
  }
}
