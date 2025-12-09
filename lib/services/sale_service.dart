import '../models/contract_model.dart';
import '../models/feedback_model.dart';
import '../models/support_model.dart';
import 'api_config.dart';
import 'package:dio/dio.dart'; // Import để dùng ResponseType

class SaleService {
  static const String _contractUrl = '/staff/sale/contracts';
  static const String _feedbackUrl = '/staff/sale/feedbacks';
  static const String _supportUrl = '/staff/sale/support';

  // --- FEEDBACKS ---
  Future<List<FeedbackModel>> getFeedbacks() async {
    final res = await ApiConfig.dio.get(_feedbackUrl);
    List<dynamic> list = (res.data is List) ? res.data : [];
    return list.map((e) => FeedbackModel.fromJson(e)).toList();
  }

  Future<void> approveFeedback(String id) async {
    await ApiConfig.dio.put('$_feedbackUrl/$id/approve');
  }

  Future<void> deleteFeedback(String id) async {
    await ApiConfig.dio.delete('$_feedbackUrl/$id');
  }

  // --- SUPPORT REQUESTS ---
  Future<List<SupportRequest>> getSupportRequests() async {
    final res = await ApiConfig.dio.get(_supportUrl);
    List<dynamic> list = (res.data is List) ? res.data : [];
    return list.map((e) => SupportRequest.fromJson(e)).toList();
  }

  Future<void> replySupport(String id, String message) async {
    await ApiConfig.dio.put('$_supportUrl/$id/reply', data: {
      "replyMessage": message
    });
  }

  // --- CONTRACTS ---
  Future<List<Contract>> getContracts() async {
    final res = await ApiConfig.dio.get(_contractUrl);

    List<dynamic> list = [];
    // Kiểm tra cấu trúc trả về (Mảng trực tiếp hoặc bọc trong data)
    if (res.data is List) {
      list = res.data;
    } else if (res.data is Map && res.data['data'] != null) {
      list = res.data['data']; // Phòng trường hợp bạn bọc response
    }

    return list.map((e) => Contract.fromJson(e)).toList();
  }  // Hàm này dùng để tạo hợp đồng mới từ Order
  Future<Contract> createContract(Map<String, dynamic> contractData) async {
    final res = await ApiConfig.dio.post(_contractUrl, data: contractData);
    if (res.data['success'] == true && res.data['data'] != null) {
      return Contract.fromJson(res.data['data']);
    }
    throw Exception(res.data['message'] ?? "Lỗi tạo hợp đồng");
  }

  // Tải file PDF hợp đồng
  Future<void> downloadContract(String id, String savePath) async {
    await ApiConfig.dio.download(
      '$_contractUrl/$id/print',
      savePath,
      options: Options(responseType: ResponseType.bytes),
    );
  }
}