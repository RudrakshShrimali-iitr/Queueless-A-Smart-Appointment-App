// models/booking.dart
class Booking {
  final String id;
  final String customerId;
  final String customerName;
  final String merchantId;
  final String serviceName;
  final String serviceType;
  final double price;
  final DateTime bookingTime;
  final BookingStatus status;
  final String? customerProfileImage;

  Booking({
    required this.id,
    required this.customerId,
    required this.customerName,
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
      customerId: customerId ?? this.customerId,
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
    return Booking(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      merchantId: json['merchantId'],
      serviceName: json['serviceName'],
      serviceType: json['serviceType'],
      price: json['price'].toDouble(),
      bookingTime: DateTime.parse(json['bookingTime']),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      customerProfileImage: json['customerProfileImage'],
    );
  }
}

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}
