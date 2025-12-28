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
  Future<void> updateProfile(Map<String, dynamic> data) async {}

  // --- INVENTORY ---
  Future<List<Inventory>> getInventoryList() => _invService.getInventoryList();
  Future<void> addInventory(String pId, int qty) => _invService.addInventory(pId, qty);

  Future<void> addInventoryByName({
    required String productName,
    required String categoryName,
    required int price,
    required List<String> images,
    required int quantityAvailable,
  }) => _invService.addInventoryByName(
    productName: productName,
    categoryName: categoryName,
    price: price,
    images: images,
    quantityAvailable: quantityAvailable,
  );

  Future<void> updateInventory(String id, int qty) => _invService.updateInventory(id, qty);
  Future<List<Product>> getProductsNotInInventory() => _invService.getProductsNotInInventory();

  Future<List<StockTransaction>> getStockTransactions() => _invService.getStockTransactions();
  Future<void> createStockTransaction(String pId, int qty, String type, String note) =>
      _invService.createStockTransaction(pId, qty, type, note);

  Future<List<Product>> getProductsInInventory() => _invService.getProductsInInventory();
  Future<List<Category>> getCategories() => _invService.getCategoriesList();


  // ---------------------------------------------------------------------------
  // 3. SALE STAFF (Kinh doanh) - Giữ nguyên
  // ---------------------------------------------------------------------------

  Future<List<FeedbackModel>> getFeedbacks() => _saleService.getFeedbacks();
  Future<void> approveFeedback(String id) => _saleService.approveFeedback(id);
  Future<void> deleteFeedback(String id) => _saleService.deleteFeedback(id);

  Future<List<SupportRequest>> getSupportRequests() => _saleService.getSupportRequests();
  Future<void> replySupport(String id, String msg) => _saleService.replySupport(id, msg);

  Future<List<Contract>> getContracts() => _saleService.getContracts();
  Future<Contract> createContract(Map<String, dynamic> contractData) {
    return _saleService.createContract(contractData);
  }
// Lấy order chưa có hợp đồng
Future<List<Map<String, dynamic>>> getOrdersNoContract() {
  return _saleService.getOrdersNoContract();
}

// Tạo hợp đồng từ order
Future<Contract> createContractFromOrder(String orderId) {
  return _saleService.createContractFromOrder(orderId);
}


  Future<void> downloadContract(String id, String savePath) => _saleService.downloadContract(id, savePath);


  // ---------------------------------------------------------------------------
  // 4. SERVICE STAFF (Dịch vụ) - CẬP NHẬT FULL
  // ---------------------------------------------------------------------------

  // --- Appointments / Bookings ---
  Future<List<Booking>> getBookings({String? status, String? search}) =>
      _staffService.getBookings(status: status, search: search);
  Future<Booking> updateBookingStatus(String id, String status) => _staffService.updateBookingStatus(id, status);

  // --- Service Bays ---
  Future<List<ServiceBay>> getServiceBays({String? status}) => _staffService.getServiceBays(status: status);
  Future<ServiceBay> createServiceBay(String num, String note) => _staffService.createServiceBay(num, note);
  Future<ServiceBay> updateServiceBayInfo(String id, String notes, String status) => _staffService.updateServiceBayInfo(id, notes, status);
  Future<ServiceBay> assignBookingToBay(String bayId, String bookingId) => _staffService.assignBookingToBay(bayId, bookingId);
  Future<ServiceBay> checkoutBay(String bayId) => _staffService.checkoutBay(bayId);
  Future<void> deleteServiceBay(String id) => _staffService.deleteServiceBay(id);

  // --- Repair Progress ---
  Future<List<RepairProgress>> getRepairProgress() => _staffService.getRepairProgresses();
  Future<RepairProgress> updateRepairProgressFull(String id, {
    required String status,
    String? notes,
    DateTime? estimatedCompletion,
    bool freeBay = false
  }) => _staffService.updateRepairProgressFull(
      id, status: status, notes: notes, estimatedCompletion: estimatedCompletion, freeBay: freeBay
  );
  Future<void> deleteRepairProgress(String id) => _staffService.deleteRepairProgress(id);
}