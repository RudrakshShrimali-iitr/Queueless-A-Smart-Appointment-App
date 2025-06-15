// models/booking.dart
class Booking {
  final String id;
  final int? serviceDuration;
  final int? queuePosition;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String merchantId;
  final String businessName;
  final String serviceName;
  final String serviceType;
  final double price;
  final DateTime bookingTime;
  final BookingStatus status;
  final String? customerProfileImage;

  Booking({
    required this.id,
    this.serviceDuration,
    this.queuePosition, // Optional field for service duration
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.merchantId,
    required this.businessName,
    required this.serviceName,
    required this.serviceType,
    required this.price,
    required this.bookingTime,
    required this.status,
    this.customerProfileImage,
  });

  Booking copyWith({
    String? id,
    int? serviceDuration,
    int? queuePosition,
    String? customerId,
    String? customerName,

    String? merchantId,
    String? businessName,

    String? serviceName,
    String? serviceType,
    double? price,
    DateTime? bookingTime,
    BookingStatus? status,
    String? customerProfileImage,
  }) {
    return Booking(
      id: id ?? this.id,
      serviceDuration: serviceDuration ?? this.serviceDuration,
      queuePosition: queuePosition ?? this.queuePosition,
      customerId: customerId ?? this.customerId,
      customerPhone: customerPhone,
      customerName: customerName ?? this.customerName,
      merchantId: merchantId ?? this.merchantId,
      businessName: businessName ?? this.businessName,
      serviceName: serviceName ?? this.serviceName,
      serviceType: serviceType ?? this.serviceType,
      price: price ?? this.price,
      bookingTime: bookingTime ?? this.bookingTime,
      status: status ?? this.status,
      customerProfileImage: customerProfileImage ?? this.customerProfileImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceDuration': serviceDuration,
      'queuePosition': queuePosition,
      'customerPhone': customerPhone,
      'customerId': customerId,
      'customerName': customerName,
      'merchantId': merchantId,
      'businessName': businessName,
      'serviceName': serviceName,
      'serviceType': serviceType,
      'price': price,
      'bookingTime': bookingTime.toIso8601String(),
      'status': status.toString(),
      'customerProfileImage': customerProfileImage,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    String rawStatus = json['status'] ?? 'pending';

    // Handle both "BookingStatus.pending" and "pending"
    if (rawStatus.contains('.')) {
      rawStatus = rawStatus.split('.').last;
    }

    // Fallback in case the value doesn't match any enum name
    final status = BookingStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == rawStatus.toLowerCase(),
      orElse: () => BookingStatus.pending,
    );
    return Booking(
      id: json['id'] ?? '',
      serviceDuration: json['serviceDuration'],
      queuePosition: json['queuePosition'] ?? 0,
      customerId: json['customerId'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerName: json['customerName'] ?? '',
      merchantId: json['merchantId'] ?? '',
      businessName: json['businessName'] ?? '',
      serviceName: json['serviceName'] ?? '',
      serviceType: (json['serviceType'] ?? '')
          .toString(), // ✅ This fixes the main error
      price: (json['price'] ?? 0).toDouble(),
      bookingTime: DateTime.parse(json['bookingTime']),
      status: status,
      customerProfileImage: json['customerProfileImage'] ?? '',
    );
  }
}

enum BookingStatus { pending, confirmed, completed, cancelled }
