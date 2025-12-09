import 'package:flutter/material.dart';
import '../../data/repository.dart'; // Đổi từ mock_data sang repository
import '../../models/index.dart'; // Sử dụng index models

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

  // Tải dữ liệu từ API
  void _loadData() async {
    try {
      final data = await Repository().getInventoryList();
      if (mounted) {
        setState(() {
          items = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        // Hiển thị lỗi nếu tải thất bại
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải dữ liệu: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Dialog cập nhật số lượng (Kiểm kê)
  void _showQuickEdit(Inventory item) {
    final _qtyCtrl = TextEditingController(text: item.quantityAvailable.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Điều chỉnh tồn kho"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.product?.name ?? "Sản phẩm", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Số lượng thực tế"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              int? qty = int.tryParse(_qtyCtrl.text);
              if (qty == null || qty < 0) return;

              Navigator.pop(ctx);

              // Gọi API update
              try {
                await Repository().updateInventory(item.id, qty);
                _loadData(); // Tải lại danh sách
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Đã cập nhật tồn kho!"), backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red),
                );
              }
            },
            child: Text("Lưu"),
          )
        ],
      ),
    );
  }

  // Dialog thêm sản phẩm mới vào kho
  void _showAddProductDialog() async {
    // Hiển thị loading khi đang tải danh sách sản phẩm chưa có trong kho
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Center(child: CircularProgressIndicator())
    );

    try {
      final productsNotInInv = await Repository().getProductsNotInInventory();
      Navigator.pop(context); // Tắt loading

      showModalBottomSheet(
        context: context,
        builder: (ctx) => Container(
          padding: EdgeInsets.all(24),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Thêm sản phẩm mới vào kho", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("Chọn sản phẩm từ danh mục chung để bắt đầu quản lý", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 16),
              Expanded(
                child: productsNotInInv.isEmpty
                    ? Center(child: Text("Tất cả sản phẩm đã có trong kho"))
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.new_releases, color: Colors.orange),
                      ),
                      title: Text(p.name, style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text("${p.price} đ"),
                      trailing: Icon(Icons.add_circle_outline, color: Colors.orange),
                      onTap: () async {
                        Navigator.pop(ctx);
                        try {
                          await Repository().addInventory(p.id, 0); // Thêm với SL 0
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Đã thêm ${p.name} vào kho"), backgroundColor: Colors.green),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red),
                          );
                        }
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Tắt loading nếu lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể tải danh sách sản phẩm: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange[800],
        onPressed: _showAddProductDialog,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView.separated(
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.inventory_2, color: Colors.orange[300], size: 28),
                      ),

                      SizedBox(width: 16),

                      // 2. Nội dung chính (Title & Subtitle)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product?.name ?? "Unknown",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text("Mã: ${product?.id}", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),

                      SizedBox(width: 16),

                      // 3. Số lượng (Trailing)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isLowStock ? Colors.red[50] : Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "${item.quantityAvailable}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isLowStock ? Colors.red : Colors.green[800],
                              ),
                            ),
                            Text("Tồn", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
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
      ),
    );
  }
}