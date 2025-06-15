import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/booking.dart';

class BookingService {
  final _db = FirebaseDatabase.instance;

  /// Fetch all bookings for a given merchant from RTDB.
  Future<List<Booking>> getBookingsByMerchant(String merchantId) async {
    final snap = await _db.ref('merchants/$merchantId/bookings').get();

    if (!snap.exists || snap.value == null) {
      return [];
    }

    final data = Map<String, dynamic>.from(snap.value as Map);
    return data.entries.map((e) {
      final json = Map<String, dynamic>.from(e.value);
      json['id'] = e.key; // Ensure ID is present
      return Booking.fromJson(json);
    }).toList();
  }

  /// Fetch all bookings for a given customer from RTDB.
  Future<List<Booking>> getBookingsByCustomer(String customerId) async {
    final snap = await _db.ref('customers/$customerId/bookings').get();

    if (!snap.exists || snap.value == null) {
      return [];
    }

    final data = Map<String, dynamic>.from(snap.value as Map);
    return data.entries.map((e) {
      final json = Map<String, dynamic>.from(e.value);
      json['id'] = e.key; // Ensure ID is present
      return Booking.fromJson(json);
    }).toList();
  }

  /// Create a new booking and save it under both merchant and customer nodes.
  Future<Booking> createBooking({
    required String merchantId,
    required String businessName,
     required int serviceDuration,
    required String serviceName,

    required double price,
    required String customerId,
    required String customerName,
    required DateTime timeSlot,
    required String serviceType,
    String? customerProfileImage,
  }) async {
    final newBookingRef = _db.ref('merchants/$merchantId/bookings').push();

    String customerPhone = '';
    String resolvedCustomerName = customerName;
    try {
      final customerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(customerId)
          .get();

      if (customerDoc.exists) {
        final data = customerDoc.data();
        customerPhone = data?['phone'] ?? '';

        if (resolvedCustomerName.toLowerCase() == 'guest' ||
            resolvedCustomerName.trim().isEmpty) {
          resolvedCustomerName = data?['name'] ?? 'Guest';
        }
      }
    } catch (e) {
      print('Failed to fetch customer phone: $e');
    }

    final booking = Booking(
      id: newBookingRef.key!,
      customerId: customerId,
      customerPhone: customerPhone, // Assuming phone is not provided here
      serviceType: serviceType,
      customerName: resolvedCustomerName,
      merchantId: merchantId,
      serviceDuration: serviceDuration,
      serviceName: serviceName,

      price: price,
      bookingTime: timeSlot,
      status: BookingStatus.pending,
      customerProfileImage: customerProfileImage,
    );

    final bookingData = booking.toJson();

    // Save under merchant
    await newBookingRef.set(bookingData);

    // Save under customer for lookup
    await _db
        .ref('customers/$customerId/bookings/${booking.id}')
        .set(bookingData);

    return booking;
  }

  /// Update booking status in both merchant and customer paths.
  Future<void> updateBookingStatus(
    String merchantId,
    String customerId,
    String bookingId,
    String status,
  ) async {
    final updates = {'status': status};

    final merchantPath = _db.ref('merchants/$merchantId/bookings/$bookingId');
    final customerPath = _db.ref('customers/$customerId/bookings/$bookingId');

    await Future.wait([
      merchantPath.update(updates),
      customerPath.update(updates),
    ]);
    // Update in both merchant and customer nodes
  }
}
