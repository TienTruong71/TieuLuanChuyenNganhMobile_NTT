import 'package:flutter/material.dart';
import '../../data/repository.dart';
import '../../models/index.dart';

class InventoryListTab extends StatefulWidget {
  @override
  _InventoryListTabState createState() => _InventoryListTabState();
}

class _InventoryListTabState extends State<InventoryListTab> {
  List<Inventory> items = [];
  bool isLoading = true;

  List<Category> _availableCategories = [];
  Category? _selectedCategory;

  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  final Color primaryColor = Color(0xFFE65100);

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCategories();
  }

  void _clearControllers() {
    _nameCtrl.clear();
    _priceCtrl.clear();
    _qtyCtrl.clear();
    _imageCtrl.clear();
    _selectedCategory = null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  void _loadCategories() async {
    try {
      final data = await Repository().getCategories();
      if (mounted) {
        setState(() {
          _availableCategories = data;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải danh mục: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải dữ liệu: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
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

  void _showQuickEdit(Inventory item) {
    final _qtyCtrlEdit = TextEditingController(text: item.quantityAvailable.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Điều chỉnh tồn kho", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.product?.name ?? "Sản phẩm",
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _qtyCtrlEdit,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("Số lượng thực tế"),
            ),
          ],
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              int? qty = int.tryParse(_qtyCtrlEdit.text);

              // --- VALIDATION SỐ LƯỢNG TỒN ---
              if (qty == null || qty < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Số lượng không hợp lệ (phải >= 0)"), backgroundColor: Colors.orange)
                );
                return;
              }
              // -------------------------------

              Navigator.pop(ctx);

              try {
                await Repository().updateInventory(item.id, qty);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Đã cập nhật tồn kho!"), backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text("Lưu"),
          )
        ],
      ),
    );
  }

  void _showAddProductDialog() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Center(child: CircularProgressIndicator())
    );

    try {
      final productsNotInInv = await Repository().getProductsNotInInventory();
      Navigator.pop(context);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) => Container(
            padding: EdgeInsets.all(24),
            child: Column(
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
                Text("Thêm từ Danh mục", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Chọn sản phẩm có sẵn để quản lý kho", style: TextStyle(color: Colors.grey[600])),
                SizedBox(height: 24),
                Expanded(
                  child: productsNotInInv.isEmpty
                      ? Center(child: Text("Tất cả sản phẩm đã có trong kho"))
                      : ListView.separated(
                    controller: scrollController,
                    itemCount: productsNotInInv.length,
                    separatorBuilder: (c, i) => SizedBox(height: 12),
                    itemBuilder: (c, i) {
                      final p = productsNotInInv[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.inventory_2_outlined, color: primaryColor),
                          ),
                          title: Text(p.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${p.price} đ", style: TextStyle(color: Colors.grey[600])),
                          trailing: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                          onTap: () async {
                            Navigator.pop(ctx);
                            try {
                              await Repository().addInventory(p.id, 0);
                              _loadData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Đã thêm ${p.name}"), backgroundColor: Colors.green),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể tải danh sách sản phẩm"), backgroundColor: Colors.red),
      );
    }
  }

  void _showAddByNameDialog() {
    _clearControllers();

    showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              scrollable: true,
              title: Text("Tạo SP Mới", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _nameCtrl, decoration: _inputDecoration("Tên Sản phẩm*")),
                  SizedBox(height: 16),
                  DropdownButtonFormField<Category>(
                    value: _selectedCategory,
                    decoration: _inputDecoration("Danh mục*"),
                    items: _availableCategories.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.name, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        _selectedCategory = val;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: _inputDecoration("Giá bán"))),
                      SizedBox(width: 16),
                      Expanded(child: TextField(controller: _qtyCtrl, keyboardType: TextInputType.number, decoration: _inputDecoration("SL Nhập*"))),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(controller: _imageCtrl, decoration: _inputDecoration("URL Hình ảnh")),
                ],
              ),
              actionsPadding: EdgeInsets.all(16),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Hủy", style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () async {
                    int? qty = int.tryParse(_qtyCtrl.text);
                    int? price = int.tryParse(_priceCtrl.text) ?? 0;

                    // --- VALIDATION GIÁ VÀ SỐ LƯỢNG ---
                    if (_nameCtrl.text.isEmpty || _selectedCategory == null || qty == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vui lòng nhập thông tin bắt buộc")));
                      return;
                    }

                    if (price < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Giá bán không được âm"), backgroundColor: Colors.orange));
                      return;
                    }

                    if (qty < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Số lượng nhập không được âm"), backgroundColor: Colors.orange));
                      return;
                    }
                    // ----------------------------------

                    Navigator.pop(ctx);

                    try {
                      await Repository().addInventoryByName(
                          productName: _nameCtrl.text,
                          categoryName: _selectedCategory!.name,
                          price: price,
                          images: _imageCtrl.text.isNotEmpty ? [_imageCtrl.text] : [],
                          quantityAvailable: qty
                      );
                      _loadData();
                      _clearControllers();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Đã tạo mới thành công"), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text("Tạo Mới"),
                )
              ],
            );
          },
        )
    );
  }

  void _showActionMenu() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => Container(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              SizedBox(height: 24),
              ListTile(
                leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.add_box_outlined, color: Colors.blue)
                ),
                title: Text("Thêm từ Danh mục", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Chọn sản phẩm đã có trong hệ thống"),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddProductDialog();
                },
              ),
              SizedBox(height: 12),
              ListTile(
                leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.drive_file_rename_outline, color: Colors.orange)
                ),
                title: Text("Tạo Sản phẩm mới", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Tạo mới hoàn toàn theo tên"),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddByNameDialog();
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator(color: primaryColor));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Nhập Kho", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _showActionMenu,
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () async => _loadData(),
        child: items.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text("Kho hàng trống", style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Bắt đầu bằng việc thêm sản phẩm mới", style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        )
            : ListView.separated(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: items.length,
          separatorBuilder: (c, i) => SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = items[index];
            final product = item.product;
            final isLowStock = item.quantityAvailable <= 5;

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
                  onLongPress: () => _showQuickEdit(item),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Icon(Icons.inventory_2, color: primaryColor.withOpacity(0.7), size: 30),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product?.name ?? "Unknown Product",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.3),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.qr_code, size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "SKU: ${product?.id.substring(0, 8).toUpperCase() ?? 'N/A'}",
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isLowStock ? Colors.red.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: isLowStock ? Colors.red.shade100 : Colors.green.shade100
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "${item.quantityAvailable}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: isLowStock ? Colors.red[700] : Colors.green[700],
                                ),
                              ),
                              Text(
                                "Tồn kho",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isLowStock ? Colors.red[400] : Colors.green[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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