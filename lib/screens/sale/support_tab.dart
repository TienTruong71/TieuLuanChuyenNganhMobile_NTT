import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/repository.dart';
import '../../../../models/support_model.dart';
import 'support_chat_screen.dart';

class SupportTab extends StatefulWidget {
  @override
  _SupportTabState createState() => _SupportTabState();
}

class _SupportTabState extends State<SupportTab> {
  List<SupportRequest> requests = [];
  bool isLoading = true;
  final Color primaryColor = Color(0xFF00897B);

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

  void _openChat(SupportRequest item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SupportChatScreen(request: item)),
    );
    _loadData(); // Refresh list on return to update snippets/times
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator(color: primaryColor));

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text("Không có tin nhắn hỗ trợ nào", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async => _loadData(),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: requests.length,
        separatorBuilder: (c, i) => Divider(height: 1),
        itemBuilder: (context, index) {
          final item = requests[index];
          // Determine last message to show in preview
          String lastMsg = item.message;
          DateTime lastTime = item.createdAt;
          bool isMeLast = false;

          if (item.messages.isNotEmpty) {
            final last = item.messages.last;
            lastMsg = last.text;
            lastTime = last.timestamp;
            isMeLast = last.senderRole == 'staff' || last.senderRole == 'admin';
          }

          final timeStr = _formatTime(lastTime);

          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () => _openChat(item),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blueGrey[50],
                  child: Text(
                    item.username.isNotEmpty ? item.username[0].toUpperCase() : "?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor),
                  ),
                ),
                if (item.status != 'resolved')
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  )
              ],
            ),
            title: Text(
              item.username,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  if (isMeLast) 
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Text("Bạn:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  Expanded(
                    child: Text(
                      lastMsg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isMeLast ? Colors.grey : Colors.black87,
                        fontWeight: isMeLast ? FontWeight.normal : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeStr, style: TextStyle(fontSize: 12, color: Colors.grey)),
                SizedBox(height: 4),
                if (item.status == 'resolved')
                  Icon(Icons.check_circle, size: 14, color: Colors.grey)
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays < 1) {
      return DateFormat('HH:mm').format(time);
    } else if (diff.inDays < 7) {
      return DateFormat('EEE').format(time); // Mon, Tue...
    } else {
      return DateFormat('dd/MM').format(time);
    }
  }
}