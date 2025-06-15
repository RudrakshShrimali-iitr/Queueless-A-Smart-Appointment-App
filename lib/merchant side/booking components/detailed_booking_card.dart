import 'dart:async';
import 'dart:convert';
// import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qless_app/bloc/booking/booking_bloc.dart';
import 'package:qless_app/bloc/booking/booking_event.dart';
import 'package:qless_app/merchant%20side/booking%20components/booking_helper.dart';
import 'package:qless_app/models/booking.dart';

class DetailedBookingCard extends StatefulWidget {
  final Booking booking;

  const DetailedBookingCard({Key? key, required this.booking})
    : super(key: key);

  @override
  State<DetailedBookingCard> createState() => _DetailedBookingCardState();
}

class _DetailedBookingCardState extends State<DetailedBookingCard> {
  bool _isProcessing = false;
  late BookingStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.booking.status;
  }

  @override
  void didUpdateWidget(DetailedBookingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.booking.status != widget.booking.status) {
      _currentStatus = widget.booking.status;
    }
  }

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
                  widget.booking.customerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(BookingHelpers.getStatusText(_currentStatus)),
                  backgroundColor: BookingHelpers.getStatusColor(
                    _currentStatus,
                  ).withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.room_service, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(child: Text(widget.booking.serviceName)),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(BookingHelpers.formatTime(widget.booking.bookingTime)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                Text('\$${widget.booking.price.toStringAsFixed(2)}'),
                const Spacer(),
                Flexible(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _buildActionButtons(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    if (_currentStatus == BookingStatus.pending) {
      return [
        ElevatedButton(
          onPressed: _isProcessing ? null : _acceptBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Accept'),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _isProcessing ? null : _declineBooking,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Decline'),
        ),
      ];
    } else if (_currentStatus == BookingStatus.confirmed) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                'Accepted',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => _editBooking(context),
          child: const Text('Edit'),
        ),
        TextButton(
          onPressed: () => _cancelBooking(context),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Cancel'),
        ),
      ];
    } else {
      return [
        TextButton(
          onPressed: () => _editBooking(context),
          child: const Text('Edit'),
        ),
        TextButton(
          onPressed: () => _cancelBooking(context),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Cancel'),
        ),
      ];
    }
  }

  Future<void> _acceptBooking() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      _updateStatus(BookingStatus.confirmed);
      setState(() {
        _currentStatus = BookingStatus.confirmed;
      });

      await _sendSMSToCustomer();
      _showSuccessMessage();
    } catch (e) {
      setState(() {
        _currentStatus = BookingStatus.pending;
      });
      _showErrorMessage('Failed to accept booking. Please try again.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _updateStatus(BookingStatus status) {
    context.read<BookingBloc>().add(
      UpdateBookingStatus(
        bookingId: widget.booking.id,
        merchantId: widget.booking.merchantId,
        customerId: widget.booking.customerId,
        status: status.name,
      ),
    );
  }

  Future<void> _declineBooking() async {
    final declined =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Decline Booking'),
            content: Text(
              'Decline booking for ${widget.booking.customerName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Decline'),
              ),
            ],
          ),
        ) ??
        false;

    if (declined) {
      _updateStatus(BookingStatus.cancelled);
      setState(() {
        _currentStatus = BookingStatus.cancelled;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking declined. ${widget.booking.customerName} has been notified.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _editBooking(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: BookingStatus.values.map((status) {
            return RadioListTile<BookingStatus>(
              title: Text(BookingHelpers.getStatusText(status)),
              value: status,
              groupValue: _currentStatus,
              onChanged: (BookingStatus? value) {
                if (value != null) {
                  _updateStatus(value);
                  setState(() {
                    _currentStatus = value;
                  });
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _cancelBooking(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Cancel booking for ${widget.booking.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              _updateStatus(BookingStatus.cancelled);
              setState(() {
                _currentStatus = BookingStatus.cancelled;
              });
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSMSToCustomer() async {
    final smsMessage =
        '''
Hello ${widget.booking.customerName}! 

Your booking is CONFIRMED ✅

Service: ${widget.booking.serviceName}
Date: ${_formatDate(widget.booking.bookingTime)}
Time: ${BookingHelpers.formatTime(widget.booking.bookingTime)}
Amount: \$${widget.booking.price.toStringAsFixed(2)}

We look forward to serving you!

- Qless Team
''';

    await _sendSMSViaAPI(widget.booking.customerPhone, smsMessage);
  }

  Future<void> _sendSMSViaAPI(String phoneNumber, String message) async {
    await Future.delayed(const Duration(seconds: 1));
    print('SMS would be sent to: $phoneNumber');
    print('Message: $message');
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Booking confirmed! SMS sent to ${widget.booking.customerName}.',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            BookingHelpers.showBookingDetails(context, widget.booking);
          },
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
