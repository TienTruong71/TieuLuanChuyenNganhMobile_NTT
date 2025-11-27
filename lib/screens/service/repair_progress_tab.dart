// lib/screens/service/repair_progress_tab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';

class RepairProgressTab extends StatefulWidget {
  @override
  _RepairProgressTabState createState() => _RepairProgressTabState();
}

class _RepairProgressTabState extends State<RepairProgressTab> {
  List<RepairProgress> progressList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await MockData().getRepairProgress();
    setState(() { progressList = data; });
  }

  void _showUpdateDialog(RepairProgress item) {
    final _notesCtrl = TextEditingController(text: item.notes);
    String _status = item.status;
    DateTime? _selectedDate = item.estimatedCompletion;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text("Cập nhật tiến độ"),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Dịch vụ: ${item.bookingServiceName}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800])),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(labelText: "Trạng thái", border: OutlineInputBorder()),
                items: [
                  {'val': 'in_progress', 'label': 'Đang sửa'},
                  {'val': 'waiting_parts', 'label': 'Chờ linh kiện'},
                  {'val': 'testing', 'label': 'Đang kiểm tra'},
                  {'val': 'completed', 'label': '✅ Hoàn thành'},
                ].map((e) => DropdownMenuItem(value: e['val'], child: Text(e['label']!))).toList(),
                onChanged: (val) => setStateDialog(() => _status = val!),
              ),
              SizedBox(height: 10),
              TextField(controller: _notesCtrl, decoration: InputDecoration(labelText: "Ghi chú", border: OutlineInputBorder()), maxLines: 3),
              SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2025));
                  if (date != null) {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time != null) setStateDialog(() { _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute); });
                  }
                },
                child: InputDecorator(decoration: InputDecoration(labelText: "Dự kiến xong", border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)), child: Text(_selectedDate == null ? "Chưa thiết lập" : DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate!))),
              )
            ]),
          ),
          actions: [
            TextButton(onPressed: () async {
              final confirm = await showDialog<bool>(context: context, builder: (dCtx) => AlertDialog(title: Text("Xóa tiến độ?"), actions: [TextButton(onPressed: ()=>Navigator.pop(dCtx,true), child: Text("Xóa"))]));
              if (confirm == true) { Navigator.pop(ctx); await MockData().deleteRepairProgress(item.id); _loadData(); }
            }, child: Text("XÓA", style: TextStyle(color: Colors.red))),

            ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);

                  // Logic hỏi trả khoang
                  bool freeBay = false;
                  if (_status == 'completed') {
                    final result = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (dCtx) => AlertDialog(
                          title: Text("Đã xong việc!"),
                          content: Text("Khách hàng có lấy xe và rời đi ngay không?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx, false), // KHÔNG
                              child: Text("Không, xe vẫn để ở khoang", style: TextStyle(color: Colors.orange)),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(dCtx, true), // CÓ
                              child: Text("Có, giải phóng khoang"),
                            ),
                          ],
                        )
                    );
                    freeBay = result ?? false;
                  }

                  await MockData().updateRepairProgressFull(item.id, status: _status, notes: _notesCtrl.text, estimatedCompletion: _selectedDate, freeBay: freeBay);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cập nhật thành công!")));
                },
                child: Text("Lưu")
            )
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch(status) { case 'completed': return Colors.green; case 'waiting_parts': return Colors.orange; case 'testing': return Colors.purple; default: return Colors.blue; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: progressList.length,
          itemBuilder: (context, index) {
            final item = progressList[index];
            final isMyTask = item.staffId == MockData().currentUser?.id;
            return Card(
              elevation: 3, margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: isMyTask ? BorderSide(color: Colors.blue, width: 1.5) : BorderSide.none),
              child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.bookingServiceName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[900])), SizedBox(height: 4), Text("Khách: ${item.bookingUserName}", style: TextStyle(fontSize: 14))])),
                  Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: _getStatusColor(item.status).withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: _getStatusColor(item.status))), child: Text(item.status.toUpperCase(), style: TextStyle(color: _getStatusColor(item.status), fontSize: 11, fontWeight: FontWeight.bold)))
                ]),
                Divider(height: 24),
                Row(children: [Icon(Icons.person, size: 16, color: Colors.grey), SizedBox(width: 8), Text("KTV: ${item.staffName}")]),
                SizedBox(height: 8),
                Row(children: [Icon(Icons.timer, size: 16, color: Colors.grey), SizedBox(width: 8), Text(item.estimatedCompletion != null ? "Dự kiến: ${DateFormat('dd/MM/yyyy HH:mm').format(item.estimatedCompletion!)}" : "Chưa có lịch hoàn thành", style: TextStyle(color: item.estimatedCompletion != null ? Colors.black87 : Colors.grey))]),
                if (item.notes.isNotEmpty) Container(margin: EdgeInsets.only(top: 12), padding: EdgeInsets.all(10), width: double.infinity, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)), child: Text(item.notes, style: TextStyle(fontStyle: FontStyle.italic))),
                if (isMyTask) Padding(padding: const EdgeInsets.only(top: 16.0), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _showUpdateDialog(item), icon: Icon(Icons.edit, size: 16), label: Text("Cập nhật / Xóa"), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50], foregroundColor: Colors.blue[800], elevation: 0))))
              ])),
            );
          },
        ),
      ),
    );
  }
}