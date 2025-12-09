import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart'; // Mở comment nếu project có gói này
import '../../data/repository.dart';
import '../../models/contract_model.dart'; // Import đúng file model

class ContractTab extends StatefulWidget {
  @override
  _ContractTabState createState() => _ContractTabState();
}

class _ContractTabState extends State<ContractTab> {
  // Vì Backend chưa có API GET /contracts, ta dùng list tạm để demo
  // Khi tạo xong sẽ add vào đây để hiển thị.
  List<Contract> contracts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData(); // Gọi hàm tải dữ liệu ngay khi vào màn hình
  }

  // Hàm tải dữ liệu từ Server
  void _loadData() async {
    try {
      final data = await Repository().getContracts(); // Gọi qua Repository -> Service
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
        print("Lỗi tải hợp đồng: $e");
      }
    }
  }
  // Xử lý tải file PDF
  void _downloadContract(Contract item) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đang tải PDF...")));

    try {
      // Giả lập đường dẫn lưu (Cần path_provider để lấy đúng path trên Android/iOS)
      // String dir = (await getApplicationDocumentsDirectory()).path;
      // String savePath = '$dir/${item.contractNumber}.pdf';

      // Tạm thời đặt tên file đơn giản để test logic gọi API
      String savePath = '/storage/emulated/0/Download/${item.contractNumber}.pdf';

      await Repository().downloadContract(item.id, savePath);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
              title: Text("Tải thành công"),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 50, color: Colors.green),
                    SizedBox(height: 10),
                    Text("Đã lưu file tại:"),
                    SizedBox(height: 4),
                    Text(savePath, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 8),
                    Text("(Lưu ý: Cần cấp quyền ghi bộ nhớ nếu chạy trên máy thật)", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11, color: Colors.red)),
                  ]
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Đóng"))
              ]
          )
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi tải file: $e"), backgroundColor: Colors.red));
    }
  }

  // Form tạo hợp đồng mới
  void _showCreateForm() {
    final _nameCtrl = TextEditingController(text: "Nguyễn Văn A");
    final _phoneCtrl = TextEditingController(text: "0988777666");
    final _emailCtrl = TextEditingController(text: "khachhang@gmail.com");
    final _addrCtrl = TextEditingController(text: "Hà Nội");
    final _amountCtrl = TextEditingController(text: "5000000");

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tạo Hợp Đồng Mới", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: "Họ tên khách", prefixIcon: Icon(Icons.person))),
              SizedBox(height: 12),
              TextField(controller: _phoneCtrl, decoration: InputDecoration(labelText: "Số điện thoại", prefixIcon: Icon(Icons.phone))),
              SizedBox(height: 12),
              TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email))),
              SizedBox(height: 12),
              TextField(controller: _addrCtrl, decoration: InputDecoration(labelText: "Địa chỉ", prefixIcon: Icon(Icons.location_on))),
              SizedBox(height: 12),
              TextField(controller: _amountCtrl, decoration: InputDecoration(labelText: "Tổng tiền (VND)", prefixIcon: Icon(Icons.attach_money)), keyboardType: TextInputType.number),
              SizedBox(height: 32),

              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: EdgeInsets.symmetric(vertical: 12)),
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
                      child: Text("XÁC NHẬN TẠO HỢP ĐỒNG")
                  )
              )
            ],
          ),
        )
    );
  }

  // Logic gọi API Create
  void _createContractAction({required String name, required String phone, required String email, required String address, required double amount}) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đang tạo hợp đồng...")));

    try {
      // Chuẩn bị dữ liệu map với Schema Backend
      final Map<String, dynamic> body = {
        // Fake ID Order (24 ký tự hex) vì backend bắt buộc trường này
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

      // Gọi Repository
      final newContract = await Repository().createContract(body);

      setState(() {
        // Thêm vào đầu danh sách để hiển thị ngay
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateForm,
        backgroundColor: Colors.green[700],
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Tạo hợp đồng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: contracts.isEmpty
          ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 50, color: Colors.orange),
              SizedBox(height: 16),
              Text("Chưa có hợp đồng nào được tạo phiên này."),
              Text("Hãy nhấn nút Tạo để thử nghiệm.", style: TextStyle(color: Colors.grey)),
            ],
          )
      )
          : ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: contracts.length,
        separatorBuilder: (c,i) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = contracts[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: (){}, // Có thể mở chi tiết nếu muốn
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                    children: [
                      Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.description_outlined, color: Colors.green[800], size: 28)
                      ),
                      SizedBox(width: 16),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.contractNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(height: 4),
                                // SỬA: Dùng trường customerName của Model mới
                                Text(item.customerName, style: TextStyle(color: Colors.black87)),
                                // SỬA: Dùng trường totalAmount của Model mới
                                Text(NumberFormat("#,###", "vi_VN").format(item.totalAmount) + " đ", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              ]
                          )
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(4)),
                                child: Text(item.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[700]))
                            ),
                            IconButton(
                              icon: Icon(Icons.download_rounded, color: Colors.blue),
                              onPressed: () => _downloadContract(item),
                              tooltip: "Tải PDF",
                            )
                          ]
                      )
                    ]
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}