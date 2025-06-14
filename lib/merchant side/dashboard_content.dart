import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qless_app/bloc/booking/booking_bloc.dart';
import 'package:qless_app/bloc/booking/booking_event.dart';
import 'package:qless_app/bloc/booking/booking_state.dart';
import 'package:qless_app/booking_repository.dart';
import 'package:qless_app/models/booking.dart';

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
    this.merchantId,
    this.bookings = const [],
    this.isBookingsPage = false,
    this.isQueuePage = false,
    required this.initialBookings,
  }) : super(key: key);

  const DashboardContent.bookingsPage({
    Key? key,
    required this.initialBookings,
    required this.bookings,
    this.merchantId,
  }) : businessName = null,
       isBookingsPage = true,
       isQueuePage = false,
       super(key: key);

  const DashboardContent.queuePage({
    Key? key,
    required this.initialBookings,
    required this.bookings,
    this.merchantId,
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
  late StreamSubscription<List<Booking>> _bookingsSubscription;
  late StreamSubscription<List<Booking>>? _newBookingSubscription;
  final _debouncer = _Debouncer(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _bookingRepository = BookingRepository();
    _bookingsNotifier = ValueNotifier(widget.initialBookings);
    _setupBookingListeners();
    if (widget.merchantId != null) {
      context.read<BookingBloc>().add(LoadBookings(widget.merchantId!));
    } else {
      debugPrint('Merchant ID is null – cannot load bookings.');
    }
    // Load initial data through BLoC
  }

  void _setupBookingListeners() {
    if (widget.merchantId != null) {
      _bookingsSubscription = _bookingRepository
          .listenToMerchantBookings(widget.merchantId!)
          .listen(_handleBookingsUpdate, onError: _handleError);

      _newBookingSubscription =
          _bookingRepository.listenToNewMerchantBookings(
                merchantId: widget.merchantId!,
                onNewBooking: _handleNewMerchantBooking,
                onError: _handleError,
              )
              as StreamSubscription<List<Booking>>?;
    } else {
      _bookingsSubscription = _bookingRepository
          .listenToBookings(merchantId: widget.merchantId)
          .listen(_handleBookingsUpdate);
    }
  }

  void _handleBookingsUpdate(List<Booking> bookings) {
    if (!mounted) return;
    _debouncer.run(() {
      _bookingsNotifier.value = bookings;
    });
  }

  void _handleNewMerchantBooking(DatabaseEvent event) {
    if (!mounted) return;

    final raw = event.snapshot.value;
    if (raw is Map) {
      try {
        final bookingData = Map<String, dynamic>.from(raw);
        bookingData['id'] = event.snapshot.key;
        final booking = Booking.fromJson(bookingData);
        _showNewBookingNotification(booking);
      } catch (e) {
        _handleError(e);
      }
    }
  }

  void _handleError(dynamic error) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${error.toString()}')));
    }
  }

  @override
  void dispose() {
    _bookingsSubscription.cancel();
    _newBookingSubscription?.cancel();
    _bookingsNotifier.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingError && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
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
      return _BookingsPageContent(
        bookings: bookings,
        merchantId: widget.merchantId,
        onUpdateStatus: _updateBookingStatus,
      );
    } else if (widget.isQueuePage) {
      return _QueuePageContent(
        bookings: bookings,
        merchantId: widget.merchantId,
        onUpdateStatus: _updateBookingStatus,
      );
    } else {
      return _DashboardContent(
        businessName: widget.businessName,
        bookings: bookings,
      );
    }
  }

  Future<void> _updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    if (widget.merchantId == null) return;

    try {
      await _bookingRepository.updateBookingStatus(
        merchantId: widget.merchantId!,
        bookingId: bookingId,
        status: status,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking marked ${status.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update booking status')),
        );
      }
    }
  }

  void _showNewBookingNotification(Booking booking) {
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
          onPressed: () => _showBookingDetails(context, booking),
        ),
      ),
    );
  }

  void _showBookingDetails(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${booking.customerName}'),
            Text('Service: ${booking.serviceName}'),
            Text('Time: ${_formatTime(booking.bookingTime)}'),
            Text('Price: \$${booking.price.toStringAsFixed(2)}'),
            Text('Status: ${_getStatusText(booking.status)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getStatusText(BookingStatus status) {
    return status.toString().split('.').last;
  }
}

// Optimized sub-components
class _DashboardContent extends StatelessWidget {
  final String? businessName;
  final List<Booking> bookings;

