import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import để init locale
import '../../data/repository.dart';
import '../../models/index.dart';

class AppointmentTab extends StatefulWidget {
  @override
  _AppointmentTabState createState() => _AppointmentTabState();
}

class _AppointmentTabState extends State<AppointmentTab> {
  Future<List<Booking>>? _bookingsFuture;
  final List<String> _statuses = ['pending', 'confirmed', 'in_progress', 'completed', 'cancelled'];
  String? _selectedStatus;
  DateTime? _selectedDate = DateTime.now(); // Mặc định là hôm nay

  final primaryColor = Color(0xFF0F62FE);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi', null).then((_) {
        _loadData(); // Gọi load data sau khi init xong locale
    });
  }

  void _loadData() {
    setState(() {
      _bookingsFuture = Repository().getBookings(status: _selectedStatus, singleDate: _selectedDate);
    });
  }

  // Chọn ngày
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  String _getVietnameseStatus(String status) {
    switch (status) {
      case 'pending': return 'Chờ duyệt';
      case 'confirmed': return 'Đã tiếp nhận';
      case 'in_progress': return 'Đang xử lý';
      case 'completed': return 'Hoàn thành';
      case 'cancelled': return 'Đã hủy';
      default: return status;
    }
  }

  void _updateStatus(String bookingId, String newStatus) async {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đang xử lý..."), duration: Duration(milliseconds: 800))
    );

    try {
      await Repository().updateBookingStatus(bookingId, newStatus);
      if (!mounted) return;
      _loadData();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.shade50
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month, color: primaryColor),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Xem lịch ngày", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            Text(
                              _selectedDate != null 
                                ? DateFormat('EEEE, dd/MM/yyyy', 'vi').format(_selectedDate!) 
                                : "Tất cả các ngày",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                            ),
                          ],
                        ),
                        Spacer(),
                        if (_selectedDate != null)
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                               setState(() => _selectedDate = null);
                               _loadData();
                            },
                          )
                        else
                          Icon(Icons.arrow_drop_down, color: Colors.grey)
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Lọc theo trạng thái"
                    ),
                    value: _selectedStatus,
                    items: [
                      DropdownMenuItem(value: null, child: Text("Tất cả trạng thái")),
                      ..._statuses.map((s) => DropdownMenuItem(value: s, child: Text(_getVietnameseStatus(s))))
                    ],
                    onChanged: (val) {
                      setState(() => _selectedStatus = val);
                      _loadData();
                    },
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: _bookingsFuture == null 
                  ? Center(child: CircularProgressIndicator()) 
                  : FutureBuilder<List<Booking>>(
                future: _bookingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}", style: TextStyle(color: Colors.red)));
                  }
                  final bookings = snapshot.data!;
                  if (bookings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
                          SizedBox(height: 16),
                          Text(
                              _selectedDate != null 
                                  ? "Không có lịch hẹn nào ngày này"
                                  : "Chưa có lịch hẹn nào", 
                              style: TextStyle(color: Colors.grey)
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.all(16),
                    itemCount: bookings.length,
                    separatorBuilder: (c, i) => SizedBox(height: 16),
                    itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
                  );
                },
              ),
            ),
          ),
        ],
      );
  }

  Widget _buildBookingCard(Booking item) {
    Color statusColor;
    String statusText;
    switch (item.status) {
      case 'pending': statusColor = Colors.orange; statusText = "Chờ duyệt"; break;
      case 'confirmed': statusColor = Colors.green; statusText = "Đã tiếp nhận"; break;
      case 'in_progress': statusColor = Colors.blue; statusText = "Đang xử lý"; break;
      case 'completed': statusColor = Colors.grey; statusText = "Hoàn thành"; break;
      case 'cancelled': statusColor = Colors.red; statusText = "Đã hủy"; break;
      default: statusColor = Colors.grey; statusText = item.status;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Time Slot & Date
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Icon(Icons.access_time_filled, size: 16, color: primaryColor),
                    SizedBox(width: 6),
                    Text(
                      item.timeSlot.isNotEmpty ? item.timeSlot : "Chưa có giờ",
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 15)
                    ),
                  ]),
                ),
                SizedBox(width: 12),
                Text(
                    DateFormat('dd/MM/yyyy').format(item.bookingDate),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                )
              ],
            ),
            Divider(height: 24),
            // Client Info
            Text(item.userName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(item.serviceName, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
            if(item.userPhone.isNotEmpty)
               Padding(
                 padding: const EdgeInsets.only(top: 4.0),
                 child: Text("SĐT: ${item.userPhone}", style: TextStyle(color: Colors.grey, fontSize: 13)),
               ),
               
            // Action Buttons
            if (item.status == 'pending') ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                       onPressed: () => _updateStatus(item.id, 'cancelled'),
                       child: Text("Từ chối"),
                       style: OutlinedButton.styleFrom(foregroundColor: Colors.red)
                    )
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                       onPressed: () => _updateStatus(item.id, 'confirmed'),
                       child: Text("Xác nhận"),
                       style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white)
                    )
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}