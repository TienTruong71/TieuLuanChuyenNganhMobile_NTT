// lib/screens/inventory/stock_transaction_tab.dart
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';

class StockTransactionTab extends StatefulWidget {
  @override
  _StockTransactionTabState createState() => _StockTransactionTabState();
}

class _StockTransactionTabState extends State<StockTransactionTab> {
  String _transactionType = 'inbound'; // 'inbound' or 'outbound'
  Product? _selectedProduct;
  final _qtyCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  List<Product> _availableProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    final list = await MockData().getProductsInInventory();
    setState(() { _availableProducts = list; });
  }

  void _submitTransaction() async {
    if (_selectedProduct == null || _qtyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vui lòng nhập đủ thông tin")));
      return;
    }

    int qty = int.tryParse(_qtyCtrl.text) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Số lượng phải > 0")));
      return;
    }

    try {
      await MockData().createStockTransaction(
          _selectedProduct!.id,
          qty,
          _transactionType,
          _noteCtrl.text
      );

      // Reset form
      setState(() {
        _qtyCtrl.clear();
        _noteCtrl.clear();
        _selectedProduct = null;
      });
      _loadProducts(); // Reload để cập nhật tồn kho mới nhất trong dropdown

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${_transactionType == 'inbound' ? 'Nhập' : 'Xuất'} kho thành công!"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Chọn loại giao dịch
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(child: _buildTypeButton('inbound', 'NHẬP KHO', Icons.arrow_downward)),
                Expanded(child: _buildTypeButton('outbound', 'XUẤT KHO', Icons.arrow_upward)),
              ],
            ),
          ),
          SizedBox(height: 24),

          // 2. Form nhập liệu
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Thông tin phiếu ${_transactionType == 'inbound' ? 'nhập' : 'xuất'}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                  Divider(),
                  SizedBox(height: 10),

                  // Chọn sản phẩm
                  DropdownButtonFormField<Product>(
                    value: _selectedProduct,
                    decoration: InputDecoration(
                        labelText: "Chọn sản phẩm",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search)
                    ),
                    isExpanded: true,
                    items: _availableProducts.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text("${p.name} (Tồn: ${p.stockQuantity})", overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedProduct = val),
                  ),
                  SizedBox(height: 16),

                  // Nhập số lượng
                  TextField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Số lượng",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                        suffixText: "Đơn vị"
                    ),
                  ),
                  SizedBox(height: 16),

                  // Ghi chú
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                        labelText: "Ghi chú / Lý do",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note)
                    ),
                  ),
                  SizedBox(height: 24),

                  // Nút Submit
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _transactionType == 'inbound' ? Colors.green : Colors.red,
                      ),
                      onPressed: _submitTransaction,
                      child: Text(
                          _transactionType == 'inbound' ? "XÁC NHẬN NHẬP KHO" : "XÁC NHẬN XUẤT KHO",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTypeButton(String type, String label, IconData icon) {
    final isSelected = _transactionType == type;
    return GestureDetector(
      onTap: () => setState(() => _transactionType = type),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : []
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? (type == 'inbound' ? Colors.green : Colors.red) : Colors.grey),
            SizedBox(width: 8),
            Text(label, style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black87 : Colors.grey
            )),
          ],
        ),
      ),
    );
  }
}