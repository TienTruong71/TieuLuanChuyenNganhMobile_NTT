import '../models/index.dart';
import '../models/feedback_model.dart';
import '../models/support_model.dart';
import '../models/contract_model.dart';
import '../services/auth_service.dart';
import '../services/inventory_service.dart';
import '../services/sale_service.dart';
import '../services/staff_service.dart';

class Repository {
  static final Repository _instance = Repository._internal();
  factory Repository() => _instance;
  Repository._internal();

  final _authService = AuthService();
  final _invService = InventoryService();
  final _saleService = SaleService();
  final _staffService = StaffService();

  // --- AUTH ---
  Future<User> login(String email, String pass) => _authService.login(email, pass);
  Future<void> logout() => _authService.logout();
  Future<User?> getCurrentUser() => _authService.getCurrentUser();
  Future<void> updateProfile(Map<String, dynamic> data) async {
    // Cần API update profile từ backend
  }

  // --- INVENTORY ---
  Future<List<Inventory>> getInventoryList() => _invService.getInventoryList();
  Future<void> addInventory(String pId, int qty) => _invService.addInventory(pId, qty);
  Future<void> updateInventory(String id, int qty) => _invService.updateInventory(id, qty);
  Future<List<Product>> getProductsNotInInventory() => _invService.getProductsNotInInventory();

  Future<List<StockTransaction>> getStockTransactions() => _invService.getTransactions();
  Future<void> createStockTransaction(String pId, int qty, String type, String note) =>
      _invService.createTransaction(pId, qty, type, note);

  // Helper lấy list product trong kho cho dropdown
  Future<List<Product>> getProductsInInventory() async {
    final invList = await getInventoryList();
    // Lọc những inventory có product != null
    return invList.where((i) => i.product != null).map((i) {
      i.product!.stockQuantity = i.quantityAvailable; // Sync số lượng hiển thị
      return i.product!;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // 3. SALE STAFF (Kinh doanh)
  // ---------------------------------------------------------------------------

  // --- Feedbacks ---
  // Lưu ý: Dùng FeedbackModel khớp với file model vừa tạo
  Future<List<FeedbackModel>> getFeedbacks() => _saleService.getFeedbacks();
  Future<void> approveFeedback(String id) => _saleService.approveFeedback(id);
  Future<void> deleteFeedback(String id) => _saleService.deleteFeedback(id);

  // --- Support ---
  Future<List<SupportRequest>> getSupportRequests() => _saleService.getSupportRequests();
  Future<void> replySupport(String id, String msg) => _saleService.replySupport(id, msg);

  // --- Contracts ---
  Future<List<Contract>> getContracts() => _saleService.getContracts();
  // Hàm tạo hợp đồng: Nhận Map data để linh hoạt với snapshot từ UI
  Future<Contract> createContract(Map<String, dynamic> contractData) {
    return _saleService.createContract(contractData);
  }

  // Hàm tải file PDF hợp đồng
  Future<void> downloadContract(String id, String savePath) => _saleService.downloadContract(id, savePath);

  // --- SERVICE STAFF ---
  Future<List<Booking>> getBookings() => _staffService.getBookings();
  Future<void> updateBookingStatus(String id, String status) => _staffService.updateBookingStatus(id, status);

  Future<List<ServiceBay>> getServiceBays() => _staffService.getServiceBays();
  Future<void> createServiceBay(String num, String note) => _staffService.createBay(num, note);
  Future<void> updateServiceBayInfo(String id, String note, String status) => _staffService.updateBay(id, note, status);
  Future<void> deleteServiceBay(String id) => _staffService.deleteBay(id);
  Future<void> assignBookingToBay(String bayId, String bookingId) => _staffService.assignBay(bayId, bookingId);
  Future<void> checkoutBay(String bayId) => _staffService.checkoutBay(bayId);

  Future<List<RepairProgress>> getRepairProgress() => _staffService.getRepairProgress();
  Future<void> updateRepairProgressFull(String id, {String? status, String? notes, DateTime? estimatedCompletion, bool freeBay = false}) {
    return _staffService.updateProgress(id, {
      if(status != null) "status": status,
      if(notes != null) "notes": notes,
      if(estimatedCompletion != null) "estimated_completion": estimatedCompletion.toIso8601String(),
      "free_bay": freeBay
    });
  }
  Future<void> deleteRepairProgress(String id) => _staffService.deleteProgress(id);
}