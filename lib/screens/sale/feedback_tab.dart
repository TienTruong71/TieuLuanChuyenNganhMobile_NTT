// lib/screens/sale/feedback_tab.dart
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
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await MockData().getFeedbacks();
    setState(() { feedbacks = data; });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: feedbacks.length,
      itemBuilder: (context, index) {
        final item = feedbacks[index];
        final isPending = item.status == 'pending';

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: List.generate(5, (i) => Icon(Icons.star, size: 18, color: i < item.rating ? Colors.amber : Colors.grey[300]))),
                    Text(item.status.toUpperCase(), style: TextStyle(
                        color: isPending ? Colors.orange : (item.status == 'approved' ? Colors.green : Colors.red),
                        fontWeight: FontWeight.bold
                    )),
                  ],
                ),
                SizedBox(height: 8),
                Text(item.productName ?? item.serviceName ?? "Sản phẩm chung", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Bởi: ${item.userName}", style: TextStyle(color: Colors.grey, fontSize: 12)),
                SizedBox(height: 8),
                Text("\"${item.comment}\"", style: TextStyle(fontStyle: FontStyle.italic)),

                if (isPending) ...[
                  Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () async {
                            await MockData().deleteFeedback(item.id);
                            _loadData();
                          },
                          child: Text("Xóa", style: TextStyle(color: Colors.red))
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async {
                            await MockData().approveFeedback(item.id);
                            _loadData();
                          },
                          child: Text("Duyệt hiển thị", style: TextStyle(color: Colors.white))
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}