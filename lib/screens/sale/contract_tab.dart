// lib/screens/sale/contract_tab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';

class ContractTab extends StatefulWidget {
  @override
  _ContractTabState createState() => _ContractTabState();
}

class _ContractTabState extends State<ContractTab> {
  List<Contract> contracts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await MockData().getContracts();
    setState(() { contracts = data; isLoading = false; });
  }

  // Dialog giả lập In PDF
  void _printContract(Contract item) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đang tạo file PDF...")));
    await MockData().printContract(item.id);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("Xuất PDF thành công"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
        SizedBox(height: 10),
        Text("Đã lưu file: ${item.contractNumber}.pdf"),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Đóng"))],
    ));
  }

  // Màn hình tạo hợp đồng mới (Form)
  void _showCreateForm() {
    // Controller giả lập nhập liệu (Trong thực tế sẽ chọn Order ID để auto fill)
    final _nameCtrl = TextEditingController(text: "Nguyễn Văn A");
    final _phoneCtrl = TextEditingController(text: "0988777666");
    final _amountCtrl = TextEditingController(text: "5000000");

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tạo Hợp Đồng Mới", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Thông tin khách hàng (Từ Order)", style: TextStyle(color: Colors.grey)),
              TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: "Họ tên khách")),
              TextField(controller: _phoneCtrl, decoration: InputDecoration(labelText: "Số điện thoại")),
              SizedBox(height: 10),
              TextField(controller: _amountCtrl, decoration: InputDecoration(labelText: "Tổng tiền (VND)"), keyboardType: TextInputType.number),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    // Tạo data giả để gửi xuống MockData
                    final cus = CustomerSnapshot(fullName: _nameCtrl.text, phone: _phoneCtrl.text, email: "demo@mail.com", address: "Hà Nội");
                    final ord = OrderSnapshot(totalAmount: double.tryParse(_amountCtrl.text) ?? 0, paymentMethod: "Tiền mặt", orderDate: DateTime.now());
                    final items = [ItemSnapshot(productName: "Dịch vụ Demo", quantity: 1, price: ord.totalAmount)];

                    await MockData().createContract(cus, ord, items);
                    _loadData(); // Reload UI
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tạo hợp đồng thành công!")));
                  },
                  child: Text("XÁC NHẬN TẠO", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    if(isLoading) return Center(child: CircularProgressIndicator());
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateForm,
        backgroundColor: Colors.green[800],
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final item = contracts[index];
          return Card(
            elevation: 3, margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Icon(Icons.description, size: 40, color: Colors.blueGrey),
              title: Text(item.contractNumber, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text("Khách: ${item.customerSnapshot.fullName}"),
                  Text("Tổng: ${NumberFormat("#,###").format(item.orderSnapshot.totalAmount)} đ"),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                    child: Text(item.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.print, color: Colors.blue),
                onPressed: () => _printContract(item),
              ),
            ),
          );
        },
      ),
    );
  }
}