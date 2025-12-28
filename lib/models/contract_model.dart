class Contract {
  final String id;
  final String orderId;
  final String contractNumber;
  final String status;
  final String fileUrl;

  final String customerName;
  final String customerPhone;
  final String customerEmail;

  final double totalAmount;
  final String paymentMethod;
  final DateTime createdAt;

  Contract({
    required this.id,
    required this.orderId,
    required this.contractNumber,
    required this.status,
    required this.fileUrl,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    // ===== CUSTOMER SNAPSHOT =====
    final customer = json['customer_snapshot'] ?? {};

    // ===== ORDER SNAPSHOT =====
    final order = json['order_snapshot'] ?? {};

    // Handle Decimal128
    double parseAmount(dynamic value) {
      if (value is Map && value['\$numberDecimal'] != null) {
        return double.tryParse(value['\$numberDecimal']) ?? 0;
      }
      return double.tryParse(value.toString()) ?? 0;
    }

    return Contract(
      id: json['_id'] ?? '',
      orderId: json['order_id'] ?? '',
      contractNumber: json['contract_number'] ?? '',
      status: json['status'] ?? 'issued',
      fileUrl: json['generated_file_url'] ?? '',

      customerName: customer['full_name'] ?? 'Unknown',
      customerPhone: customer['phone'] ?? '',
      customerEmail: customer['email'] ?? '',

      totalAmount: parseAmount(order['total_amount']),
      paymentMethod: order['payment_method'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
