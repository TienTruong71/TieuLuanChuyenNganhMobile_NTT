// User Model - Khớp với response của Auth Controller & Profile Controller
class User {
  String id;
  String username;
  String email;
  String fullName; // API: full_name
  String phone;
  String address;
  String roleName; // API: role_id.role_name
  String status;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.roleName,
    this.status = 'active',
  });
}

// Booking Model
class Booking {
  String id;
  String userId;
  String userName;
  String userPhone; // Thêm phone để hiển thị chi tiết
  String serviceName;
  DateTime bookingDate;
  String status;

  Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.serviceName,
    required this.bookingDate,
    required this.status,
  });
}

// ServiceBay Model
class ServiceBay {
  String id;
  String bayNumber;
  String status;
  String? currentBookingId;
  String notes;

  String? bookingUserName;
  String? bookingServiceName;
  String? bookingUserPhone;

  ServiceBay({
    required this.id,
    required this.bayNumber,
    required this.status,
    this.currentBookingId,
    this.notes = '',
    this.bookingUserName,
    this.bookingServiceName,
    this.bookingUserPhone,
  });
}

// RepairProgress Model
class RepairProgress {
  String id;
  String bookingId;
  String staffId;
  String staffName;
  String status;
  String notes;
  DateTime? estimatedCompletion; // API: estimated_completion

  // Trường bổ sung để hiển thị UI (do API dùng populate)
  String bookingServiceName;
  String bookingUserName;

  RepairProgress({
    required this.id,
    required this.bookingId,
    required this.staffId,
    required this.staffName,
    required this.status,
    this.notes = '',
    this.estimatedCompletion,
    required this.bookingServiceName,
    required this.bookingUserName,
  });
}

// 1. Contract Model
class Contract {
  String id;
  String contractNumber;
  String status; // draft, issued, signed, cancelled
  String generatedFileUrl; // Mock URL PDF
  DateTime createdAt;

  // Snapshots (Dữ liệu lưu cứng tại thời điểm tạo)
  CustomerSnapshot customerSnapshot;
  OrderSnapshot orderSnapshot;
  List<ItemSnapshot> itemsSnapshot;

  Contract({
    required this.id,
    required this.contractNumber,
    required this.status,
    this.generatedFileUrl = '',
    required this.createdAt,
    required this.customerSnapshot,
    required this.orderSnapshot,
    required this.itemsSnapshot,
  });
}

class CustomerSnapshot {
  String fullName;
  String email;
  String phone;
  String address;

  CustomerSnapshot({required this.fullName, required this.email, required this.phone, required this.address});
}

class OrderSnapshot {
  double totalAmount;
  String paymentMethod;
  DateTime orderDate;

  OrderSnapshot({required this.totalAmount, required this.paymentMethod, required this.orderDate});
}

class ItemSnapshot {
  String productName;
  int quantity;
  double price;

  ItemSnapshot({required this.productName, required this.quantity, required this.price});
}

// 2. Feedback Model
class FeedbackItem {
  String id;
  String userName; // Populate từ user_id
  String? productName; // Populate từ product_id
  String? serviceName; // Populate từ service_id
  int rating;
  String comment;
  String status; // pending, approved, rejected
  DateTime createdAt;

  FeedbackItem({
    required this.id,
    required this.userName,
    this.productName,
    this.serviceName,
    required this.rating,
    required this.comment,
    required this.status,
    required this.createdAt,
  });
}

// 3. Support Request Model
class SupportRequest {
  String id;
  String userName; // Populate từ user
  String userEmail; // Populate từ user
  String message;
  String reply; // Câu trả lời của Staff
  String status; // pending, in_progress, resolved
  DateTime createdAt;

  SupportRequest({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.message,
    this.reply = '',
    required this.status,
    required this.createdAt,
  });
}