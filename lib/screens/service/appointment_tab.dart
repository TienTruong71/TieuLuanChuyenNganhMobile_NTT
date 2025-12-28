import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/repository.dart';
import '../../models/index.dart';

class AppointmentTab extends StatefulWidget {
  @override
  _AppointmentTabState createState() => _AppointmentTabState();
}

class _AppointmentTabState extends State<AppointmentTab> {
  late Future<List<Booking>> _bookingsFuture;
  final List<String> _statuses = ['pending', 'confirmed', 'in_progress', 'completed', 'cancelled'];
  String? _selectedStatus;
  final primaryColor = Color(0xFF0F62FE);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _bookingsFuture = Repository().getBookings(status: _selectedStatus);
    });
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(newStatus == 'confirmed' ? "Đã tiếp nhận lịch hẹn" : "Đã từ chối lịch hẹn"),
              backgroundColor: newStatus == 'confirmed' ? Colors.green : Colors.orange
          )
      );
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Tăng chiều cao để chứa padding tốt hơn
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Lọc theo trạng thái",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            value: _selectedStatus,
            items: [
              DropdownMenuItem(value: null, child: Text("Tất cả")),
              ..._statuses.map((s) => DropdownMenuItem(value: s, child: Text(_getVietnameseStatus(s))))
            ],
            onChanged: (val) {
              setState(() => _selectedStatus = val);
              _loadData();
            },
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: FutureBuilder<List<Booking>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 40),
                    SizedBox(height: 10),
                    Text("Lỗi tải dữ liệu: ${snapshot.error}", style: TextStyle(color: Colors.red)),
                    TextButton(onPressed: _loadData, child: Text("Thử lại"))
                  ],
                ),
              );
            }

            final bookings = snapshot.data!;

            if (bookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey[300]),
                    SizedBox(height: 16),
                    Text("Chưa có lịch hẹn nào", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (c, i) => SizedBox(height: 16), // Tăng khoảng cách giữa các card
              itemBuilder: (context, index) {
                final item = bookings[index];
                return _buildBookingCard(item);
              },
            );
          },
        ),
      ),
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
      elevation: 4, // Tăng độ nổi bật
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Ngày giờ + Trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.calendar_today, size: 18, color: primaryColor),
                  SizedBox(width: 8),
                  Text(
                      DateFormat('dd/MM/yyyy - HH:mm').format(item.bookingDate),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[800])
                  ),
                ]),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)
                  ),
                )
              ],
            ),

            Divider(height: 24),

            // Thông tin Khách hàng & Dịch vụ
            Text(item.userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text(item.serviceName, style: TextStyle(color: Colors.grey[700], fontSize: 14)),

            if(item.userPhone.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(item.userPhone, style: TextStyle(color: Colors.grey, fontSize: 13))
                ]),
              ),

            // Nút hành động (Chỉ hiện khi trạng thái là Pending)
            if (item.status == 'pending') ...[
              Divider(height: 28, thickness: 0.5),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(item.id, 'cancelled'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.withOpacity(0.5)),
                          padding: EdgeInsets.symmetric(vertical: 12)
                      ),
                      child: Text("Từ chối", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(item.id, 'confirmed'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12)
                      ),
                      child: Text("Xác nhận", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
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