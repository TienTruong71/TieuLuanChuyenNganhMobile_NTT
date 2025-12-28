import 'package:dio/dio.dart';

import '../models/contract_model.dart';
import '../models/feedback_model.dart';
import '../models/support_model.dart';
import 'api_config.dart';

class SaleService {
  static const String _contractUrl = '/staff/sale/contracts';
  static const String _feedbackUrl = '/staff/sale/feedbacks';
  static const String _supportUrl = '/staff/sale/support';

  // ================= FEEDBACK =================
  Future<List<FeedbackModel>> getFeedbacks() async {
    final res = await ApiConfig.dio.get(_feedbackUrl);
    final list = res.data['data'] ?? res.data;
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
    final list = res.data['data'] ?? res.data;
    return List.from(list)
        .map((e) => SupportRequest.fromJson(e))
        .toList();
  }

  Future<void> replySupport(String id, String message) async {
    await ApiConfig.dio.put(
      '$_supportUrl/$id/reply',
      data: {"replyMessage": message},
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
    final res = await ApiConfig.dio.get('/staff/sale/orders/no-contract');
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
