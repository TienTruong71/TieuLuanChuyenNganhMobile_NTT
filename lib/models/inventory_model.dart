// lib/models/inventory_model.dart
import 'product_model.dart';

class Inventory {
  final String id;
  final String productId;
  int quantityAvailable;
  DateTime lastUpdated;
  Product? product; // Chứa thông tin chi tiết từ populate

  Inventory({
    required this.id,
    required this.productId,
    required this.quantityAvailable,
    required this.lastUpdated,
    this.product,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    String pId = '';
    Product? pObj;

    if (json['product_id'] is Map) {
      pObj = Product.fromJson(json['product_id']);
      pId = pObj.id;
    } else {
      pId = json['product_id']?.toString() ?? '';
    }

    return Inventory(
      id: json['_id'] ?? '',
      productId: pId,
      quantityAvailable: json['quantity_available'] ?? 0,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : DateTime.now(),
      product: pObj,
    );
  }
}