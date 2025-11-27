// lib/screens/service/service_bay_tab.dart
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';

class ServiceBayTab extends StatefulWidget {
  @override
  _ServiceBayTabState createState() => _ServiceBayTabState();
}

class _ServiceBayTabState extends State<ServiceBayTab> {
  List<ServiceBay> bays = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => isLoading = true);
    try {
      final data = await MockData().getServiceBays();
      setState(() {
        bays = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // --- 1. Dialog Thêm Khoang ---
  void _showAddBayDialog() {
    final _numberCtrl = TextEditingController();
    final _notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Thêm Khu Vực Mới"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _numberCtrl, decoration: InputDecoration(labelText: "Số hiệu (VD: Bay 5)", border: OutlineInputBorder())),
          SizedBox(height: 10),
          TextField(controller: _notesCtrl, decoration: InputDecoration(labelText: "Ghi chú", border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Hủy")),
          ElevatedButton(onPressed: () async {
            if (_numberCtrl.text.isEmpty) return;
            Navigator.pop(ctx);
            await MockData().createServiceBay(_numberCtrl.text, _notesCtrl.text);
            _loadData();
          }, child: Text("Thêm"))
        ],
      ),
    );
  }

  // --- 2. Dialog Quản lý & Trả xe ---
  void _showManageBayDialog(ServiceBay bay) async {
    // Check trạng thái job hiện tại để xem xong chưa
    bool isJobDone = false;
    if (bay.currentBookingId != null) {
      final bookings = await MockData().getBookings();
      try {
        final booking = bookings.firstWhere((b) => b.id == bay.currentBookingId);
        isJobDone = booking.status == 'completed';
      } catch (e) {}
    }

    final _notesCtrl = TextEditingController(text: bay.notes);
    String _tempStatus = bay.status;
    bool isOccupied = bay.status == 'occupied';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text("Cấu hình ${bay.bayNumber}"),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            if (isOccupied) ...[
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: isJobDone ? Colors.green[50] : Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  Icon(isJobDone ? Icons.check_circle : Icons.build, color: isJobDone ? Colors.green : Colors.blue),
                  SizedBox(width: 10),
                  Expanded(child: Text(isJobDone ? "Dịch vụ đã hoàn tất.\nChờ khách lấy xe." : "Xe đang được sửa chữa.", style: TextStyle(fontWeight: FontWeight.bold)))
                ]),
              ),
              SizedBox(height: 10),
              if (isJobDone)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    icon: Icon(Icons.outbond, color: Colors.white),
                    label: Text("TRẢ XE / GIẢI PHÓNG", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await MockData().checkoutBay(bay.id);
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã trả xe thành công!")));
                    },
                  ),
                )
            ] else ...[
              DropdownButtonFormField<String>(
                value: _tempStatus,
                decoration: InputDecoration(labelText: "Trạng thái", border: OutlineInputBorder()),
                items: [{'val': 'available', 'label': '🟢 Sẵn sàng'}, {'val': 'maintenance', 'label': '🟠 Bảo trì'}].map((e) => DropdownMenuItem(value: e['val'], child: Text(e['label']!))).toList(),
                onChanged: (val) => setStateDialog(() => _tempStatus = val!),
              )
            ],
            SizedBox(height: 10),
            TextField(controller: _notesCtrl, decoration: InputDecoration(labelText: "Ghi chú", border: OutlineInputBorder()), maxLines: 2),
          ]),
          actions: [
            if (!isOccupied)
              TextButton(onPressed: () async {
                final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: Text("Xóa khoang này?"), actions: [TextButton(onPressed: ()=>Navigator.pop(c,true), child: Text("Xóa"))]));
                if(confirm == true) { Navigator.pop(ctx); await MockData().deleteServiceBay(bay.id); _loadData(); }
              }, child: Text("XÓA KHOANG", style: TextStyle(color: Colors.red))),
            ElevatedButton(onPressed: () async {
              Navigator.pop(ctx);
              await MockData().updateServiceBayInfo(bay.id, _notesCtrl.text, _tempStatus);
              _loadData();
            }, child: Text("Lưu"))
          ],
        ),
      ),
    );
  }

  // --- 3. Dialog Gán xe ---
  void _showAssignDialog(ServiceBay bay) async {
    final allBookings = await MockData().getBookings();
    final confirmedBookings = allBookings.where((b) => b.status == 'confirmed').toList();
    showModalBottomSheet(context: context, builder: (ctx) => Container(
        padding: EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Đưa xe vào ${bay.bayNumber}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          if (confirmedBookings.isEmpty) Padding(padding: EdgeInsets.all(20), child: Text("Không có xe chờ (Confirmed).")),
          ...confirmedBookings.map((booking) => ListTile(
            leading: Icon(Icons.directions_car, color: Colors.blue),
            title: Text(booking.userName, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(booking.serviceName),
            trailing: Icon(Icons.arrow_forward),
            onTap: () async { Navigator.pop(ctx); await MockData().assignBookingToBay(bay.id, booking.id); _loadData(); },
          )).toList()
        ])
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _showAddBayDialog, backgroundColor: Colors.blue[800], child: Icon(Icons.add, color: Colors.white)),
      body: GridView.builder(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
        itemCount: bays.length,
        itemBuilder: (context, index) {
          final bay = bays[index];
          final isAvailable = bay.status == 'available';
          final isMaintenance = bay.status == 'maintenance';
          final isOccupied = bay.status == 'occupied';

          return FutureBuilder<List<Booking>>(
              future: MockData().getBookings(),
              builder: (context, snapshot) {
                bool isJobDone = false;
                if (snapshot.hasData && isOccupied && bay.currentBookingId != null) {
                  try {
                    final booking = snapshot.data!.firstWhere((b) => b.id == bay.currentBookingId);
                    isJobDone = booking.status == 'completed';
                  } catch(e) {}
                }

                return GestureDetector(
                  onTap: () {
                    // Nhấn vào thẻ (body)
                    if (isAvailable) _showAssignDialog(bay);
                    else _showManageBayDialog(bay);
                  },
                  onLongPress: () => _showManageBayDialog(bay),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.white : (isMaintenance ? Colors.orange[50] : (isJobDone ? Colors.green[50] : Colors.blue[50])),
                      border: Border.all(color: isAvailable ? Colors.green : (isMaintenance ? Colors.orange : (isJobDone ? Colors.green : Colors.blue[800]!)), width: 2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Stack(
                      alignment: Alignment.center, // <--- SỬA LỖI Ở ĐÂY: Căn giữa toàn bộ nội dung trong Stack
                      children: [

                        // Nút Settings (Đã sửa InkWell)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                _showManageBayDialog(bay);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.settings, size: 22, color: Colors.grey[600]),
                              ),
                            ),
                          ),
                        ),

                        // Nội dung chính
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, // Căn giữa dọc
                            children: [
                              Icon(isAvailable ? Icons.add_circle_outline : (isMaintenance ? Icons.build : (isJobDone ? Icons.check_circle : Icons.directions_car)), size: 32, color: isAvailable ? Colors.green : (isMaintenance ? Colors.orange : (isJobDone ? Colors.green : Colors.blue[800]))),
                              SizedBox(height: 8),
                              Text(bay.bayNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Divider(height: 12),
                              if (isOccupied) ...[
                                Text(bay.bookingUserName ?? "Khách", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                                SizedBox(height: 2),
                                Text(bay.bookingServiceName ?? "Dịch vụ", style: TextStyle(fontSize: 11, color: Colors.grey[700]), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                                SizedBox(height: 4),
                                Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: isJobDone ? Colors.green : Colors.blue[100], borderRadius: BorderRadius.circular(4)), child: Text(isJobDone ? "CHỜ GIAO XE" : "ĐANG SỬA", style: TextStyle(fontSize: 10, color: isJobDone ? Colors.white : Colors.blue[900], fontWeight: FontWeight.bold)))
                              ] else if (isMaintenance) ...[
                                Text("Đang bảo trì", style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
                              ] else ...[
                                Text("Trống", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                Text("Chạm để nhận xe", style: TextStyle(fontSize: 10, color: Colors.grey))
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
          );
        },
      ),
    );
  }
}