import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/repository.dart';
import '../../models/index.dart';

class RepairProgressTab extends StatefulWidget {
  @override
  _RepairProgressTabState createState() => _RepairProgressTabState();
}

class _RepairProgressTabState extends State<RepairProgressTab> {
  List<RepairProgress> progressList = [];
  bool isLoading = true;
  String? currentStaffId;
  final primaryColor = Color(0xFF0F62FE);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => isLoading = true);
    try {
      final user = await Repository().getCurrentUser();
      final data = await Repository().getRepairProgress();

      if (mounted) {
        setState(() {
          currentStaffId = user?.id;
          progressList = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showUpdateDialog(RepairProgress item) {
    final _notesCtrl = TextEditingController(text: item.notes);
    String _status = item.status;
    DateTime? _selectedDate = item.estimatedCompletion;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text("Cập nhật Tiến độ", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Dịch vụ: ${item.bookingServiceName}", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                  SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: InputDecoration(
                      labelText: "Trạng thái",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: [
                      {'val': 'in_progress', 'label': 'Đang sửa'},
                      {'val': 'waiting_parts', 'label': 'Chờ linh kiện'},
                      {'val': 'testing', 'label': 'Đang kiểm tra'},
                      {'val': 'completed', 'label': '✅ Hoàn thành'}
                    ].map((e) => DropdownMenuItem(value: e['val'], child: Text(e['label']!))).toList(),
                    onChanged: (val) => setStateDialog(() => _status = val!),
                  ),

                  SizedBox(height: 16),
                  TextField(
                      controller: _notesCtrl,
                      decoration: InputDecoration(
                        labelText: "Ghi chú kỹ thuật",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      maxLines: 3
                  ),

                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2025)
                      );
                      if (date != null) {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          setStateDialog(() {
                            _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          });
                        }
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Dự kiến hoàn thành",
                        suffixIcon: Icon(Icons.calendar_month, color: primaryColor),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      child: Text(_selectedDate == null ? "Chưa đặt" : DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate!)),
                    ),
                  )
                ]
            ),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dCtx) => AlertDialog(
                          title: Text("Xác nhận xóa"),
                          content: Text("Bạn có chắc chắn muốn xóa tiến độ này?"),
                          actions: [
                            TextButton(onPressed: ()=>Navigator.pop(dCtx,false), child: Text("Hủy")),
                            TextButton(onPressed: ()=>Navigator.pop(dCtx,true), child: Text("Xóa", style: TextStyle(color: Colors.red)))
                          ]
                      )
                  );

                  if (confirm == true) {
                    Navigator.pop(ctx);
                    try {
                      await Repository().deleteRepairProgress(item.id);
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã xóa"), backgroundColor: Colors.green));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi xóa: $e"), backgroundColor: Colors.red));
                    }
                  }
                },
                child: Text("XÓA", style: TextStyle(color: Colors.red))
            ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Hủy")),
            ElevatedButton(
                onPressed: () async {
                  bool freeBay = false;

                  if (_status == 'completed') {
                    final result = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (dCtx) => AlertDialog(
                            title: Text("Hoàn tất sửa chữa!"),
                            content: Text("Bạn có muốn giải phóng khu vực dịch vụ ngay lập tức không?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text("Không, chờ giao")),
                              ElevatedButton(onPressed: () => Navigator.pop(dCtx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: Text("Có, trả khoang"))
                            ]
                        )
                    );
                    freeBay = result ?? false;
                  }

                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đang cập nhật...")));
                  try {
                    await Repository().updateRepairProgressFull(
                        item.id,
                        status: _status,
                        notes: _notesCtrl.text,
                        estimatedCompletion: _selectedDate,
                        freeBay: freeBay
                    );
                    _loadData();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cập nhật thành công!"), backgroundColor: Colors.green));
                  } catch (e) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                child: Text("Lưu")
            )
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch(status) {
      case 'completed': return Colors.green;
      case 'waiting_parts': return Colors.orange;
      case 'testing': return Colors.purple;
      default: return Colors.blue;
    }
  }

  String _getVietnameseStatus(String status) {
    switch (status) {
      case 'in_progress': return 'ĐANG SỬA';
      case 'waiting_parts': return 'CHỜ LINH KIỆN';
      case 'testing': return 'ĐANG KIỂM TRA';
      case 'completed': return 'HOÀN THÀNH';
      default: return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    if (progressList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timelapse_outlined, size: 60, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text("Không có xe đang sửa chữa", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: progressList.length,
          separatorBuilder: (c,i) => SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = progressList[index];
            final isMyTask = (currentStaffId != null && item.staffId == currentStaffId);
            final statusColor = _getStatusColor(item.status);

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER & STATUS CHIP ---
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          item.bookingServiceName,
                                          style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: primaryColor)
                                      ),
                                      SizedBox(height: 4),
                                      Row(children: [
                                        Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(item.bookingUserName, style: TextStyle(color: Colors.grey[700], fontSize: 13))
                                      ]),
                                    ]
                                )
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                                child: Text(_getVietnameseStatus(item.status), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold))
                            )
                          ]
                      ),

                      Divider(height: 24),

                      // --- ESTIMATED COMPLETION ---
                      if (item.estimatedCompletion != null)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(children: [
                              Icon(Icons.timer_outlined, size: 18, color: Colors.orange),
                              SizedBox(width: 8),
                              Text("Dự kiến hoàn thành: ${DateFormat('dd/MM HH:mm').format(item.estimatedCompletion!)}", style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.w600, fontSize: 13))
                            ])
                        ),

                      // --- NOTES ---
                      if (item.notes.isNotEmpty)
                        Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Ghi chú kỹ thuật:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[700])),
                                SizedBox(height: 4),
                                Text(item.notes, style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                              ],
                            )
                        ),

                      // --- ACTION BUTTON ---
                      if (isMyTask)
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                                onPressed: () => _showUpdateDialog(item),
                                icon: Icon(Icons.edit_note),
                                label: Text("Cập nhật trạng thái", style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: EdgeInsets.symmetric(vertical: 12)
                                )
                            )
                        )
                    ]
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}