// lib/screens/inventory/stock_history_tab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';

class StockHistoryTab extends StatefulWidget {
  @override
  _StockHistoryTabState createState() => _StockHistoryTabState();
}

class _StockHistoryTabState extends State<StockHistoryTab> {
  List<StockTransaction> history = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await MockData().getStockTransactions();
    setState(() { history = data; });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          final isInbound = item.type == 'inbound';

          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isInbound ? Colors.green[100] : Colors.red[100],
                child: Icon(
                  isInbound ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isInbound ? Colors.green[800] : Colors.red[800],
                ),
              ),
              title: Text(item.productName, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt)),
                  if(item.note.isNotEmpty) Text("Note: ${item.note}", style: TextStyle(fontStyle: FontStyle.italic)),
                  Text("Bởi: ${item.createdBy}", style: TextStyle(fontSize: 11)),
                ],
              ),
              trailing: Text(
                "${isInbound ? '+' : '-'}${item.quantity}",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isInbound ? Colors.green : Colors.red
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}