import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/repository.dart'; // Sử dụng Repository (API thật)
import '../../models/index.dart';    // Sử dụng index models

class StockHistoryTab extends StatefulWidget {
  @override
  _StockHistoryTabState createState() => _StockHistoryTabState();
}

class _StockHistoryTabState extends State<StockHistoryTab> {
  List<StockTransaction> history = [];
  bool isLoading = true;

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
    if (isLoading) return Center(child: CircularProgressIndicator());

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 60, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text("Chưa có giao dịch nào", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          final isInbound = item.type == 'inbound';

          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: isInbound ? Colors.green[50] : Colors.red[50],
                child: Icon(
                  isInbound ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isInbound ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                item.productName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (item.note.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          item.note,
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, size: 12, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(item.createdBy, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ],
                    )
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isInbound ? '+' : '-'}${item.quantity}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isInbound ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    isInbound ? "Nhập" : "Xuất",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}