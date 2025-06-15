import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import '../models/booking.dart';

class BookingRepository {
  final DatabaseReference _baseRef = FirebaseDatabase.instance.ref('merchants');

  /// Stream of all bookings for one merchant.
  Stream<List<Booking>> listenToMerchantBookings(String merchantId) {
    final ref = _baseRef.child('$merchantId/bookings');
    return ref.onValue.map((event) {
      final raw = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return raw.entries.map((e) {
        return Booking.fromJson(
          Map<String, dynamic>.from(e.value as Map)..['id'] = e.key,
        );
      }).toList();
    });
  }

  /// Listen to all bookings — accepts callbacks directly
  Stream<List<Booking>> listenToBookings({String? merchantId}) {
    final ref = _baseRef;

    return ref.onValue.map((event) {
      final merchantData = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final List<Booking> allBookings = [];

      merchantData.forEach((merchantKey, merchantValue) {
        if (merchantValue is Map) {
          final bookingsMap =
              merchantValue['bookings'] as Map<dynamic, dynamic>? ?? {};
          bookingsMap.forEach((bookingId, bookingData) {
            if (bookingData is Map) {
              try {
                final booking = Booking.fromJson(
                  Map<String, dynamic>.from(bookingData)..['id'] = bookingId,
                );
                if (merchantId == null || merchantId == merchantKey) {
                  allBookings.add(booking);
                }
              } catch (_) {}
            }
          });
        }
      });

      return allBookings;
    });
  }

  /// Listen to new bookings for a specific merchant
  StreamSubscription<DatabaseEvent>? listenToNewMerchantBookings({
    required String merchantId,
    required void Function(DatabaseEvent) onNewBooking,
    void Function(Object)? onError,
  }) {
    final ref = _baseRef.child('$merchantId/bookings');
    return ref.onChildAdded.listen(onNewBooking, onError: onError);
  }

  /// Update a booking's status.
  Future<void> updateBookingStatus({
    required String merchantId,
    required String bookingId,
    required BookingStatus status,
  }) async {
    final ref = _baseRef.child('$merchantId/bookings/$bookingId/status');
    await ref.set(status.name);
  }
}
