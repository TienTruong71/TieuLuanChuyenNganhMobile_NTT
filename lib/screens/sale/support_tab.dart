import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/repository.dart';
import '../../../../models/support_model.dart';

class SupportTab extends StatefulWidget {
  @override
  _SupportTabState createState() => _SupportTabState();
}

class _SupportTabState extends State<SupportTab> {
  List<SupportRequest> requests = [];
  bool isLoading = true;
  final Color primaryColor = Color(0xFF00897B); // Teal color for Support

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final data = await Repository().getSupportRequests();
      if (mounted) {
        setState(() {
          requests = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showReplyDialog(SupportRequest item) {
    final _replyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.reply_rounded, color: primaryColor),
            SizedBox(width: 8),
            Text("Phản hồi khách hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Câu hỏi từ ${item.username}:", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueGrey[100]!),
                ),
                child: Text(
                  item.message,
                  style: TextStyle(color: Colors.blueGrey[900], fontStyle: FontStyle.italic),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _replyCtrl,
                decoration: InputDecoration(
                  labelText: "Nội dung trả lời",
                  hintText: "Nhập câu trả lời chi tiết...",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (_replyCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đang gửi phản hồi...")));

              try {
                await Repository().replySupport(item.id, _replyCtrl.text);
                _loadData();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã gửi phản hồi thành công!"), backgroundColor: Colors.green));
              } catch (e) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: Icon(Icons.send_rounded, size: 18, color: Colors.white),
            label: Text("Gửi đi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    return status == 'resolved' ? Colors.green : Colors.orange;
  }

  String _getStatusText(String status) {
    return status == 'resolved' ? 'Đã xử lý' : 'Chờ xử lý';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator(color: primaryColor));

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.support_agent_rounded, size: 60, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text("Không có yêu cầu hỗ trợ nào", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async => _loadData(),
      child: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (c, i) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = requests[index];
          final isResolved = item.status == 'resolved';
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
                // Header: User Info & Status
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue[50],
                            child: Text(
                              item.username.isNotEmpty ? item.username[0].toUpperCase() : "?",
                              style: TextStyle(fontSize: 16, color: Colors.blue[800], fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.username, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              SizedBox(height: 2),
                              Text(
                                DateFormat('HH:mm - dd/MM/yyyy').format(item.createdAt),
                                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(isResolved ? Icons.check_circle : Icons.access_time_filled, size: 14, color: statusColor),
                            SizedBox(width: 4),
                            Text(
                              _getStatusText(item.status),
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: Colors.grey[200]),

                // Body: Message
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.message,
                        style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                      ),
                    ],
                  ),
                ),

                // Footer: Reply Section
                if (isResolved)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.subdirectory_arrow_right, size: 18, color: Colors.green[700]),
                            SizedBox(width: 8),
                            Text("Phản hồi từ nhân viên:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[800])),
                          ],
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 26.0),
                          child: Text(
                            item.reply,
                            style: TextStyle(color: Colors.green[900], fontSize: 14, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showReplyDialog(item),
                        icon: Icon(Icons.reply, size: 18),
                        label: Text("Gửi trả lời"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}