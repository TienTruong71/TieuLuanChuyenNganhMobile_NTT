import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/repository.dart';
import '../../models/index.dart';

class StockHistoryTab extends StatefulWidget {
  @override
  _StockHistoryTabState createState() => _StockHistoryTabState();
}

class _StockHistoryTabState extends State<StockHistoryTab> {
  List<StockTransaction> history = [];
  bool isLoading = true;
  final Color primaryColor = Color(0xFFE65100); // Đồng bộ với màu Kho hàng

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await Repository().getStockTransactions();
      if (mounted) {
        setState(() {
          history = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải lịch sử: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator(color: primaryColor));

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history_toggle_off_rounded, size: 80, color: Colors.grey[300]),
            ),
            SizedBox(height: 24),
            Text("Chưa có giao dịch nào",
                style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)
            ),
            Text("Các biến động kho sẽ xuất hiện tại đây",
                style: TextStyle(color: Colors.grey[500])
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async => _loadData(),
      child: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: history.length,
        separatorBuilder: (c, i) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = history[index];
          final isInbound = item.type == 'inbound';
          final statusColor = isInbound ? Color(0xFF10B981) : Color(0xFFEF4444);

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Thanh màu chỉ thị trạng thái
                    Container(
                      width: 6,
                      color: statusColor,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Icon tròn
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isInbound ? Icons.add_circle_outline : Icons.remove_circle_outline,
                                color: statusColor,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            // Thông tin chính
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800]),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Text(
                                        DateFormat('HH:mm - dd/MM/yyyy').format(item.createdAt),
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  if (item.note.isNotEmpty)
                                    Container(
                                      margin: EdgeInsets.only(top: 8),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.note,
                                        style: TextStyle(fontSize: 12, color: Colors.grey[700], fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.grey[200],
                                        child: Icon(Icons.person, size: 12, color: Colors.grey[600]),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        item.createdBy,
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            // Số lượng
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${isInbound ? '+' : '-'}${item.quantity}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: statusColor,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isInbound ? "NHẬP" : "XUẤT",
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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