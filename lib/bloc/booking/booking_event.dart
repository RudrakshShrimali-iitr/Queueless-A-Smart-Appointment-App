import 'package:qless_app/models/booking.dart';

abstract class BookingEvent {}

class LoadBookings extends BookingEvent {
  final String merchantId;
  LoadBookings(this.merchantId);
}

class CreateBooking extends BookingEvent {
  final String merchantId;
  final String serviceId;
  final int serviceDuration; // Optional field for service duration
  final String serviceName;
  final String businessName;
  final String serviceType;
  final double price;
  final String customerId;
  final String customerName;
  final DateTime timeSlot;

  CreateBooking({
    required this.merchantId,
    required this.businessName,
    required this .serviceDuration, // Optional field for service duration
    required this.serviceId,
    required this.serviceName,
    required this.serviceType,
    required this.price,
    required this.customerId,
    required this.customerName,
    required this.timeSlot,
  });
}

class UpdateBookingStatus extends BookingEvent {
  final String merchantId;
  final String customerId;
  final String bookingId;
  final String status;
  UpdateBookingStatus({
    required this.merchantId,
    required this.customerId,
    required this.bookingId,
    required this.status,
  });
}

class LoadCustomerBookings extends BookingEvent {
  final String customerId;
  LoadCustomerBookings(this.customerId);
}
class ListenToCustomerBookingStatus extends BookingEvent {
  final String customerId;

  ListenToCustomerBookingStatus({required this.customerId});
}

class BookingStatusUpdated extends BookingEvent {
  final Booking booking;

  BookingStatusUpdated({required this.booking});
}
