class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String roleName;
  String? token;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.roleName,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Xử lý Role
    String parsedRole = 'service'; // Mặc định
    if (json['role'] != null) {
      parsedRole = json['role'];
    }

    return User(
      id: json['_id'] ?? '',
      // Map đúng key 'full_name' từ JSON
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      roleName: parsedRole.toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'role': roleName,
      'token': token,
    };
  }
}