import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/repository.dart';
import '../../models/contract_model.dart';

/// ================= ORDER LITE =================
/// Chỉ dùng trong UI chọn Order
class OrderLite {
  final String id;
  final String customerName;
  final double totalAmount;

  OrderLite({
    required this.id,
    required this.customerName,
    required this.totalAmount,
  });

  factory OrderLite.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic value) {
      if (value is Map && value['\$numberDecimal'] != null) {
        return double.tryParse(value['\$numberDecimal']) ?? 0;
      }
      return double.tryParse(value.toString()) ?? 0;
    }

    return OrderLite(
      id: json['_id'] ?? '',
      customerName: json['customer']?['full_name'] ?? 'Unknown',
      totalAmount: parseAmount(json['total_amount']),
    );
  }
}

/// ================= CONTRACT TAB =================
class ContractTab extends StatefulWidget {
  @override
  State<ContractTab> createState() => _ContractTabState();
}

class _ContractTabState extends State<ContractTab> {
  List<Contract> contracts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  // ================= LOAD CONTRACTS =================
  Future<void> _loadContracts() async {
    try {
      final data = await Repository().getContracts();
      if (mounted) {
        setState(() {
          contracts = data;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // ================= PICK ORDER =================
  void _showOrderPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: Repository().getOrdersNoContract(),
          builder: (_, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final orders =
                snapshot.data!.map(OrderLite.fromJson).toList();

            if (orders.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text("Không có order nào chưa tạo hợp đồng"),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final o = orders[i];
                return Card(
                  child: ListTile(
                    title: Text(o.customerName),
                    subtitle: Text(
                      "Tổng tiền: ${NumberFormat("#,###", "vi_VN").format(o.totalAmount)} đ",
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _createContractFromOrder(o.id);
                      },
                      child: const Text("Tạo hợp đồng"),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ================= CREATE CONTRACT =================
  Future<void> _createContractFromOrder(String orderId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đang tạo hợp đồng...")),
    );

    try {
      final contract =
          await Repository().createContractFromOrder(orderId);

      setState(() {
        contracts.insert(0, contract);
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tạo hợp đồng thành công")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  // ================= DOWNLOAD PDF =================
  Future<void> _downloadContract(Contract c) async {
    final savePath =
        "/storage/emulated/0/Download/${c.contractNumber}.pdf";

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đang tải PDF...")),
    );

    try {
      await Repository().downloadContract(c.id, savePath);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã lưu tại: $savePath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải file: $e")),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showOrderPicker,
        icon: const Icon(Icons.add),
        label: const Text("Tạo hợp đồng"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : contracts.isEmpty
              ? const Center(child: Text("Chưa có hợp đồng"))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: contracts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final c = contracts[i];
                    return Card(
                      child: ListTile(
                        leading:
                            const Icon(Icons.description_outlined),
                        title: Text(c.contractNumber),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(c.customerName),
                            Text(
                              "${NumberFormat("#,###", "vi_VN").format(c.totalAmount)} đ",
                              style:
                                  const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "Thanh toán: ${c.paymentMethod}",
                              style:
                                  const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download,
                              color: Colors.blue),
                          onPressed: () =>
                              _downloadContract(c),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(c.contractNumber),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Khách hàng: ${c.customerName}"),
                                  Text("SĐT: ${c.customerPhone}"),
                                  Text("Email: ${c.customerEmail}"),
                                  const SizedBox(height: 8),
                                  Text(
                                      "Tổng tiền: ${NumberFormat("#,###", "vi_VN").format(c.totalAmount)} đ"),
                                  Text(
                                      "Trạng thái: ${c.status}"),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text("Đóng"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
