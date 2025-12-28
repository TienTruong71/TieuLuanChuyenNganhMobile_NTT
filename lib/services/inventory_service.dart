import '../models/index.dart';
import 'api_config.dart';

class InventoryService {
  static const String _inventoryUrl = '/staff/inventory';
  static const String _stockUrl = '/staff/stock';
  static const String _productUrl = '/products';
  static const String _categoryStaffUrl = '/staff/categories'; // Endpoint lấy danh mục cho Staff

  Future<List<Inventory>> getInventoryList() async {
    final res = await ApiConfig.dio.get(_inventoryUrl);

    List<dynamic> list = res.data is List ? res.data : [];

    return list.map((e) {
      try { return Inventory.fromJson(e); } catch (err) { return null; }
    }).whereType<Inventory>().toList();
  }

  Future<void> addInventory(String productId, int quantity) async {
    await ApiConfig.dio.post(_inventoryUrl, data: {
      "product_id": productId,
      "quantity_available": quantity
    });
  }

  Future<void> addInventoryByName({
    required String productName,
    required String categoryName,
    required int price,
    required List<String> images,
    required int quantityAvailable,
  }) async {
    await ApiConfig.dio.post('$_inventoryUrl/add-by-name', data: {
      "product_name": productName,
      "category_name": categoryName,
      "price": price,
      "images": images,
      "quantity_available": quantityAvailable,
    });
  }

  Future<void> updateInventory(String invId, int quantity) async {
    await ApiConfig.dio.put('$_inventoryUrl/$invId', data: {
      "quantity_available": quantity
    });
  }

  Future<void> deleteInventory(String invId) async {
    await ApiConfig.dio.delete('$_inventoryUrl/$invId');
  }

  Future<List<StockTransaction>> getStockTransactions() async {
    final res = await ApiConfig.dio.get(_stockUrl);

    List<dynamic> list = res.data is List ? res.data : [];

    return list.map((e) {
      try { return StockTransaction.fromJson(e); } catch (err) { return null; }
    }).whereType<StockTransaction>().toList();
  }

  Future<void> createStockTransaction(String productId, int quantity, String type, String note) async {
    await ApiConfig.dio.post(_stockUrl, data: {
      "product_id": productId,
      "quantity": quantity,
      "type": type,
      "note": note
    });
  }

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

      final invList = await getInventoryList();
      final existingProductIds = invList.map((i) => i.productId).toList();

      return allProducts.where((p) => !existingProductIds.contains(p.id)).toList();
    } catch (e) {
      print("Lỗi getProductsNotInInventory: $e");
      return [];
    }
  }

  // HÀM MỚI
  Future<List<Category>> getCategoriesList() async {
    final res = await ApiConfig.dio.get(_categoryStaffUrl);

    List<dynamic> list = res.data is List ? res.data : [];

    return list.map((e) {
      try { return Category.fromJson(e); } catch (err) { return null; }
    }).whereType<Category>().toList();
  }
}