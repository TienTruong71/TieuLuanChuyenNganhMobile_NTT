import 'package:flutter/material.dart';
import '../../data/repository.dart';
import '../../models/index.dart';

class ServiceBayTab extends StatefulWidget {
  @override
  _ServiceBayTabState createState() => _ServiceBayTabState();
}

class _ServiceBayTabState extends State<ServiceBayTab> {
  List<ServiceBay> bays = [];
  List<Booking> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => isLoading = true);
    try {
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

  // --- Helpers UI ---
  Color _getBayColor(ServiceBay bay, bool isJobDone) {
    if (bay.status == 'available') return Colors.green;
    if (bay.status == 'maintenance') return Colors.orange;
    if (bay.status == 'occupied') {
      return isJobDone ? Colors.green : Colors.blue[800]!;
    }
    return Colors.grey;
  }

  Color _getBayBgColor(ServiceBay bay, bool isJobDone) {
    if (bay.status == 'available') return Colors.white;
    if (bay.status == 'maintenance') return Colors.orange[50]!;
    if (bay.status == 'occupied') {
      return isJobDone ? Colors.green[50]! : Colors.blue[50]!;
    }
    return Colors.grey[50]!;
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available': return 'Trống';
      case 'maintenance': return 'Bảo trì';
      case 'occupied': return 'Đang sử dụng';
      default: return 'Không rõ';
    }
  }
  // --- END Helpers UI ---


  // --- 1. Dialog Thêm Khoang ---
  void _showAddBayDialog() {
    final _numberCtrl = TextEditingController();
    final _notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Thêm Khu Vực Mới", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _numberCtrl,
                  decoration: InputDecoration(
                      labelText: "Số hiệu (VD: Bay 5)",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                  )
              ),
              SizedBox(height: 16),
              TextField(
                  controller: _notesCtrl,
                  decoration: InputDecoration(
                      labelText: "Ghi chú",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                  )
              ),
            ]
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Hủy")),
          ElevatedButton(
              onPressed: () async {
                if (_numberCtrl.text.isEmpty) return;
                Navigator.pop(ctx);

                try {
                  await Repository().createServiceBay(_numberCtrl.text, _notesCtrl.text);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Thêm khoang thành công"), backgroundColor: Colors.green));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F62FE), foregroundColor: Colors.white),
              child: Text("Thêm")
          )
        ],
      ),
    );
  }

  // --- 2. Dialog Quản lý & Trả xe ---
  void _showManageBayDialog(ServiceBay bay) async {
    bool isJobDone = false;
    if (bay.currentBookingId != null) {
      try {
        final booking = bookings.firstWhere((b) => b.id == bay.currentBookingId);
        isJobDone = booking.status == 'completed';
      } catch (e) {
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
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: isJobDone ? Colors.green[50] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isJobDone ? Colors.green : Colors.blue[300]!)
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(isJobDone ? Icons.check_circle : Icons.build, color: isJobDone ? Colors.green : Colors.blue, size: 24),
                          SizedBox(width: 12),
                          Expanded(child: Text(isJobDone ? "Dịch vụ đã hoàn tất.\nChờ khách lấy xe." : "Xe đang được sửa chữa.", style: TextStyle(fontWeight: FontWeight.bold)))
                        ]),
                  ),
                  SizedBox(height: 16),
                  if (isJobDone)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12)
                        ),
                        icon: Icon(Icons.outbond),
                        label: Text("TRẢ XE / GIẢI PHÓNG"),
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
                    decoration: InputDecoration(labelText: "Trạng thái", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    items: [
                      {'val': 'available', 'label': '🟢 Sẵn sàng'},
                      {'val': 'maintenance', 'label': '🟠 Bảo trì'}
                    ].map((e) => DropdownMenuItem(value: e['val'], child: Text(e['label']!))).toList(),
                    onChanged: (val) => setStateDialog(() => _tempStatus = val!),
                  )
                ],
                SizedBox(height: 16),
                TextField(
                    controller: _notesCtrl,
                    decoration: InputDecoration(
                        labelText: "Ghi chú",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                    ),
                    maxLines: 2
                ),
              ]
          ),
          actions: [
            if (!isOccupied)
              TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: Text("Xác nhận xóa"), content: Text("Bạn có chắc chắn muốn xóa khoang ${bay.bayNumber}?"), actions: [TextButton(onPressed: ()=>Navigator.pop(c,false), child: Text("Hủy")), TextButton(onPressed: ()=>Navigator.pop(c,true), child: Text("Xóa", style: TextStyle(color: Colors.red)))]));
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Hủy")),
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
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F62FE), foregroundColor: Colors.white),
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
      final latestBookings = await Repository().getBookings();
      final confirmedBookings = latestBookings.where((b) => b.status == 'confirmed').toList();

      showModalBottomSheet(
          context: context,
          builder: (ctx) => Container(
              padding: EdgeInsets.all(20),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Đưa xe vào ${bay.bayNumber}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F62FE))),
                    SizedBox(height: 16),
                    if (confirmedBookings.isEmpty)
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text("Không có lịch hẹn đã xác nhận (Confirmed) đang chờ.", style: TextStyle(color: Colors.grey)))
                      ),

                    ...confirmedBookings.map((booking) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
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
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue[100]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                                child: Icon(Icons.directions_car, color: Colors.blue[800], size: 24),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(booking.userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    SizedBox(height: 2),
                                    Text(booking.serviceName, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
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

    if (bays.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.garage_outlined, size: 60, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text("Chưa có khu vực dịch vụ nào được định nghĩa.", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAddBayDialog,
              child: Text("Tạo Khu vực đầu tiên"),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F62FE), foregroundColor: Colors.white),
            )
          ],
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: _showAddBayDialog,
          backgroundColor: Color(0xFF0F62FE),
          child: Icon(Icons.add, color: Colors.white)
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: GridView.builder(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.9), // Tăng aspect ratio lên 0.9
          itemCount: bays.length,
          itemBuilder: (context, index) {
            final bay = bays[index];
            final isAvailable = bay.status == 'available';
            final isMaintenance = bay.status == 'maintenance';
            final isOccupied = bay.status == 'occupied';

            bool isJobDone = false;
            if (isOccupied && bay.currentBookingId != null) {
              try {
                final booking = bookings.firstWhere((b) => b.id == bay.currentBookingId);
                isJobDone = booking.status == 'completed';
              } catch(e) {}
            }

            final statusColor = _getBayColor(bay, isJobDone);
            final bgColor = _getBayBgColor(bay, isJobDone);

            return InkWell(
              onTap: () {
                if (isAvailable) _showAssignDialog(bay);
                else _showManageBayDialog(bay);
              },
              onLongPress: () => _showManageBayDialog(bay),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Bay number and status text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(bay.bayNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: statusColor)),
                          Text(
                            _getStatusText(bay.status),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                          )
                        ],
                      ),

                      SizedBox(height: 10),
                      Divider(height: 0),
                      SizedBox(height: 10),

                      // Icon and main status
                      Center(
                        child: Icon(
                            isAvailable ? Icons.add_circle_outline : (isMaintenance ? Icons.build_circle_outlined : (isJobDone ? Icons.check_circle_outline : Icons.directions_car)),
                            size: 36,
                            color: statusColor
                        ),
                      ),

                      SizedBox(height: 12),

                      // Nội dung chi tiết
                      if (isOccupied) ...[
                        Text(
                            bay.bookingUserName ?? "Khách hàng",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis
                        ),
                        SizedBox(height: 4),
                        Text(
                            bay.bookingServiceName ?? "Dịch vụ",
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis
                        ),
                        Spacer(),
                        Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                                color: isJobDone ? Colors.green : Colors.blue[100],
                                borderRadius: BorderRadius.circular(4)
                            ),
                            child: Center(
                                child: Text(
                                    isJobDone ? "CHỜ GIAO XE" : "ĐANG SỬA",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: isJobDone ? Colors.white : Colors.blue[900],
                                        fontWeight: FontWeight.bold
                                    )
                                )
                            )
                        )
                      ] else if (isMaintenance) ...[
                        Text("Ghi chú:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            bay.notes.isNotEmpty ? bay.notes : "Không có ghi chú bảo trì.",
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Spacer(),
                      ] else ...[
                        Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showAssignDialog(bay),
                            icon: Icon(Icons.add, size: 16),
                            label: Text("Gán xe", style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 8)
                            ),
                          ),
                        )
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}