// lib/data/mock_data.dart
import '../models/app_models.dart';

class MockData {
  static final MockData _instance = MockData._internal();
  factory MockData() => _instance;
  MockData._internal();

  User? currentUser;

  // --- DATA STORE ---
  final List<User> _usersDB = [
    User(id: 'u1', username: 'service_staff', email: 'service@gara.com', fullName: 'Nguyễn Kỹ Thuật', phone: '0901234567', address: 'Hà Nội', roleName: 'service'),
    User(id: 'u2', username: 'inventory_staff', email: 'kho@gara.com', fullName: 'Trần Thủ Kho', phone: '0909999999', address: 'Đà Nẵng', roleName: 'inventory'),
    User(id: 'u3', username: 'sale_staff', email: 'sale@gara.com', fullName: 'Lê Sales', phone: '0908888888', address: 'HCM', roleName: 'sale'),
  ];

  List<Booking> bookings = [
    Booking(id: '1', userId: 'c1', userName: 'Nguyễn Văn A', userPhone: '0912345678', serviceName: 'Bảo dưỡng cấp 1', bookingDate: DateTime.now().add(Duration(hours: 1)), status: 'pending'),
    Booking(id: '2', userId: 'c2', userName: 'Trần Thị B', userPhone: '0987654321', serviceName: 'Thay dầu & Lọc nhớt', bookingDate: DateTime.now().add(Duration(hours: 2)), status: 'confirmed'),
    Booking(id: '3', userId: 'c3', userName: 'Lê Văn C', userPhone: '0909090909', serviceName: 'Sửa hệ thống phanh', bookingDate: DateTime.now().subtract(Duration(hours: 1)), status: 'in_progress'),
  ];

  List<ServiceBay> serviceBays = [
    // Bay 1 đang có xe (cần điền info fake vào đây để hiển thị đúng ngay lần đầu load)
    ServiceBay(id: 'bay1', bayNumber: 'Khoang 01', status: 'occupied', currentBookingId: '3', bookingUserName: 'Lê Văn C', bookingServiceName: 'Sửa hệ thống phanh'),
    ServiceBay(id: 'bay2', bayNumber: 'Khoang 02', status: 'available'),
    ServiceBay(id: 'bay3', bayNumber: 'Khoang 03', status: 'maintenance', notes: 'Hỏng cầu nâng'),
  ];

  List<RepairProgress> repairProgresses = [
    RepairProgress(id: 'prog1', bookingId: '3', staffId: 'u1', staffName: 'Nguyễn Kỹ Thuật', status: 'in_progress', bookingServiceName: 'Sửa hệ thống phanh', bookingUserName: 'Lê Văn C'),
  ];

