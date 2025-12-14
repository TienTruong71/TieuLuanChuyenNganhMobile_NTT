import 'package:flutter/material.dart';
import '../../data/repository.dart';
import '../../models/index.dart';

class StockTransactionTab extends StatefulWidget {
  @override
  _StockTransactionTabState createState() => _StockTransactionTabState();
}

class _StockTransactionTabState extends State<StockTransactionTab> {
  String _transactionType = 'inbound';
  Product? _selectedProduct;
  final _qtyCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  List<Product> _availableProducts = [];
  bool isLoading = false;

  final Color inboundColor = Color(0xFF00C853);
  final Color outboundColor = Color(0xFFFF3D00);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    try {
      final list = await Repository().getProductsInInventory();
      if (mounted) {
        setState(() {
          _availableProducts = list;
        });
      }
    } catch (e) {
      print("Lỗi tải sản phẩm: $e");
    }
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

    setState(() => isLoading = true);

    try {
      await Repository().createStockTransaction(
          _selectedProduct!.id,
          qty,
          _transactionType,
          _noteCtrl.text
      );

      setState(() {
        _qtyCtrl.clear();
        _noteCtrl.clear();
        _selectedProduct = null;
        isLoading = false;
      });

      _loadProducts();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${_transactionType == 'inbound' ? 'Nhập' : 'Xuất'} kho thành công!"),
        backgroundColor: Colors.green,
      ));

    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red));
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon, Color activeColor) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
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
        borderSide: BorderSide(color: activeColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTypeInbound = _transactionType == 'inbound';
    final themeColor = isTypeInbound ? inboundColor : outboundColor;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTypeButton('inbound', 'NHẬP KHO', Icons.file_download_outlined)),
                  Expanded(child: _buildTypeButton('outbound', 'XUẤT KHO', Icons.file_upload_outlined)),
                ],
              ),
            ),
            SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(isTypeInbound ? Icons.add_business : Icons.local_shipping, color: themeColor, size: 28),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                isTypeInbound ? "Phiếu Nhập Hàng" : "Phiếu Xuất Hàng",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])
                            ),
                            Text(
                                isTypeInbound ? "Thêm hàng vào kho" : "Chuyển hàng đi hoặc bán",
                                style: TextStyle(fontSize: 12, color: Colors.grey[500])
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(height: 32, thickness: 1, color: Colors.grey[100]),

                    DropdownButtonFormField<Product>(
                      value: _selectedProduct,
                      decoration: _inputDecoration("Chọn sản phẩm", Icons.search, themeColor),
                      icon: Icon(Icons.keyboard_arrow_down_rounded),
                      isExpanded: true,
                      items: _availableProducts.map((p) => DropdownMenuItem(
                        value: p,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text("${p.name}", overflow: TextOverflow.ellipsis)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                              child: Text("Tồn: ${p.stockQuantity}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                            )
                          ],
                        ),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedProduct = val),
                    ),
                    SizedBox(height: 20),

                    TextField(
                      controller: _qtyCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: _inputDecoration("Số lượng", Icons.onetwothree, themeColor).copyWith(
                        suffixText: "Đơn vị",
                      ),
                    ),
                    SizedBox(height: 20),

                    TextField(
                      controller: _noteCtrl,
                      maxLines: 2,
                      decoration: _inputDecoration("Ghi chú / Lý do", Icons.edit_note, themeColor),
                    ),
                    SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                          shadowColor: themeColor.withOpacity(0.4),
                        ),
                        onPressed: isLoading ? null : _submitTransaction,
                        child: isLoading
                            ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "XÁC NHẬN ${isTypeInbound ? 'NHẬP' : 'XUẤT'}",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1)
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type, String label, IconData icon) {
    final isSelected = _transactionType == type;
    final color = type == 'inbound' ? inboundColor : outboundColor;

    return GestureDetector(
      onTap: () => setState(() => _transactionType = type),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: color.withOpacity(0.5), width: 1) : null
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey[500]),
            SizedBox(width: 8),
            Text(label, style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey[500],
                fontSize: 14
            )),
          ],
        ),
      ),
    );
  }
}