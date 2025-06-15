// models/booking.dart
class Booking {
  final String id;
  final int? serviceDuration;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String merchantId;
  final String serviceName;
  final String serviceType;
  final double price;
  final DateTime bookingTime;
  final BookingStatus status;
  final String? customerProfileImage;

  Booking({
    required this.id,
    this.serviceDuration, // Optional field for service duration
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.merchantId,
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
    String? customerId,
    String? customerName,

    String? merchantId,
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
      customerId: customerId ?? this.customerId,
      customerPhone: customerPhone,
      customerName: customerName ?? this.customerName,
      merchantId: merchantId ?? this.merchantId,
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
      'customerPhone': customerPhone,
      'customerId': customerId,
      'customerName': customerName,
      'merchantId': merchantId,
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
      id: json['id'],
      serviceDuration: json['serviceDuration'] ,
      customerId: json['customerId'],
      customerPhone: json['customerPhone'] ?? '', // Optional field
      customerName: json['customerName'],
      merchantId: json['merchantId'],
      serviceName: json['serviceName'],
      serviceType: json['serviceType'],
      price: json['price'].toDouble(),
      bookingTime: DateTime.parse(json['bookingTime']),
      status: status,
      customerProfileImage: json['customerProfileImage'],
    );
  }
}

enum BookingStatus { pending, confirmed, completed, cancelled }
