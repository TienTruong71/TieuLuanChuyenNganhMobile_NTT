import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';

class FeedbackTab extends StatefulWidget {
  @override
  _FeedbackTabState createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  List<FeedbackItem> feedbacks = [];

  @override
  void initState() { super.initState(); _loadData(); }
  void _loadData() async { final data = await MockData().getFeedbacks(); setState(() { feedbacks = data; }); }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: feedbacks.length,
      separatorBuilder: (c, i) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = feedbacks[index];
        final isPending = item.status == 'pending';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(8)),
                    child: Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, size: 16, color: i < item.rating ? Colors.amber : Colors.grey[300]))),
                  ),
                  _buildStatusChip(item.status),
                ]),
                SizedBox(height: 12),
                Text(item.productName ?? item.serviceName ?? "Sản phẩm chung", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.account_circle, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(item.userName, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                ]),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                  child: Text("\"${item.comment}\"", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[800])),
                ),
                if (isPending) ...[
                  SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(onPressed: () async { await MockData().deleteFeedback(item.id); _loadData(); }, child: Text("Xóa", style: TextStyle(color: Colors.red))),
                    SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                      onPressed: () async { await MockData().approveFeedback(item.id); _loadData(); },
                      child: Text("Duyệt đăng", style: TextStyle(fontSize: 13)),
                    ),
                  ])
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == 'pending' ? Colors.orange : (status == 'approved' ? Colors.green : Colors.red);
    String text = status == 'pending' ? 'Chờ duyệt' : (status == 'approved' ? 'Đã duyệt' : 'Đã xóa');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(border: Border.all(color: color.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}