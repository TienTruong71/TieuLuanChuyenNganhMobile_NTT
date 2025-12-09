import 'package:flutter/material.dart';
import '../../data/repository.dart'; // Sử dụng Repository (API thật)
import '../../models/index.dart';    // Sử dụng index models

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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Tải danh sách sản phẩm từ API
  void _loadProducts() async {
    try {
      final list = await Repository().getProductsInInventory();
      if (mounted) {
        setState(() {
          _availableProducts = list;
        });
      }
    } catch (e) {
      // Xử lý lỗi tải sản phẩm (im lặng hoặc log)
      print("Lỗi tải sản phẩm: $e");
    }
  }

  void _submitTransaction() async {
    // 1. Validate
    if (_selectedProduct == null || _qtyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vui lòng nhập đủ thông tin")));
      return;
    }

    int qty = int.tryParse(_qtyCtrl.text) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Số lượng phải > 0")));
      return;
    }

    setState(() => isLoading = true);

    // 2. Gọi API
    try {
      await Repository().createStockTransaction(
          _selectedProduct!.id,
          qty,
          _transactionType,
          _noteCtrl.text
      );

      // 3. Thành công -> Reset Form
      setState(() {
        _qtyCtrl.clear();
        _noteCtrl.clear();
        _selectedProduct = null;
        isLoading = false;
      });

      _loadProducts(); // Reload để cập nhật tồn kho mới nhất trong dropdown

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${_transactionType == 'inbound' ? 'Nhập' : 'Xuất'} kho thành công!"),
        backgroundColor: Colors.green,
      ));

    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTypeInbound = _transactionType == 'inbound';
    final themeColor = isTypeInbound ? Colors.green : Colors.red;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Selector Loại Giao Dịch (Modern Style)
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(child: _buildTypeButton('inbound', 'NHẬP KHO', Icons.login)),
                Expanded(child: _buildTypeButton('outbound', 'XUẤT KHO', Icons.logout)),
              ],
            ),
          ),
          SizedBox(height: 24),

          // 2. Form Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(isTypeInbound ? Icons.add_circle : Icons.remove_circle, color: themeColor),
                      SizedBox(width: 8),
                      Text(
                          isTypeInbound ? "Phiếu Nhập Hàng" : "Phiếu Xuất Hàng",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: themeColor)
                      ),
                    ],
                  ),
                  Divider(height: 30),

                  // Chọn sản phẩm
                  DropdownButtonFormField<Product>(
                    value: _selectedProduct,
                    decoration: InputDecoration(
                      labelText: "Chọn sản phẩm",
                      prefixIcon: Icon(Icons.search),
                      helperText: _selectedProduct != null ? "Tồn kho hiện tại: ${_selectedProduct!.stockQuantity}" : null,
                    ),
                    isExpanded: true,
                    items: _availableProducts.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text("${p.name}", overflow: TextOverflow.ellipsis),
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
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Ghi chú
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Ghi chú / Lý do",
                      prefixIcon: Icon(Icons.edit_note),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Nút Submit
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                      ),
                      onPressed: isLoading ? null : _submitTransaction,
                      child: isLoading
                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                          "XÁC NHẬN ${isTypeInbound ? 'NHẬP' : 'XUẤT'}",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
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
    final color = type == 'inbound' ? Colors.green : Colors.red;

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
            Icon(icon, color: isSelected ? color : Colors.grey),
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