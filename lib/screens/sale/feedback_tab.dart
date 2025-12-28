import 'package:flutter/material.dart';
import '../../../../data/repository.dart';
import '../../../../models/feedback_model.dart';

class FeedbackTab extends StatefulWidget {
  @override
  _FeedbackTabState createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  List<FeedbackModel> feedbacks = [];
  bool isLoading = true;
  final Color primaryColor = Color(0xFF00897B);

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

  String _getTargetName(FeedbackModel item) {
    if (item.productName.isNotEmpty) return item.productName;
    if (item.serviceName.isNotEmpty) return item.serviceName;
    return "Sản phẩm chung";
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'approved': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Chờ duyệt';
      case 'approved': return 'Đã duyệt';
      default: return 'Đã xóa';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator(color: primaryColor));

    if (feedbacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text("Chưa có phản hồi nào", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async => _loadData(),
      child: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: feedbacks.length,
        separatorBuilder: (c, i) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = feedbacks[index];
          final isPending = item.status == 'pending';
          final statusColor = _getStatusColor(item.status);

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blueGrey[50],
                        radius: 20,
                        child: Text(
                          item.username.isNotEmpty ? item.username[0].toUpperCase() : '?',
                          style: TextStyle(color: Colors.blueGrey[700], fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.username,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _getStatusText(item.status),
                                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (i) => Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: i < item.rating ? Colors.amber : Colors.grey[300],
                              )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: Colors.grey[200]),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _getTargetName(item),
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800], fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.format_quote_rounded, color: Colors.grey[400], size: 20),
                            Text(
                              item.comment,
                              style: TextStyle(color: Colors.grey[800], height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (isPending) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleDelete(item.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red.withOpacity(0.5)),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text("Từ chối"),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleApprove(item.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: Text("Duyệt đăng"),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}