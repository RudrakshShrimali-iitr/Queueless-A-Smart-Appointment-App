import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qless_app/bloc/booking/booking_bloc.dart';
import 'package:qless_app/bloc/booking/booking_event.dart';
import 'package:qless_app/bloc/booking/booking_state.dart';
import 'package:qless_app/booking_repository.dart';
import 'package:qless_app/merchant%20side/booking%20components/booking_helper.dart';
import 'package:qless_app/merchant%20side/booking%20components/booking_page.dart';
import 'package:qless_app/merchant%20side/dashboard_widget.dart';
import 'package:qless_app/models/booking.dart';

import 'package:qless_app/merchant%20side/booking%20components/queue_page.dart';

class DashboardContent extends StatefulWidget {
  final String? businessName;
  final String? merchantId;
  final List<Booking> bookings;
  final bool isBookingsPage;
  final bool isQueuePage;
  final List<Booking> initialBookings;

  const DashboardContent({
    Key? key,
    this.businessName,
    required this.merchantId, // Make merchantId required
    this.bookings = const [],
    this.isBookingsPage = false,
    this.isQueuePage = false,
    required this.initialBookings,
  }) : super(key: key);

  const DashboardContent.bookingsPage({
    Key? key,
    required this.initialBookings,
    required this.bookings,
    required this.merchantId, // Make merchantId required
  }) : businessName = null,
       isBookingsPage = true,
       isQueuePage = false,
       super(key: key);

  const DashboardContent.queuePage({
    Key? key,
    required this.initialBookings,
    required this.bookings,
    required this.merchantId, // Make merchantId required
  }) : businessName = null,
       isBookingsPage = false,
       isQueuePage = true,
       super(key: key);

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late final BookingRepository _bookingRepository;
  late final ValueNotifier<List<Booking>> _bookingsNotifier;
  StreamSubscription<List<Booking>>? _bookingsSubscription;
  StreamSubscription<DatabaseEvent>? _newBookingSubscription;
  final _debouncer = _Debouncer(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _bookingRepository = BookingRepository();
    _bookingsNotifier = ValueNotifier(widget.initialBookings);

    // Only setup listeners if merchantId is not null
    if (widget.merchantId != null && widget.merchantId!.isNotEmpty) {
      _setupBookingListeners();
      context.read<BookingBloc>().add(LoadBookings(widget.merchantId!));
    } else {
      debugPrint('❌ Merchant ID is null or empty – cannot load bookings.');
    }
  }

  void _setupBookingListeners() {
    if (widget.merchantId == null || widget.merchantId!.isEmpty) {
      debugPrint(
        '❌ Cannot setup booking listeners: merchantId is null or empty',
      );
      return;
    }

    debugPrint(
      '✅ Setting up booking listeners for merchantId: ${widget.merchantId}',
    );

    try {
      // 1️⃣ Listen to the full list of bookings onValue
      _bookingsSubscription = _bookingRepository
          .listenToMerchantBookings(widget.merchantId!)
          .listen(
            _handleBookingsUpdate,
            onError: _handleError,
            onDone: () => debugPrint('📡 Bookings stream closed'),
          );

      // 2️⃣ Listen for NEW bookings v  ia onChildAdded
      _newBookingSubscription = _bookingRepository.listenToNewMerchantBookings(
        merchantId: widget.merchantId!,
        onNewBooking: _handleNewMerchantBooking,
        onError: _handleError,
      );
      // Note: no extra `.listen(...)` here — the repository already attaches your callback.
    } catch (e) {
      debugPrint('❌ Error setting up booking listeners: $e');
      _handleError(e);
    }
  }

  void _handleBookingsUpdate(List<Booking> bookings) {
    if (!mounted) return;

    debugPrint('📊 Bookings updated: ${bookings.length} bookings');
    _debouncer.run(() {
      if (mounted) {
        _bookingsNotifier.value = bookings;
      }
    });
  }

  void _handleNewMerchantBooking(DatabaseEvent event) {
    if (!mounted) return;

    final raw = event.snapshot.value;
    if (raw is Map) {
      try {
        final bookingData = Map<String, dynamic>.from(raw);
        bookingData['id'] = event.snapshot.key;

        // ✅ Debug log
        debugPrint('📦 Incoming bookingData: $bookingData');

        final booking = Booking.fromJson(bookingData);
        debugPrint('🔔 New booking notification: ${booking.customerName}');
        _showNewBookingNotification(booking);
      } catch (e, stack) {
        debugPrint('❌ Error parsing new booking: $e');
        debugPrintStack(stackTrace: stack); // 👈 print full error
        _handleError(e);
      }
    }
  }

  void _handleError(dynamic error) {
    debugPrint('❌ Booking error: $error');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking Error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    _newBookingSubscription?.cancel();
    _bookingsNotifier.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show error if merchantId is missing for booking/queue pages
    if ((widget.isBookingsPage || widget.isQueuePage) &&
        (widget.merchantId == null || widget.merchantId!.isEmpty)) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Merchant ID is missing',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            SizedBox(height: 8),
            Text(
              'Cannot load bookings without merchant ID',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingError && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: ValueListenableBuilder<List<Booking>>(
        valueListenable: _bookingsNotifier,
        builder: (context, bookings, _) {
          return _buildContent(bookings);
        },
      ),
    );
  }

  Widget _buildContent(List<Booking> bookings) {
    if (widget.isBookingsPage) {
      return BookingsPageContent(
        merchantId: widget.merchantId,
        onUpdateStatus: _updateBookingStatus,
      );
    } else if (widget.isQueuePage) {
      return QueuePageContent(
        merchantId: widget.merchantId,
        onUpdateStatus: _updateBookingStatus,
      );
    } else {
      return DashboardHomeContent(
        businessName: widget.businessName,
        bookings: bookings,
      );
    }
  }

  Future<void> _updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    if (widget.merchantId == null || widget.merchantId!.isEmpty) {
      debugPrint('❌ Cannot update booking status: merchantId is null or empty');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot update booking: Merchant ID missing'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      debugPrint('🔄 Updating booking $bookingId to status: ${status.name}');

      await _bookingRepository.updateBookingStatus(
        merchantId: widget.merchantId!,
        bookingId: bookingId,
        status: status,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking marked ${status.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }

      debugPrint('✅ Booking status updated successfully');
    } catch (e) {
      debugPrint('❌ Failed to update booking status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update booking status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNewBookingNotification(Booking booking) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('New booking from ${booking.customerName}')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => BookingHelpers.showBookingDetails(context, booking),
        ),
      ),
    );
  }
}

String formatTime(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

// Utility classes
class _Debouncer {
  final int milliseconds;
  Timer? _timer;

  _Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
