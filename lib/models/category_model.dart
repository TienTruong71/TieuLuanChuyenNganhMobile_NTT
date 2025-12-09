class Category {
  final String id;
  final String name;
  final String image;

  Category({
    required this.id,
    required this.name,
    this.image = '',
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['category_name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}