// lib/screens/inventory/inventory_list_tab.dart
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';

class InventoryListTab extends StatefulWidget {
  @override
  _InventoryListTabState createState() => _InventoryListTabState();
}

class _InventoryListTabState extends State<InventoryListTab> {
  List<Inventory> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await MockData().getInventoryList();
    setState(() {
      items = data;
      isLoading = false;
    });
  }

  void _showQuickEdit(Inventory item) {
    final _qtyCtrl =
    TextEditingController(text: item.quantityAvailable.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Điều chỉnh tồn kho"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.product?.name ?? "Sản phẩm",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            TextField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Số lượng thực tế")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Hủy")),
          ElevatedButton(
              onPressed: () async {
                int? qty = int.tryParse(_qtyCtrl.text);
                if (qty == null || qty < 0) return;
                Navigator.pop(ctx);
                await MockData().updateInventory(item.id, qty);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã cập nhật tồn kho!")));
              },
              child: Text("Lưu"))
        ],
      ),
    );
  }

  void _showAddProductDialog() async {
    final productsNotInInv = await MockData().getProductsNotInInventory();
    showModalBottomSheet(
        context: context,
        builder: (ctx) => Container(
          padding: EdgeInsets.all(24),
          height: 400,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Thêm sản phẩm mới vào kho",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Chọn sản phẩm từ danh mục chung để bắt đầu quản lý",
                    style: TextStyle(color: Colors.grey)),
                SizedBox(height: 16),
                Expanded(
                  child: productsNotInInv.isEmpty
                      ? Center(
                      child: Text("Tất cả sản phẩm đã có trong kho"))
                      : ListView.separated(
                    itemCount: productsNotInInv.length,
                    separatorBuilder: (c, i) => Divider(),
                    itemBuilder: (c, i) {
                      final p = productsNotInInv[i];
                      return ListTile(
                        leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius:
                                BorderRadius.circular(8)),
                            child: Icon(Icons.new_releases,
                                color: Colors.orange)),
                        title: Text(p.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Text("${p.price} đ"),
                        trailing: Icon(Icons.add_circle_outline,
                            color: Colors.orange),
                        onTap: () async {
                          Navigator.pop(ctx);
                          await MockData().addInventory(p.id, 0);
                          _loadData();
                        },
                      );
                    },
                  ),
                )
              ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange[800],
          onPressed: _showAddProductDialog,
          child: Icon(Icons.add, color: Colors.white)),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (c, i) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final product = item.product;
          final isLowStock = item.quantityAvailable <= 5;

          return Card(
            child: InkWell(
              onLongPress: () => _showQuickEdit(item),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // 1. Icon (Leading)
                    Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.inventory_2,
                            color: Colors.orange[300], size: 28)),

                    SizedBox(width: 16),

                    // 2. Nội dung chính (Title & Subtitle) - Dùng Expanded để tránh lỗi layout ngang
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product?.name ?? "Unknown",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text("Mã: ${product?.id}",
                              style:
                              TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),

                    SizedBox(width: 16),

                    // 3. Số lượng (Trailing) - Thiết kế lại bằng Column nằm trong Container tự do
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: isLowStock ? Colors.red[50] : Colors.green[50],
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Text("${item.quantityAvailable}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isLowStock
                                      ? Colors.red
                                      : Colors.green[800])),
                          Text("Tồn",
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}