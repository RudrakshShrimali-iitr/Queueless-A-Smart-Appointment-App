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
   required  String businessName,
    
    required String serviceName,
    required String serviceType,
    required double price,
    required String customerId,
    required String customerName,
    required DateTime timeSlot,
    String? customerProfileImage,
  }) async {
    final newBookingRef = _db.ref('merchants/$merchantId/bookings').push();

    final booking = Booking(
      id: newBookingRef.key!,
      customerId: customerId,
      serviceType: serviceType,
      customerName: customerName,
      merchantId: merchantId,
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

    String bookingId,
    String status,
  ) async {
    final updates = {'status': status.toString()};

    // Update in both merchant and customer nodes
    await Future.wait([
      _db.ref('merchants/$merchantId/bookings/$bookingId').update(updates),
      
    ]);
  }
}
