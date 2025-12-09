class StockTransaction {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final String type;
  final String note;
  final String createdBy; // Sẽ chứa tên người dùng
  final DateTime createdAt;

  StockTransaction({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.type,
    required this.note,
    required this.createdBy,
    required this.createdAt,
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    // 1. Xử lý Product (Populate)
    String pId = '';
    String pName = 'Unknown Product';
    String pImage = '';

    if (json['product_id'] is Map) {
      final pObj = json['product_id'];
      pId = pObj['_id'] ?? '';
      pName = pObj['product_name'] ?? 'Unknown';

      // Xử lý ảnh trong product populate
      if (pObj['images'] != null && (pObj['images'] as List).isNotEmpty) {
        var img = pObj['images'][0];
        pImage = (img is Map) ? img['image_url'] : img.toString();
      }
    } else {
      pId = json['product_id']?.toString() ?? '';
    }

    // 2. Xử lý User (Populate) - SỬA ĐỂ HIỆN TÊN
    String creatorName = 'Unknown Staff';
    if (json['created_by'] != null) {
      if (json['created_by'] is Map) {
        // Nếu backend đã populate
        creatorName = json['created_by']['full_name'] ?? 'Staff';
      } else {
        // Nếu backend chỉ trả ID
        creatorName = "Staff ID: ${json['created_by'].toString().substring(0, 5)}...";
      }
    }

    return StockTransaction(
      id: json['_id'] ?? '',
      productId: pId,
      productName: pName,
      productImage: pImage,
      quantity: json['quantity'] ?? 0,
      type: json['type'] ?? 'inbound',
      note: json['note'] ?? '',
      createdBy: creatorName, // Gán tên đã xử lý
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}