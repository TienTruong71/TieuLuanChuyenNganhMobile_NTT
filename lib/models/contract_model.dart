class Contract {
  final String id;
  final String contractNumber;
  final String status;
  final String fileUrl;
  final String customerName;
  final double totalAmount;
  final DateTime createdAt;

  Contract({
    required this.id,
    required this.contractNumber,
    required this.status,
    required this.fileUrl,
    required this.customerName,
    required this.totalAmount,
    required this.createdAt,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    // Xử lý snapshot khách hàng
    String cName = 'Unknown';
    if (json['customer_snapshot'] != null) {
      cName = json['customer_snapshot']['full_name'] ?? 'Unknown';
    }

    // Xử lý snapshot đơn hàng (Amount có thể là Decimal128 object)
    double total = 0.0;
    if (json['order_snapshot'] != null) {
      var amt = json['order_snapshot']['total_amount'];
      if (amt is Map && amt['\$numberDecimal'] != null) {
        total = double.tryParse(amt['\$numberDecimal'].toString()) ?? 0.0;
      } else {
        total = double.tryParse(amt.toString()) ?? 0.0;
      }
    }

    return Contract(
      id: json['_id'] ?? '',
      contractNumber: json['contract_number'] ?? '',
      status: json['status'] ?? 'draft',
      fileUrl: json['generated_file_url'] ?? '',
      customerName: cName,
      totalAmount: total,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}