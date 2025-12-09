class Product {
  final String id;
  final String name; // App dùng 'name', Backend trả 'product_name'
  final double price;
  final String image;
  int stockQuantity; // Thêm trường này để hiển thị tồn kho

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.stockQuantity = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // --- XỬ LÝ ẢNH (Mảng Object hoặc String) ---
    String imgUrl = '';
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      var firstImg = json['images'][0];
      if (firstImg is String) {
        imgUrl = firstImg;
      } else if (firstImg is Map) {
        imgUrl = firstImg['image_url'] ?? '';
      }
    }

    return Product(
      id: json['_id'] ?? '',

      // --- SỬA LỖI TẠI ĐÂY (QUAN TRỌNG NHẤT) ---
      // Ưu tiên lấy 'product_name', nếu không có mới tìm 'name'
      name: json['product_name'] ?? json['name'] ?? 'Unknown Product',

      // Xử lý giá (đôi khi backend trả về object decimal)
      price: (json['price'] is Map)
          ? double.tryParse(json['price']['\$numberDecimal'].toString()) ?? 0.0
          : double.tryParse(json['price'].toString()) ?? 0.0,

      image: imgUrl,
      stockQuantity: json['stock_quantity'] ?? 0,
    );
  }
}