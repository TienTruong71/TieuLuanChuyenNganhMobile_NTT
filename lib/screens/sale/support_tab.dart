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
  void initState() { super.initState(); _loadData(); }
  void _loadData() async { final data = await MockData().getSupportRequests(); setState(() { requests = data; }); }

  void _showReplyDialog(SupportRequest item) {
    final _replyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Phản hồi khách hàng"),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              SizedBox(height: 4),
              Text(item.message, style: TextStyle(color: Colors.black87)),
            ]),
          ),
          SizedBox(height: 16),
          TextField(controller: _replyCtrl, decoration: InputDecoration(labelText: "Nội dung trả lời", hintText: "Nhập câu trả lời..."), maxLines: 3),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Hủy")),
          ElevatedButton(onPressed: () async {
            if (_replyCtrl.text.isEmpty) return;
            Navigator.pop(ctx);
            await MockData().replySupport(item.id, _replyCtrl.text);
            _loadData();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã gửi phản hồi!")));
          }, child: Text("Gửi đi"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (c, i) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = requests[index];
        final isResolved = item.status == 'resolved';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  CircleAvatar(radius: 12, backgroundColor: Colors.blue[50], child: Text(item.userName[0], style: TextStyle(fontSize: 12, color: Colors.blue))),
                  SizedBox(width: 8),
                  Text(item.userName, style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
                Icon(isResolved ? Icons.check_circle : Icons.pending, size: 18, color: isResolved ? Colors.green : Colors.orange),
              ]),
              SizedBox(height: 12),
              Text(item.message, style: TextStyle(fontSize: 15)),
              SizedBox(height: 8),
              Text(DateFormat('dd/MM HH:mm').format(item.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey)),
              if (isResolved) ...[
                Divider(height: 24),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8), topRight: Radius.circular(8))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Staff Reply:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green[800])),
                    SizedBox(height: 4),
                    Text(item.reply, style: TextStyle(color: Colors.green[900])),
                  ]),
                )
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _showReplyDialog(item), icon: Icon(Icons.reply, size: 18), label: Text("Trả lời"))),
                )
            ]),
          ),
        );
      },
    );
  }
}