  // --- AUTH METHODS ---
  Future<User> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    try {
      final user = _usersDB.firstWhere((u) => u.email == email);
      currentUser = user;
      return user;
    } catch (e) {
      throw Exception('Email hoặc mật khẩu không đúng');
    }
  }

  void logout() {
    currentUser = null;
  }

  Future<User> updateProfile({String? fullName, String? phone, String? address}) async {
    await Future.delayed(Duration(milliseconds: 500));
    if (currentUser == null) throw Exception("Unauthorized");
    if (fullName != null) currentUser!.fullName = fullName;
    if (phone != null) currentUser!.phone = phone;
    if (address != null) currentUser!.address = address;
    return currentUser!;
  }

  // --- SERVICE METHODS ---

  Future<List<Booking>> getBookings() async {
    await Future.delayed(Duration(milliseconds: 500));
    return bookings;
  }

  Future<void> updateBookingStatus(String id, String newStatus) async {
    await Future.delayed(Duration(milliseconds: 300));
    final index = bookings.indexWhere((b) => b.id == id);
    if(index != -1) bookings[index].status = newStatus;
  }

  // Lấy danh sách Service Bay (Tự động populate info nếu có booking)
  Future<List<ServiceBay>> getServiceBays() async {
    await Future.delayed(Duration(milliseconds: 500));
    for (var bay in serviceBays) {
      if (bay.currentBookingId != null) {
        try {
          final booking = bookings.firstWhere((b) => b.id == bay.currentBookingId);
          bay.bookingUserName = booking.userName;
          bay.bookingServiceName = booking.serviceName;
          bay.bookingUserPhone = booking.userPhone;
        } catch (e) {
          bay.currentBookingId = null;
          bay.status = 'available';
        }
      } else {
        // Clear info nếu bay trống
        bay.bookingUserName = null;
        bay.bookingServiceName = null;
        bay.bookingUserPhone = null;
      }
    }
    return serviceBays;
  }

  // Tạo khoang mới
  Future<void> createServiceBay(String bayNumber, String notes) async {
    await Future.delayed(Duration(milliseconds: 500));
    if (serviceBays.any((b) => b.bayNumber == bayNumber)) {
      throw Exception('Số hiệu khoang đã tồn tại!');
    }
    serviceBays.add(ServiceBay(id: DateTime.now().toString(), bayNumber: bayNumber, status: 'available', notes: notes));
  }

  // Update khoang
  Future<void> updateServiceBayInfo(String id, String notes, String status) async {
    await Future.delayed(Duration(milliseconds: 300));
    final index = serviceBays.indexWhere((b) => b.id == id);
    if (index == -1) throw Exception('Khoang không tồn tại');

    if (serviceBays[index].status == 'occupied' && status != 'occupied') {
      throw Exception('Không thể đổi trạng thái khi đang có xe! Phải trả xe trước.');
    }

    serviceBays[index].notes = notes;
    if (serviceBays[index].status != 'occupied') {
      serviceBays[index].status = status;
    }
  }

  // Xóa khoang
  Future<void> deleteServiceBay(String id) async {
    await Future.delayed(Duration(milliseconds: 500));
    final bay = serviceBays.firstWhere((b) => b.id == id);
    if (bay.status == 'occupied') throw Exception('Không thể xóa khu vực đang có xe');
    serviceBays.removeWhere((b) => b.id == id);
  }

  // Gán xe vào khoang
  Future<void> assignBookingToBay(String bayId, String bookingId) async {
    await Future.delayed(Duration(milliseconds: 800));

    final bayIndex = serviceBays.indexWhere((b) => b.id == bayId);
    final booking = bookings.firstWhere((b) => b.id == bookingId);

    // 1. Update Bay & Populate Info ngay lập tức
    serviceBays[bayIndex].status = 'occupied';
    serviceBays[bayIndex].currentBookingId = bookingId;
    serviceBays[bayIndex].bookingUserName = booking.userName;
    serviceBays[bayIndex].bookingServiceName = booking.serviceName;
    serviceBays[bayIndex].bookingUserPhone = booking.userPhone;

    // 2. Update Booking Status -> in_progress
    booking.status = 'in_progress';

    // 3. Create Repair Progress
    repairProgresses.add(RepairProgress(
      id: DateTime.now().toString(),
      bookingId: booking.id,
      staffId: currentUser!.id,
      staffName: currentUser!.fullName,
      status: 'in_progress',
      bookingServiceName: booking.serviceName,
      bookingUserName: booking.userName,
    ));
  }

  // Trả xe thủ công (Checkout)
  Future<void> checkoutBay(String bayId) async {
    await Future.delayed(Duration(milliseconds: 500));
    final index = serviceBays.indexWhere((b) => b.id == bayId);
    if (index == -1) throw Exception("Khoang không tồn tại");

    serviceBays[index].status = 'available';
    serviceBays[index].currentBookingId = null;
    serviceBays[index].bookingUserName = null;
    serviceBays[index].bookingServiceName = null;
    serviceBays[index].bookingUserPhone = null;
  }

  // --- REPAIR PROGRESS METHODS ---

  Future<List<RepairProgress>> getRepairProgress() async {
    await Future.delayed(Duration(milliseconds: 500));
    return repairProgresses;
  }

  // Cập nhật tiến độ Full logic
  Future<void> updateRepairProgressFull(String id, {String? status, String? notes, DateTime? estimatedCompletion, bool freeBay = false}) async {
    await Future.delayed(Duration(milliseconds: 500));

    final index = repairProgresses.indexWhere((p) => p.id == id);
    if (index == -1) throw Exception('Tiến độ không tồn tại');

    final progress = repairProgresses[index];
    if (progress.staffId != currentUser?.id) throw Exception('Không có quyền cập nhật');

    // Update info
    if (notes != null) progress.notes = notes;
    if (estimatedCompletion != null) progress.estimatedCompletion = estimatedCompletion;

    // Update status logic
    if (status != null) {
      progress.status = status;

      // Nếu hoàn thành -> Update Booking -> completed
      if (status == 'completed') {
        final bookingIndex = bookings.indexWhere((b) => b.id == progress.bookingId);
        if (bookingIndex != -1) {
          bookings[bookingIndex].status = 'completed';
        }

        // Xử lý khoang xe
        final bayIndex = serviceBays.indexWhere((b) => b.currentBookingId == progress.bookingId);
        if (bayIndex != -1) {
          if (freeBay) {
            // Khách lấy xe luôn -> Giải phóng
            serviceBays[bayIndex].status = 'available';
            serviceBays[bayIndex].currentBookingId = null;
            serviceBays[bayIndex].bookingUserName = null;
            serviceBays[bayIndex].bookingServiceName = null;
            serviceBays[bayIndex].bookingUserPhone = null;
          }
          // Nếu freeBay = false -> Khoang vẫn giữ Occupied, nhưng Booking đã Completed -> UI khoang sẽ hiện "Chờ giao xe"
        }
      }
    }
  }

  Future<void> deleteRepairProgress(String id) async {
    await Future.delayed(Duration(milliseconds: 500));
    final index = repairProgresses.indexWhere((p) => p.id == id);
    if (index == -1) throw Exception('Tiến độ không tồn tại');
    if (repairProgresses[index].staffId != currentUser?.id) throw Exception('Không có quyền xóa');
    repairProgresses.removeAt(index);
  }

  List<Contract> contracts = [
    Contract(
      id: 'ct1',
      contractNumber: 'HD-2023001',
      status: 'signed',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      customerSnapshot: CustomerSnapshot(fullName: 'Phạm Văn Khách', email: 'khach@gmail.com', phone: '0912345678', address: '123 Đường Láng'),
      orderSnapshot: OrderSnapshot(totalAmount: 15000000, paymentMethod: 'Chuyển khoản', orderDate: DateTime.now().subtract(Duration(days: 3))),
      itemsSnapshot: [
        ItemSnapshot(productName: 'Lốp Michelin', quantity: 4, price: 3500000),
        ItemSnapshot(productName: 'Dầu nhớt Castrol', quantity: 1, price: 1000000),
      ],
    ),
  ];

  // 2. Data Feedbacks
  List<FeedbackItem> feedbacks = [
    FeedbackItem(id: 'fb1', userName: 'User A', serviceName: 'Bảo dưỡng định kỳ', rating: 5, comment: 'Dịch vụ rất tốt, nhân viên nhiệt tình.', status: 'approved', createdAt: DateTime.now().subtract(Duration(days: 1))),
    FeedbackItem(id: 'fb2', userName: 'User B', productName: 'Gạt mưa Bosch', rating: 3, comment: 'Hàng ổn nhưng giao hơi chậm.', status: 'pending', createdAt: DateTime.now()),
  ];

  // 3. Data Support Requests
  List<SupportRequest> supportRequests = [
    SupportRequest(id: 'sr1', userName: 'User C', userEmail: 'c@gmail.com', message: 'Tôi muốn hỏi về chính sách bảo hành lốp xe?', status: 'pending', createdAt: DateTime.now().subtract(Duration(hours: 4))),
    SupportRequest(id: 'sr2', userName: 'User D', userEmail: 'd@gmail.com', message: 'Xe tôi sửa xong chưa?', status: 'resolved', reply: 'Xe của quý khách đã hoàn tất, mời quý khách qua nhận xe.', createdAt: DateTime.now().subtract(Duration(days: 1))),
  ];

  // --- SALE STAFF METHODS ---

  // A. Contract Methods
  Future<List<Contract>> getContracts() async {
    await Future.delayed(Duration(milliseconds: 500));
    return contracts;
  }

  // Tạo hợp đồng (Mô phỏng việc lấy info từ Order)
  Future<void> createContract(CustomerSnapshot cus, OrderSnapshot ord, List<ItemSnapshot> items) async {
    await Future.delayed(Duration(seconds: 1));
    final newContract = Contract(
      id: DateTime.now().toString(),
      contractNumber: 'HD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', // Fake số HD
      status: 'issued', // Mới tạo là issued
      createdAt: DateTime.now(),
      customerSnapshot: cus,
      orderSnapshot: ord,
      itemsSnapshot: items,
    );
    contracts.insert(0, newContract); // Thêm vào đầu danh sách
  }

  // Giả lập in PDF
  Future<String> printContract(String id) async {
    await Future.delayed(Duration(seconds: 2));
    // Trong thực tế trả về URL file PDF
    return "https://example.com/contracts/$id.pdf";
  }

  // B. Feedback Methods
  Future<List<FeedbackItem>> getFeedbacks() async {
    await Future.delayed(Duration(milliseconds: 500));
    return feedbacks;
  }

  Future<void> approveFeedback(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    final index = feedbacks.indexWhere((f) => f.id == id);
    if(index != -1) feedbacks[index].status = 'approved';
  }

  Future<void> deleteFeedback(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    feedbacks.removeWhere((f) => f.id == id);
  }

  // C. Support Methods
  Future<List<SupportRequest>> getSupportRequests() async {
    await Future.delayed(Duration(milliseconds: 500));
    return supportRequests;
  }

  Future<void> replySupport(String id, String replyMsg) async {
    await Future.delayed(Duration(seconds: 1));
    final index = supportRequests.indexWhere((s) => s.id == id);
    if(index != -1) {
      supportRequests[index].reply = replyMsg;
      supportRequests[index].status = 'resolved';
    }
  }

}