// lib/screens/sale/support_tab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';

class SupportTab extends StatefulWidget {
  @override
  _SupportTabState createState() => _SupportTabState();
}

class _SupportTabState extends State<SupportTab> {
  List<SupportRequest> requests = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await MockData().getSupportRequests();
    setState(() { requests = data; });
  }

  void _showReplyDialog(SupportRequest item) {
    final _replyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Trả lời yêu cầu"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Khách: ${item.message}", style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic)),
            SizedBox(height: 10),
            TextField(
              controller: _replyCtrl,
              decoration: InputDecoration(labelText: "Nội dung phản hồi", border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (_replyCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              await MockData().replySupport(item.id, _replyCtrl.text);
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã gửi phản hồi!")));
            },
            child: Text("Gửi & Đóng Ticket"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final item = requests[index];
        final isResolved = item.status == 'resolved';

        return Card(
          color: isResolved ? Colors.grey[100] : Colors.white,
          child: ListTile(
            title: Text(item.userName, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.userEmail, style: TextStyle(fontSize: 12, color: Colors.grey)),
                SizedBox(height: 4),
                Text(item.message, style: TextStyle(color: Colors.black87)),
                if (isResolved)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                      child: Text("Staff Reply: ${item.reply}", style: TextStyle(fontSize: 12, color: Colors.green[800])),
                    ),
                  )
              ],
            ),
            trailing: isResolved
                ? Icon(Icons.check_circle, color: Colors.green)
                : IconButton(
              icon: Icon(Icons.reply, color: Colors.blue),
              onPressed: () => _showReplyDialog(item),
            ),
          ),
        );
      },
    );
  }
}