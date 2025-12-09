import 'package:flutter/material.dart';
import '../../data/repository.dart'; // Sử dụng Repository (API thật)
import '../../models/index.dart';    // Sử dụng index models

class ServiceBayTab extends StatefulWidget {
  @override
  _ServiceBayTabState createState() => _ServiceBayTabState();
}

class _ServiceBayTabState extends State<ServiceBayTab> {
  List<ServiceBay> bays = [];
  List<Booking> bookings = []; // Cache danh sách booking để check trạng thái job
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Tải dữ liệu từ API (Bays + Bookings)
  void _loadData() async {
    try {
      // Gọi song song 2 API để tiết kiệm thời gian
      final results = await Future.wait([
        Repository().getServiceBays(),
        Repository().getBookings(),
      ]);

      if (mounted) {
        setState(() {
          bays = results[0] as List<ServiceBay>;
          bookings = results[1] as List<Booking>;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải dữ liệu: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
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
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _numberCtrl, decoration: InputDecoration(labelText: "Số hiệu (VD: Bay 5)", border: OutlineInputBorder())),
              SizedBox(height: 10),
              TextField(controller: _notesCtrl, decoration: InputDecoration(labelText: "Ghi chú", border: OutlineInputBorder())),
            ]
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Hủy")),
          ElevatedButton(
              onPressed: () async {
                if (_numberCtrl.text.isEmpty) return;
                Navigator.pop(ctx);

                // Gọi API Create
                try {
                  await Repository().createServiceBay(_numberCtrl.text, _notesCtrl.text);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Thêm khoang thành công"), backgroundColor: Colors.green));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
                }
              },
              child: Text("Thêm")
          )
        ],
      ),
    );
  }

  // --- 2. Dialog Quản lý & Trả xe ---
  void _showManageBayDialog(ServiceBay bay) async {
    // Check trạng thái job hiện tại từ list bookings đã cache
    bool isJobDone = false;
    if (bay.currentBookingId != null) {
      try {
        final booking = bookings.firstWhere((b) => b.id == bay.currentBookingId);
        isJobDone = booking.status == 'completed';
      } catch (e) {
        // Không tìm thấy booking (có thể đã bị xóa hoặc lỗi data)
      }
    }

    final _notesCtrl = TextEditingController(text: bay.notes);
    String _tempStatus = bay.status;
    bool isOccupied = bay.status == 'occupied';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text("Cấu hình ${bay.bayNumber}"),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                          try {
                            await Repository().checkoutBay(bay.id);
                            _loadData();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã trả xe thành công!"), backgroundColor: Colors.green));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
                          }
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
              ]
          ),
          actions: [
            if (!isOccupied)
              TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: Text("Xóa khoang này?"), actions: [TextButton(onPressed: ()=>Navigator.pop(c,false), child: Text("Hủy")), TextButton(onPressed: ()=>Navigator.pop(c,true), child: Text("Xóa", style: TextStyle(color: Colors.red)))]));
                    if(confirm == true) {
                      Navigator.pop(ctx);
                      try {
                        await Repository().deleteServiceBay(bay.id);
                        _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã xóa khoang"), backgroundColor: Colors.green));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
                      }
                    }
                  },
                  child: Text("XÓA KHOANG", style: TextStyle(color: Colors.red))
              ),
            ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await Repository().updateServiceBayInfo(bay.id, _notesCtrl.text, _tempStatus);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cập nhật thành công"), backgroundColor: Colors.green));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
                  }
                },
                child: Text("Lưu")
            )
          ],
        ),
      ),
    );
  }

  // --- 3. Dialog Gán xe ---
  void _showAssignDialog(ServiceBay bay) async {
    try {
      // Tải lại booking mới nhất để đảm bảo không gán xe đã hủy/xong
      final latestBookings = await Repository().getBookings();
      final confirmedBookings = latestBookings.where((b) => b.status == 'confirmed').toList();

      showModalBottomSheet(
          context: context,
          builder: (ctx) => Container(
              padding: EdgeInsets.all(16),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Đưa xe vào ${bay.bayNumber}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    if (confirmedBookings.isEmpty)
                      Padding(padding: EdgeInsets.all(20), child: Text("Không có xe chờ (Confirmed).")),

                    ...confirmedBookings.map((booking) => ListTile(
                      leading: Icon(Icons.directions_car, color: Colors.blue),
                      title: Text(booking.userName, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(booking.serviceName),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () async {
                        Navigator.pop(ctx);
                        try {
                          await Repository().assignBookingToBay(bay.id, booking.id);
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã gán xe vào khoang"), backgroundColor: Colors.green));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
                        }
                      },
                    )).toList()
                  ]
              )
          )
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Không thể tải danh sách xe chờ: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: _showAddBayDialog,
          backgroundColor: Color(0xFF0F62FE),
          child: Icon(Icons.add, color: Colors.white)
      ),
      body: GridView.builder(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
        itemCount: bays.length,
        itemBuilder: (context, index) {
          final bay = bays[index];
          final isAvailable = bay.status == 'available';
          final isMaintenance = bay.status == 'maintenance';
          final isOccupied = bay.status == 'occupied';

          // Kiểm tra trạng thái job (Sử dụng dữ liệu đã cache từ _loadData để tránh gọi API liên tục)
          bool isJobDone = false;
          if (isOccupied && bay.currentBookingId != null) {
            try {
              final booking = bookings.firstWhere((b) => b.id == bay.currentBookingId);
              isJobDone = booking.status == 'completed';
            } catch(e) {}
          }

          final statusColor = isAvailable ? Colors.green : (isMaintenance ? Colors.orange : (isJobDone ? Colors.green : Colors.blue));
          final bgColor = isAvailable ? Colors.white : (isMaintenance ? Colors.orange[50]! : (isJobDone ? Colors.green[50]! : Colors.blue[50]!));

          return GestureDetector(
            onTap: () {
              // Nhấn vào thẻ (body)
              if (isAvailable) _showAssignDialog(bay);
              else _showManageBayDialog(bay);
            },
            onLongPress: () => _showManageBayDialog(bay),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: isAvailable ? Colors.green : (isMaintenance ? Colors.orange : (isJobDone ? Colors.green : Colors.blue[800]!)), width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Stack(
                alignment: Alignment.center,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isAvailable ? Icons.add_circle_outline : (isMaintenance ? Icons.build : (isJobDone ? Icons.check_circle : Icons.directions_car)), size: 32, color: statusColor),
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
        },
      ),
    );
  }
}