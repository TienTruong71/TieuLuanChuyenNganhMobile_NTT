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
  void initState() { super.initState(); _loadData(); }
  void _loadData() async { final data = await MockData().getContracts(); setState(() { contracts = data; isLoading = false; }); }

  void _printContract(Contract item) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đang xuất PDF...")));
    await MockData().printContract(item.id);
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text("Xuất PDF thành công"), content: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle, size: 50, color: Colors.green), SizedBox(height: 10), Text("Đã lưu file: ${item.contractNumber}.pdf")]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Đóng"))]));
  }

  void _showCreateForm() {
    final _nameCtrl = TextEditingController(text: "Nguyễn Văn A");
    final _phoneCtrl = TextEditingController(text: "0988777666");
    final _amountCtrl = TextEditingController(text: "5000000");

    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Tạo Hợp Đồng Mới", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 24),
        TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: "Họ tên khách", prefixIcon: Icon(Icons.person))),
        SizedBox(height: 16),
        TextField(controller: _phoneCtrl, decoration: InputDecoration(labelText: "Số điện thoại", prefixIcon: Icon(Icons.phone))),
        SizedBox(height: 16),
        TextField(controller: _amountCtrl, decoration: InputDecoration(labelText: "Tổng tiền (VND)", prefixIcon: Icon(Icons.attach_money)), keyboardType: TextInputType.number),
        SizedBox(height: 32),
        SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]), onPressed: () async {
          Navigator.pop(ctx);
          final cus = CustomerSnapshot(fullName: _nameCtrl.text, phone: _phoneCtrl.text, email: "demo@mail.com", address: "Hà Nội");
          final ord = OrderSnapshot(totalAmount: double.tryParse(_amountCtrl.text) ?? 0, paymentMethod: "Tiền mặt", orderDate: DateTime.now());
          final items = [ItemSnapshot(productName: "Dịch vụ Demo", quantity: 1, price: ord.totalAmount)];
          await MockData().createContract(cus, ord, items);
          _loadData();
        }, child: Text("XÁC NHẬN TẠO HỢP ĐỒNG")))
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if(isLoading) return Center(child: CircularProgressIndicator());
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateForm,
        backgroundColor: Colors.green[700],
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Tạo hợp đồng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: contracts.length,
        separatorBuilder: (c,i) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = contracts[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: (){},
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(children: [
                  Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)), child: Icon(Icons.description_outlined, color: Colors.green[800], size: 28)),
                  SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.contractNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text(item.customerSnapshot.fullName, style: TextStyle(color: Colors.black87)),
                    Text(NumberFormat("#,###", "vi_VN").format(item.orderSnapshot.totalAmount) + " đ", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(4)), child: Text(item.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                    IconButton(icon: Icon(Icons.print_outlined, color: Colors.blue), onPressed: () => _printContract(item))
                  ])
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}