  const _DashboardContent({required this.businessName, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeCard(businessName: businessName),
          const SizedBox(height: 20),
          _RealTimeStatusCard(bookingsCount: bookings.length),
          const SizedBox(height: 20),
          const _SectionHeader('Upcoming Bookings', Icons.schedule),
          const SizedBox(height: 12),
          _BookingsList(bookings: bookings),
          const SizedBox(height: 20),
          const _SectionHeader('Quick Actions', Icons.flash_on),
          const SizedBox(height: 12),
          const _QuickActionsRow(),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String? businessName;

  const _WelcomeCard({this.businessName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s what\'s happening at ${businessName ?? "your business"} today',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _RealTimeStatusCard extends StatelessWidget {
  final int bookingsCount;

  const _RealTimeStatusCard({required this.bookingsCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Live Updates Active',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const Spacer(),
          Text(
            '$bookingsCount active bookings',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final List<Booking> bookings;

  const _BookingsList({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const _EmptyStateCard(
        icon: Icons.calendar_today,
        title: 'No bookings yet',
        description: 'Your upcoming bookings will appear here',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _BookingTile(booking: bookings[index]);
        },
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final Booking booking;

  const _BookingTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(booking.status).withOpacity(0.2),
        child: Icon(Icons.person, color: _getStatusColor(booking.status)),
      ),
      title: Text(booking.customerName),
      subtitle: Text(
        '${booking.serviceName} • ${_formatTime(booking.bookingTime)}',
      ),
      trailing: Chip(
        label: Text(
          _getStatusText(booking.status),
          style: const TextStyle(fontSize: 12),
        ),
        backgroundColor: _getStatusColor(booking.status).withOpacity(0.2),
      ),
      onTap: () => _showBookingDetails(context, booking),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(BookingStatus status) {
    return status.toString().split('.').last;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _showBookingDetails(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${booking.customerName}'),
            Text('Service: ${booking.serviceName}'),
            Text('Time: ${_formatTime(booking.bookingTime)}'),
            Text('Price: \$${booking.price.toStringAsFixed(2)}'),
            Text('Status: ${_getStatusText(booking.status)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            'Add Service',
            Icons.add_business,
            Colors.blue,
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navigate to Add Service page')),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            'View Analytics',
            Icons.analytics,
            Colors.green,
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navigate to Analytics page')),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(this.title, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1E88E5)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _BookingsPageContent extends StatelessWidget {
  final List<Booking> bookings;
  final String? merchantId;
  final Function(String, BookingStatus) onUpdateStatus;

  const _BookingsPageContent({
    required this.bookings,
    this.merchantId,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const _FilterTabs(),
          const SizedBox(height: 16),
          Expanded(
            child: bookings.isEmpty
                ? const _EmptyStateCard(
                    icon: Icons.calendar_today,
                    title: 'No bookings found',
                    description: 'Your bookings will appear here',
                  )
                : ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return _DetailedBookingCard(
                        booking: bookings[index],
                        onUpdateStatus: onUpdateStatus,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _FilterTab('Today', true)),
          Expanded(child: _FilterTab('Upcoming', false)),
          Expanded(child: _FilterTab('Past', false)),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String title;
  final bool isSelected;

  const _FilterTab(this.title, this.isSelected);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _DetailedBookingCard extends StatelessWidget {
  final Booking booking;
  final Function(String, BookingStatus) onUpdateStatus;

  const _DetailedBookingCard({
    required this.booking,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.customerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(_getStatusText(booking.status)),
                  backgroundColor: _getStatusColor(
                    booking.status,
                  ).withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.room_service, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(booking.serviceName),
                const Spacer(),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(_formatTime(booking.bookingTime)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                Text('\$${booking.price.toStringAsFixed(2)}'),
                const Spacer(),
                if (booking.status == BookingStatus.pending) ...[
                  ElevatedButton(
                    onPressed: () =>
                        onUpdateStatus(booking.id, BookingStatus.confirmed),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () =>
                        onUpdateStatus(booking.id, BookingStatus.cancelled),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Decline'),
                  ),
                ] else ...[
                  TextButton(
                    onPressed: () => _editBooking(context, booking),
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: () => _cancelBooking(context, booking),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(BookingStatus status) {
    return status.toString().split('.').last;
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _editBooking(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: BookingStatus.values.map((status) {
            return RadioListTile<BookingStatus>(
              title: Text(_getStatusText(status)),
              value: status,
              groupValue: booking.status,
              onChanged: (BookingStatus? value) {
                if (value != null) {
                  onUpdateStatus(booking.id, value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _cancelBooking(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Cancel booking for ${booking.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              onUpdateStatus(booking.id, BookingStatus.cancelled);
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

class _QueuePageContent extends StatelessWidget {
  final List<Booking> bookings;
  final String? merchantId;
  final Function(String, BookingStatus) onUpdateStatus;

  const _QueuePageContent({
    required this.bookings,
    this.merchantId,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _QueueStatusHeader(bookingsCount: bookings.length),
          const SizedBox(height: 16),
          Expanded(
            child: bookings.isEmpty
                ? const _EmptyStateCard(
                    icon: Icons.people_alt_outlined,
                    title: 'No customers in queue',
                    description:
                        'Your queue will appear here when customers book',
                  )
                : ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return _QueueTile(
                        booking: bookings[index],
                        position: index,
                        onUpdateStatus: onUpdateStatus,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _QueueStatusHeader extends StatelessWidget {
  final int bookingsCount;

  const _QueueStatusHeader({required this.bookingsCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.queue, color: Color(0xFF1E88E5), size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Queue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '$bookingsCount customers waiting',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  final Booking booking;
  final int position;
  final Function(String, BookingStatus) onUpdateStatus;

  const _QueueTile({
    required this.booking,
    required this.position,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isNext = position == 0;
    final waitTime = _calculateWaitTime(position);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isNext
              ? Colors.green.withOpacity(0.2)
              : Colors.blue.withOpacity(0.2),
          child: Text(
            '${position + 1}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isNext ? Colors.green : Colors.blue,
            ),
          ),
        ),
        title: Text(booking.customerName),
        subtitle: Text('${booking.serviceName} • Wait: $waitTime'),
        trailing: isNext
            ? ElevatedButton(
                onPressed: () =>
                    onUpdateStatus(booking.id, BookingStatus.completed),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Check In'),
              )
            : Chip(
                label: Text(isNext ? 'Next' : 'Waiting'),
                backgroundColor: Colors.blue.withOpacity(0.2),
              ),
      ),
    );
  }

  String _calculateWaitTime(int position) {
    final minutes = position * 15;
    return minutes > 60
        ? '${(minutes / 60).toStringAsFixed(0)}h ${minutes % 60}min'
        : '${minutes}min';
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(description, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}

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
