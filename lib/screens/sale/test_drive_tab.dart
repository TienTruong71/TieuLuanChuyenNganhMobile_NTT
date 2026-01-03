import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/repository.dart';
import '../../models/booking_model.dart';

class TestDriveTab extends StatefulWidget {
  @override
  State<TestDriveTab> createState() => _TestDriveTabState();
}

class _TestDriveTabState extends State<TestDriveTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Booking> bookings = [];
  bool isLoading = true;

  // Filter vars
  DateTime? _selectedDate;
  String _filterStatus = ''; // Used for "Tất cả" tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => isLoading = true);
    try {
      String statusParam = '';
      if (_tabController.index == 0) {
        // Tab 0: Chờ xác nhận
        statusParam = 'pending';
      } else {
        // Tab 1: Tất cả - use filter
        statusParam = _filterStatus;
      }

      String? dateParam;
      if (_selectedDate != null) {
        dateParam = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      }

      final data = await Repository().getTestDriveBookings(
        status: statusParam,
        date: dateParam,
      );
      
      if (mounted) {
        setState(() {
          bookings = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      print(e); // Debug
    }
  }

  Future<void> _updateStatus(String id, String status, {String? note}) async {
    try {
      await Repository().updateTestDriveStatus(id, status, note: note);
      _loadBookings(); // Reload
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Trạng thái đã cập nhật thành: $status")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadBookings();
    }
  }

  void _clearDate() {
    setState(() => _selectedDate = null);
    _loadBookings();
  }

  // --- DIALOGS (Keep existing logic) ---
  void _showActionDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Cập nhật trạng thái"),
        content: Text("Chọn trạng thái cho lịch hẹn của ${booking.userName}"),
        actions: [
          if (booking.status == 'pending')
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus(booking.id, 'confirmed');
              },
              child: Text("Xác nhận"),
            ),
          if (booking.status != 'completed' && booking.status != 'cancelled')
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus(booking.id, 'completed');
              },
              child: Text("Hoàn thành"),
            ),
          if (booking.status != 'completed' && booking.status != 'cancelled')
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showCancelReasonDialog(booking);
              },
              child: Text("Hủy", style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Đóng"),
          ),
        ],
      ),
    );
  }

  void _showCancelReasonDialog(Booking booking) {
    final _reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Lý do hủy lịch"),
        content: TextField(
          controller: _reasonController,
          decoration: InputDecoration(hintText: "Nhập lý do hủy..."),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Quay lại"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(booking.id, 'cancelled', note: _reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Xác nhận hủy", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- UI HELPERS ---
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Chờ xác nhận';
      case 'confirmed': return 'Đã xác nhận';
      case 'completed': return 'Hoàn thành';
      case 'cancelled': return 'Đã hủy';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Chờ xác nhận"),
              Tab(text: "Tất cả"),
            ],
          ),
        ),

        // 2. Filters (Date & Status)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[100],
          child: Row(
            children: [
              // Date Picker
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedDate == null 
                              ? "Chọn ngày" 
                              : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_selectedDate != null)
                          GestureDetector(
                            onTap: _clearDate,
                            child: Icon(Icons.close, size: 16, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 12),

              // Status Dropdown (Only for "All" tab)
              if (_tabController.index == 1)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterStatus,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(value: '', child: Text("Tất cả TT")),
                          DropdownMenuItem(value: 'confirmed', child: Text("Đã xác nhận")),
                          DropdownMenuItem(value: 'completed', child: Text("Hoàn thành")),
                          DropdownMenuItem(value: 'cancelled', child: Text("Đã hủy")),
                          // pending is in the other tab, but can be here too logically
                          DropdownMenuItem(value: 'pending', child: Text("Chờ xác nhận")), 
                        ],
                        onChanged: (val) {
                          setState(() => _filterStatus = val ?? '');
                          _loadBookings();
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 3. List
        Expanded(
          child: isLoading 
            ? Center(child: CircularProgressIndicator())
            : bookings.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("Không có lịch hẹn nào"),
                  ],
                ))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final b = bookings[i];
                    final dateStr = DateFormat("dd/MM/yyyy").format(b.bookingDate);
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () => _showActionDialog(b),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.drive_eta, color: Colors.blue),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.productName.isNotEmpty ? b.productName : "Xe ẩn danh",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    SizedBox(height: 4),
                                    Text("KH: ${b.userName}"),
                                    Text("SĐT: ${b.userPhone}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text("$dateStr - ${b.timeSlot}", style: TextStyle(fontSize: 13)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(b.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: _getStatusColor(b.status).withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      _getStatusText(b.status),
                                      style: TextStyle(
                                        color: _getStatusColor(b.status),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  if (b.status == 'pending')
             Icon(Icons.circle, size: 10, color: Colors.orange)
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
