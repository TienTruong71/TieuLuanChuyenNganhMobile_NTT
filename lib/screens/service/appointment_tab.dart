import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';

class AppointmentTab extends StatefulWidget {
  @override
  _AppointmentTabState createState() => _AppointmentTabState();
}

class _AppointmentTabState extends State<AppointmentTab> {
  late Future<List<Booking>> _bookingsFuture;

  @override
  void initState() { super.initState(); _loadData(); }
  void _loadData() { setState(() { _bookingsFuture = MockData().getBookings(); }); }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: FutureBuilder<List<Booking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final bookings = snapshot.data!;
          if (bookings.isEmpty) return Center(child: Text("Chưa có lịch hẹn nào"));

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
      default: statusColor = Colors.red; statusText = "Hủy";
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 6),
                  Text(DateFormat('dd/MM - HH:mm').format(item.bookingDate), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ]),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            SizedBox(height: 12),
            Text(item.userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Text(item.serviceName, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
            if(item.userPhone.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(children: [Icon(Icons.phone, size: 14, color: Colors.grey), SizedBox(width: 4), Text(item.userPhone, style: TextStyle(color: Colors.grey))]),
              ),

            if (item.status == 'pending') ...[
              Divider(height: 24, thickness: 0.5),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async { await MockData().updateBookingStatus(item.id, 'cancelled'); _loadData(); },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: BorderSide(color: Colors.red[200]!)),
                      child: Text("Từ chối"),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async { await MockData().updateBookingStatus(item.id, 'confirmed'); _loadData(); },
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