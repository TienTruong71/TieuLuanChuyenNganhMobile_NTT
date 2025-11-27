import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần thêm package intl vào pubspec.yaml
import '../../data/mock_data.dart';
import '../../models/app_models.dart';

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

  void _loadData() {
    setState(() {
      _bookingsFuture = MockData().getBookings();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.green;
      case 'in_progress': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: FutureBuilder<List<Booking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final bookings = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final item = bookings[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd/MM - HH:mm').format(item.bookingDate),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(item.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(item.status.toUpperCase(),
                                style: TextStyle(color: _getStatusColor(item.status), fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                        ],
                      ),
                      Divider(),
                      Text("Khách: ${item.userName}", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 4),
                      Text("Dịch vụ: ${item.serviceName}", style: TextStyle(color: Colors.grey[700])),
                      SizedBox(height: 12),
                      if (item.status == 'pending')
                        Row(
                          children: [
                            Expanded(child: OutlinedButton(
                              onPressed: () async {
                                await MockData().updateBookingStatus(item.id, 'cancelled');
                                _loadData();
                              },
                              child: Text("Từ chối"),
                            )),
                            SizedBox(width: 10),
                            Expanded(child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
                              onPressed: () async {
                                await MockData().updateBookingStatus(item.id, 'confirmed');
                                _loadData();
                              },
                              child: Text("Xác nhận", style: TextStyle(color: Colors.white)),
                            )),
                          ],
                        )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}