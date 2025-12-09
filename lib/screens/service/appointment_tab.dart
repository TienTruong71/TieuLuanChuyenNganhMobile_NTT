import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/repository.dart'; // Sử dụng Repository
import '../../models/index.dart';    // Sử dụng index models

class AppointmentTab extends StatefulWidget {
  @override
  _AppointmentTabState createState() => _AppointmentTabState();
}

class _AppointmentTabState extends State<AppointmentTab> {
  late Future<List<Booking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Tải dữ liệu
  void _loadData() {
    setState(() {
      _bookingsFuture = Repository().getBookings();
    });
  }

  // Hàm xử lý cập nhật trạng thái (Duyệt / Từ chối)
  void _updateStatus(String bookingId, String newStatus) async {
    // Hiển thị thông báo đang xử lý
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đang xử lý..."), duration: Duration(milliseconds: 800))
    );

    try {
      await Repository().updateBookingStatus(bookingId, newStatus);

      // Kiểm tra xem màn hình còn hiển thị không trước khi update UI
      if (!mounted) return;

      // Tải lại danh sách sau khi update thành công
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
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: FutureBuilder<List<Booking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          // 1. Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // 2. Trạng thái lỗi
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 40),
                  SizedBox(height: 10),
                  Text("Lỗi tải dữ liệu", style: TextStyle(color: Colors.red)),
                  TextButton(onPressed: _loadData, child: Text("Thử lại"))
                ],
              ),
            );
          }

          final bookings = snapshot.data!;

          // 3. Trạng thái danh sách trống
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

          // 4. Hiển thị danh sách
          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (c, i) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = bookings[index];
              return _buildBookingCard(item);
            },
          );
        },
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
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 6),
                  Text(
                      DateFormat('dd/MM - HH:mm').format(item.bookingDate),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                  ),
                ]),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)
                  ),
                )
              ],
            ),

            SizedBox(height: 12),

            // Thông tin Khách hàng & Dịch vụ
            Text(item.userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text(item.serviceName, style: TextStyle(color: Colors.grey[700], fontSize: 14)),

            if(item.userPhone.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(item.userPhone, style: TextStyle(color: Colors.grey, fontSize: 13))
                ]),
              ),

            // Nút hành động (Chỉ hiện khi trạng thái là Pending)
            if (item.status == 'pending') ...[
              Divider(height: 24, thickness: 0.5),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(item.id, 'cancelled'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red[200]!)
                      ),
                      child: Text("Từ chối"),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(item.id, 'confirmed'),
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F62FE)),
                      child: Text("Xác nhận"),
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