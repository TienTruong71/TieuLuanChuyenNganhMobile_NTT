import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/repository.dart';
import '../../../../models/support_model.dart';
import 'package:intl/intl.dart';

class SupportChatScreen extends StatefulWidget {
  final SupportRequest request;

  const SupportChatScreen({Key? key, required this.request}) : super(key: key);

  @override
  _SupportChatScreenState createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late SupportRequest _currentRequest;
  Timer? _timer;
  bool _isSending = false;
  final Color primaryColor = Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.request;
    _startPolling();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await _refreshData();
    });
  }

  Future<void> _refreshData() async {
    try {
      final updated = await Repository().getSupportRequestById(_currentRequest.id);
      if (mounted) {
        setState(() {
          _currentRequest = updated;
        });
        if (_scrollCtrl.hasClients &&
            _scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
           _scrollToBottom();
        }
      }
    } catch (e) {
      print("Error refreshing chat: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await Repository().replySupport(_currentRequest.id, text);
      _msgCtrl.clear();
      await _refreshData();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không gửi được: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _resolveRequest() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Hoàn tất hỗ trợ"),
        content: Text("Bạn có chắc chắn muốn đánh dấu yêu cầu này là đã xử lý xong không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Hủy")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text("Xác nhận", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Repository().resolveSupport(_currentRequest.id);
        await _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã đóng yêu cầu hỗ trợ."), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isResolved = _currentRequest.status == 'resolved';

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00695C), Color(0xFF00897B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    _currentRequest.username.isNotEmpty ? _currentRequest.username[0].toUpperCase() : '?',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                  radius: 18,
                ),
                if (!isResolved)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  )
              ],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentRequest.username,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isResolved ? 'Đã hoàn tất' : 'Đang hỗ trợ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!isResolved)
            IconButton(
              icon: Icon(Icons.check_circle_outline, color: Colors.white),
              tooltip: 'Đánh dấu hoàn tất',
              onPressed: _resolveRequest,
            ),
        ],
      ),
      backgroundColor: Color(0xFFF5F7F9),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _currentRequest.messages.isEmpty ? 1 : _currentRequest.messages.length,
              itemBuilder: (context, index) {
                if (_currentRequest.messages.isEmpty) {
                  return _buildMessageBubble(
                    text: _currentRequest.message,
                    time: _currentRequest.createdAt,
                    isMe: false,
                    senderName: _currentRequest.username,
                  );
                }
                
                final msg = _currentRequest.messages[index];
                final isMe = msg.senderRole == 'staff' || msg.senderRole == 'admin';
                
                return _buildMessageBubble(
                  text: msg.text,
                  time: msg.timestamp,
                  isMe: isMe,
                  senderName: isMe ? "Tôi" : msg.senderName,
                );
              },
            ),
          ),
          if (isResolved)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Center(
                child: Text(
                  "Phiên hỗ trợ này đã kết thúc.",
                  style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required DateTime time,
    required bool isMe,
    required String senderName,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: isMe 
              ? LinearGradient(colors: [Color(0xFF00897B), Color(0xFF4DB6AC)]) 
              : null,
          color: isMe ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
            bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            )
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  senderName,
                  style: TextStyle(
                    color: Colors.blueGrey[400],
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat('HH:mm').format(time),
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.grey[400],
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[300]!)
                ),
                child: TextField(
                  controller: _msgCtrl,
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
            ),
            SizedBox(width: 12),
            InkWell(
              onTap: _isSending ? null : _sendMessage,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF00897B), Color(0xFF26A69A)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0xFF00897B).withOpacity(0.4), blurRadius: 8, offset: Offset(0, 4))
                  ]
                ),
                child: _isSending
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
