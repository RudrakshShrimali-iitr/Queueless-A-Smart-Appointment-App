import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qless_app/bloc/booking/booking_event.dart';
import 'package:qless_app/bloc/booking/booking_state.dart';
import 'package:qless_app/booking_repository.dart';
import '/models/booking.dart';
import '/services/booking_service.dart';


class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingService bookingService;
  final BookingRepository bookingRepository;

  StreamSubscription<Booking>? _statusSubscription;

  BookingBloc({
    required this.bookingService,
    required this.bookingRepository,
  }) : super(BookingInitial()) {
    on<LoadBookings>(_onLoadBookings);  
    on<CreateBooking>(_onCreateBooking);
    on<UpdateBookingStatus>(_onUpdateBookingStatus);
    on<LoadCustomerBookings>(_onLoadCustomerBookings);
    on<ListenToCustomerBookingStatus>(_onListenToCustomerBookingStatus);
    on<BookingStatusUpdated>(_onBookingStatusUpdated);
  }

  Future<void> _onLoadBookings(
    LoadBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final bookings = await bookingService.getBookingsByMerchant(event.merchantId);
      emit(BookingLoaded(bookings));
    } catch (e) {
      emit(BookingError('Failed to load bookings: $e'));
    }
  }

  Future<void> _onCreateBooking(
    CreateBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final createdBooking = await bookingService.createBooking(
        merchantId: event.merchantId,
        businessName: event.businessName,
        serviceName: event.serviceName,
        serviceDuration: event.serviceDuration,
        price: event.price,
        customerId: event.customerId,
        customerName: event.customerName,
        timeSlot: event.timeSlot,
        serviceType: event.serviceType,
        customerProfileImage: null, // Assuming this is optional
        // Assuming queue position is managed internally
      );
      emit(BookingCreated(createdBooking));

      final bookings = await bookingService.getBookingsByMerchant(event.merchantId);
      emit(BookingLoaded(bookings));
    } catch (e) {
      emit(BookingError('Failed to create booking: $e'));
    }
  }

  Future<void> _onUpdateBookingStatus(
    UpdateBookingStatus event,
    Emitter<BookingState> emit,
  ) async {
    try {
      await bookingService.updateBookingStatus(
        event.merchantId,
        event.customerId,
        event.bookingId,
        event.status,
      );

      if (state is BookingLoaded) {
        final bookings = await bookingService.getBookingsByMerchant(event.merchantId);
        emit(BookingLoaded(bookings));
      }
    } catch (e) {
      emit(BookingError('Failed to update status: $e'));
    }
  }

  Future<void> _onLoadCustomerBookings(
    LoadCustomerBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final bookings = await bookingService.getBookingsByCustomer(event.customerId);
      emit(BookingLoaded(bookings));
    } catch (e) {
      emit(BookingError('Failed to load customer bookings: $e'));
    }
  }

  Future<void> _onListenToCustomerBookingStatus(
    ListenToCustomerBookingStatus event,
    Emitter<BookingState> emit,
  ) async {
    await _statusSubscription?.cancel();
    _statusSubscription = bookingRepository
        .listenToCustomerBookingStatus(event.customerId)
        .listen((booking) {
      add(BookingStatusUpdated(booking: booking));
    });
  }

  Future<void> _onBookingStatusUpdated(
    BookingStatusUpdated event,
    Emitter<BookingState> emit,
  ) async {
    if (state is BookingLoaded) {
      final currentBookings = (state as BookingLoaded).bookings;
      final updatedList = currentBookings.map((b) {
        return b.id == event.booking.id ? event.booking : b;
      }).toList();
      emit(BookingLoaded(updatedList));
    }
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}
