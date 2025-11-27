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
  void initState() { super.initState(); _loadData(); }
  void _loadData() async { final data = await MockData().getRepairProgress(); setState(() { progressList = data; }); }

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
              Text("Dịch vụ: ${item.bookingServiceName}", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F62FE))),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(labelText: "Trạng thái"),
                items: [{'val': 'in_progress', 'label': 'Đang sửa'}, {'val': 'waiting_parts', 'label': 'Chờ linh kiện'}, {'val': 'testing', 'label': 'Đang kiểm tra'}, {'val': 'completed', 'label': '✅ Hoàn thành'}]
                    .map((e) => DropdownMenuItem(value: e['val'], child: Text(e['label']!))).toList(),
                onChanged: (val) => setStateDialog(() => _status = val!),
              ),
              SizedBox(height: 12),
              TextField(controller: _notesCtrl, decoration: InputDecoration(labelText: "Ghi chú kỹ thuật"), maxLines: 3),
              SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2025));
                  if (date != null) {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time != null) setStateDialog(() { _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute); });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(labelText: "Dự kiến hoàn thành", suffixIcon: Icon(Icons.calendar_month)),
                  child: Text(_selectedDate == null ? "--/--/--" : DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate!)),
                ),
              )
            ]),
          ),
          actions: [
            TextButton(onPressed: () async {
              final confirm = await showDialog<bool>(context: context, builder: (dCtx) => AlertDialog(title: Text("Xóa tiến độ?"), actions: [TextButton(onPressed: ()=>Navigator.pop(dCtx,false), child: Text("Hủy")), TextButton(onPressed: ()=>Navigator.pop(dCtx,true), child: Text("Xóa", style: TextStyle(color: Colors.red)))]));
              if (confirm == true) { Navigator.pop(ctx); await MockData().deleteRepairProgress(item.id); _loadData(); }
            }, child: Text("XÓA", style: TextStyle(color: Colors.red))),
            ElevatedButton(onPressed: () async {
              Navigator.pop(ctx);
              bool freeBay = false;
              if (_status == 'completed') {
                final result = await showDialog<bool>(context: context, barrierDismissible: false, builder: (dCtx) => AlertDialog(title: Text("Đã xong việc!"), content: Text("Khách hàng có lấy xe ngay không?"), actions: [TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text("Không, chờ giao")), ElevatedButton(onPressed: () => Navigator.pop(dCtx, true), child: Text("Có, trả khoang"))]));
                freeBay = result ?? false;
              }
              await MockData().updateRepairProgressFull(item.id, status: _status, notes: _notesCtrl.text, estimatedCompletion: _selectedDate, freeBay: freeBay);
              _loadData();
            }, child: Text("Lưu"))
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
        child: ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: progressList.length,
          separatorBuilder: (c,i) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = progressList[index];
            final isMyTask = item.staffId == MockData().currentUser?.id;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.bookingServiceName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Row(children: [Icon(Icons.person_outline, size: 14, color: Colors.grey), SizedBox(width: 4), Text(item.bookingUserName, style: TextStyle(color: Colors.grey[700], fontSize: 13))]),
                    ])),
                    Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: _getStatusColor(item.status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(item.status.toUpperCase(), style: TextStyle(color: _getStatusColor(item.status), fontSize: 11, fontWeight: FontWeight.bold)))
                  ]),
                  Divider(height: 24),
                  if (item.estimatedCompletion != null) Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Row(children: [Icon(Icons.timer_outlined, size: 16, color: Colors.orange), SizedBox(width: 6), Text("Dự kiến: ${DateFormat('dd/MM HH:mm').format(item.estimatedCompletion!)}", style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.w500))])),
                  if (item.notes.isNotEmpty) Container(width: double.infinity, padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Text(item.notes, style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey[800]))),
                  if (isMyTask) Padding(padding: const EdgeInsets.only(top: 16.0), child: SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _showUpdateDialog(item), icon: Icon(Icons.edit_note), label: Text("Cập nhật trạng thái"), style: OutlinedButton.styleFrom(side: BorderSide(color: Color(0xFF0F62FE))))))
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}