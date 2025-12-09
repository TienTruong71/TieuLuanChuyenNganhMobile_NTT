import '../models/index.dart';
import 'api_config.dart';

class InventoryService {
  // Định nghĩa Endpoint theo cấu trúc backend
  static const String _inventoryUrl = '/staff/inventory';
  static const String _stockUrl = '/staff/stock';

  // (Nếu bạn chưa có API lấy all products, tạm thời dùng endpoint này nếu có, hoặc để trống)
  static const String _productUrl = '/products';

  // ---------------------------------------------------------------------------
  // 1. INVENTORY (Quản lý kho)
  // ---------------------------------------------------------------------------

  Future<List<Inventory>> getInventoryList() async {
    // GET /api/staff/inventory
    final res = await ApiConfig.dio.get(_inventoryUrl);

    // Backend trả về mảng trực tiếp: [...]
    // Tuy nhiên, để an toàn ta vẫn check kiểu dữ liệu
    List<dynamic> list = [];
    if (res.data is List) {
      list = res.data;
    } else if (res.data is Map && res.data['data'] != null) {
      list = res.data['data'];
    }

    return list.map((e) {
      try { return Inventory.fromJson(e); } catch (err) { return null; }
    }).whereType<Inventory>().toList();
  }

  Future<void> addInventory(String productId, int quantity) async {
    // POST /api/staff/inventory
    await ApiConfig.dio.post(_inventoryUrl, data: {
      "product_id": productId,
      "quantity_available": quantity
    });
  }

  Future<void> updateInventory(String invId, int quantity) async {
    // PUT /api/staff/inventory/:id
    await ApiConfig.dio.put('$_inventoryUrl/$invId', data: {
      "quantity_available": quantity
    });
  }

  Future<void> deleteInventory(String invId) async {
    // DELETE /api/staff/inventory/:id
    await ApiConfig.dio.delete('$_inventoryUrl/$invId');
  }

  // ---------------------------------------------------------------------------
  // 2. STOCK TRANSACTIONS (Nhập/Xuất kho)
  // ---------------------------------------------------------------------------

  Future<List<StockTransaction>> getTransactions() async {
    // GET /api/staff/stock
    final res = await ApiConfig.dio.get(_stockUrl);

    List<dynamic> list = [];
    if (res.data is List) {
      list = res.data;
    }

    return list.map((e) {
      try { return StockTransaction.fromJson(e); } catch (err) { return null; }
    }).whereType<StockTransaction>().toList();
  }

  Future<void> createTransaction(String productId, int quantity, String type, String note) async {
    // POST /api/staff/stock
    await ApiConfig.dio.post(_stockUrl, data: {
      "product_id": productId,
      "quantity": quantity,
      "type": type,
      "note": note
    });
  }

  // ---------------------------------------------------------------------------
  // 3. HELPER METHODS (Xử lý dữ liệu cho UI)
  // ---------------------------------------------------------------------------

  Future<List<Product>> getProductsInInventory() async {
    final invList = await getInventoryList();
    return invList.where((i) => i.product != null).map((i) {
      i.product!.stockQuantity = i.quantityAvailable;
      return i.product!;
    }).toList();
  }

  Future<List<Product>> getProductsNotInInventory() async {
    try {
      final res = await ApiConfig.dio.get(_productUrl);
      List<dynamic> allProductsJson = (res.data is List) ? res.data : [];
      List<Product> allProducts = allProductsJson.map((e) => Product.fromJson(e)).toList();

      // 2. Lấy danh sách đang có trong kho
      final invList = await getInventoryList();
      final existingProductIds = invList.map((i) => i.productId).toList();

      // 3. Lọc ra những sp chưa có
      return allProducts.where((p) => !existingProductIds.contains(p.id)).toList();
    } catch (e) {
      print("Lỗi getProductsNotInInventory: $e");
      return []; // Trả về rỗng nếu lỗi
    }
  }
}