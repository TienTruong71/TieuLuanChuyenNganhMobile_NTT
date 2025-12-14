import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/repository.dart';
import '../../models/contract_model.dart';

class ContractTab extends StatefulWidget {
  @override
  _ContractTabState createState() => _ContractTabState();
}

class _ContractTabState extends State<ContractTab> {
  List<Contract> contracts = [];
  bool isLoading = true;
  final Color primaryColor = Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final data = await Repository().getContracts();
      if (mounted) {
        setState(() {
          contracts = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _downloadContract(Contract item) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đang tải PDF...")));

    try {
      String savePath = '/storage/emulated/0/Download/${item.contractNumber}.pdf';
      await Repository().downloadContract(item.id, savePath);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Column(
                children: [
                  Icon(Icons.check_circle, size: 60, color: Colors.green),
                  SizedBox(height: 12),
                  Text("Tải thành công", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Đã lưu file tại:", style: TextStyle(color: Colors.grey[600])),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(savePath, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  ]
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Đóng", style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ]
          )
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi tải file: $e"), backgroundColor: Colors.red));
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  void _showCreateForm() {
    final _nameCtrl = TextEditingController(text: "Nguyễn Văn A");
    final _phoneCtrl = TextEditingController(text: "0988777666");
    final _emailCtrl = TextEditingController(text: "khachhang@gmail.com");
    final _addrCtrl = TextEditingController(text: "Hà Nội");
    final _amountCtrl = TextEditingController(text: "5000000");

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              SizedBox(height: 24),
              Text("Tạo Hợp Đồng Mới", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 24),
              TextField(controller: _nameCtrl, decoration: _inputDecoration("Họ tên khách", Icons.person_outline)),
              SizedBox(height: 16),
              TextField(controller: _phoneCtrl, decoration: _inputDecoration("Số điện thoại", Icons.phone_outlined), keyboardType: TextInputType.phone),
              SizedBox(height: 16),
              TextField(controller: _emailCtrl, decoration: _inputDecoration("Email", Icons.email_outlined), keyboardType: TextInputType.emailAddress),
              SizedBox(height: 16),
              TextField(controller: _addrCtrl, decoration: _inputDecoration("Địa chỉ", Icons.location_on_outlined)),
              SizedBox(height: 16),
              TextField(controller: _amountCtrl, decoration: _inputDecoration("Tổng tiền (VND)", Icons.attach_money), keyboardType: TextInputType.number),
              SizedBox(height: 32),

              SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        _createContractAction(
                            name: _nameCtrl.text,
                            phone: _phoneCtrl.text,
                            email: _emailCtrl.text,
                            address: _addrCtrl.text,
                            amount: double.tryParse(_amountCtrl.text) ?? 0
                        );
                      },
                      child: Text("XÁC NHẬN TẠO", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                  )
              )
            ],
          ),
        )
    );
  }

  void _createContractAction({required String name, required String phone, required String email, required String address, required double amount}) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đang tạo hợp đồng...")));

    try {
      final Map<String, dynamic> body = {
        "order_id": "654321000000000000000999",
        "contract_number": "HD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}",
        "customer_snapshot": {
          "full_name": name,
          "email": email,
          "phone": phone,
          "address": address
        },
        "order_snapshot": {
          "total_amount": amount,
          "payment_method": "Tiền mặt",
          "createdAt": DateTime.now().toIso8601String()
        },
        "items_snapshot": [
          {
            "product_name": "Gói dịch vụ bảo dưỡng",
            "quantity": 1,
            "price": amount
          }
        ]
      };

      final newContract = await Repository().createContract(body);

      setState(() {
        contracts.insert(0, newContract);
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tạo hợp đồng thành công!"), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateForm,
        backgroundColor: primaryColor,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Tạo Hợp Đồng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : contracts.isEmpty
          ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                child: Icon(Icons.description_outlined, size: 60, color: Colors.grey[300]),
              ),
              SizedBox(height: 16),
              Text("Chưa có hợp đồng nào", style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600)),
              Text("Nhấn nút tạo mới để bắt đầu", style: TextStyle(color: Colors.grey[500])),
            ],
          )
      )
          : ListView.separated(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: contracts.length,
        separatorBuilder: (c, i) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = contracts[index];
          final isDraft = item.status.toLowerCase() == 'draft';

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.article_rounded, color: primaryColor, size: 24),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.contractNumber,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDraft ? Colors.orange[50] : Colors.green[50],
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: isDraft ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      item.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isDraft ? Colors.orange[800] : Colors.green[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.cloud_download_outlined, color: Colors.blue[600]),
                            onPressed: () => _downloadContract(item),
                            tooltip: "Tải PDF",
                          )
                        ],
                      ),
                      Divider(height: 24, color: Colors.grey[100], thickness: 1),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Khách hàng", style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        item.customerName,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey[800]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Tổng giá trị", style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                SizedBox(height: 4),
                                Text(
                                  NumberFormat("#,###", "vi_VN").format(item.totalAmount) + " đ",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}