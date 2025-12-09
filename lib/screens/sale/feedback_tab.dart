import 'package:flutter/material.dart';
import '../../../../data/repository.dart';
import '../../../../models/feedback_model.dart'; // Import đúng model

class FeedbackTab extends StatefulWidget {
  @override
  _FeedbackTabState createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  // SỬA: Dùng FeedbackModel thay vì FeedbackItem
  List<FeedbackModel> feedbacks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final data = await Repository().getFeedbacks();
      if (mounted) {
        setState(() {
          feedbacks = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _handleDelete(String id) async {
    try {
      await Repository().deleteFeedback(id);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã xóa phản hồi"), backgroundColor: Colors.orange));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi xóa: ${e.toString()}"), backgroundColor: Colors.red));
    }
  }

  void _handleApprove(String id) async {
    try {
      await Repository().approveFeedback(id);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã duyệt phản hồi"), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi duyệt: ${e.toString()}"), backgroundColor: Colors.red));
    }
  }

  // Helper để lấy tên hiển thị (Sản phẩm hoặc Dịch vụ)
  String _getTargetName(FeedbackModel item) {
    if (item.productName.isNotEmpty) return item.productName;
    if (item.serviceName.isNotEmpty) return item.serviceName;
    return "Sản phẩm chung";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    if (feedbacks.isEmpty) {
      return Center(child: Text("Chưa có phản hồi nào", style: TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.separated(
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

                  // SỬA: Logic hiển thị tên sản phẩm/dịch vụ
                  Text(_getTargetName(item), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

                  SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.account_circle, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    // SỬA: item.username (chữ thường)
                    Text(item.username, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
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
                      TextButton(
                          onPressed: () => _handleDelete(item.id),
                          child: Text("Xóa", style: TextStyle(color: Colors.red))
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                        onPressed: () => _handleApprove(item.id),
                        child: Text("Duyệt đăng", style: TextStyle(fontSize: 13)),
                      ),
                    ])
                  ]
                ],
              ),
            ),
          );
        },
      ),
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