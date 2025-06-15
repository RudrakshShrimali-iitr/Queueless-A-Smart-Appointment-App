import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qless_app/models/booking.dart';
import 'package:qless_app/merchant%20side/booking%20components/booking_helper.dart';

// Queue status header
class QueueStatusHeader extends StatelessWidget {
  final int bookingsCount;
  final int totalWaitTime;

  const QueueStatusHeader({
    Key? key,
    required this.bookingsCount,
    required this.totalWaitTime,
  }) : super(key: key);

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Queue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$bookingsCount confirmed customers waiting',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                if (totalWaitTime > 0)
                  Text(
                    'Total queue time: ${_formatTotalTimeDisplay(totalWaitTime)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTotalTimeDisplay(int minutes) {
    if (minutes == 0) return '';
    if (minutes < 60) return '${minutes}min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return remaining == 0 ? '${hours}h' : '${hours}h ${remaining}min';
  }
}

// Queue tile
class QueueTile extends StatefulWidget {
  final Booking booking;
  final int position;
  final List<Booking> allConfirmedBookings;
  final Function(String, BookingStatus) onUpdateStatus;

  const QueueTile({
    Key? key,
    required this.booking,
    required this.position,
    required this.allConfirmedBookings,
    required this.onUpdateStatus,
  }) : super(key: key);

  @override
  State<QueueTile> createState() => _QueueTileState();
}

class _QueueTileState extends State<QueueTile> {
  String waitTime = 'Calculating...';
  String estimatedTime = '';

  @override
  void initState() {
    super.initState();
    _calculateWaitTime();
  }

  @override
  void didUpdateWidget(QueueTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position ||
        oldWidget.allConfirmedBookings.length !=
            widget.allConfirmedBookings.length) {
      _calculateWaitTime();
    }
  }

  void _calculateWaitTime() {
    int totalWaitMinutes = 0;

    // Calculate cumulative wait time based on service durations from RTDB
    for (int i = 0; i < widget.position; i++) {
      final booking = widget.allConfirmedBookings[i];
      // Use serviceDuration directly from booking object (as per your RTDB structure)
      totalWaitMinutes +=
          booking.serviceDuration ?? 30; // fallback to 30 minutes
    }

    final formatted = _formatWaitTime(totalWaitMinutes);
    final currentTime = DateTime.now();
    final estimatedStartTime = currentTime.add(
      Duration(minutes: totalWaitMinutes),
    );

    if (mounted) {
      setState(() {
        waitTime = widget.position == 0 ? 'Your turn!' : formatted;
        estimatedTime = widget.position == 0
            ? 'Now'
            : 'Est. ${_formatTime(estimatedStartTime)}';
      });
    }
  }

  String _formatWaitTime(int minutes) {
    if (minutes == 0) return 'Now';
    if (minutes < 60) return '${minutes}min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return remaining == 0 ? '${hours}h' : '${hours}h ${remaining}min';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final isNext = widget.position == 0;
    final serviceTime = widget.booking.serviceDuration ?? 30;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isNext ? 4 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isNext ? Border.all(color: Colors.green, width: 2) : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            backgroundColor: isNext
                ? Colors.green.withOpacity(0.2)
                : Colors.blue.withOpacity(0.2),
            child: Text(
              '${widget.position + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isNext ? Colors.green : Colors.blue,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  widget.booking.customerName,
                  style: TextStyle(
                    fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isNext)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.content_cut, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    widget.booking.serviceName,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${serviceTime}min',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Wait: $waitTime',
                    style: TextStyle(
                      color: isNext ? Colors.green[700] : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: isNext ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  if (estimatedTime.isNotEmpty && !isNext) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.schedule_outlined,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      estimatedTime,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: isNext
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => widget.onUpdateStatus(
                        widget.booking.id,
                        BookingStatus.completed,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Complete',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${widget.booking.price}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: const Text(
                        'Waiting',
                        style: TextStyle(fontSize: 10),
                      ),
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Queue Page
class QueuePage extends StatefulWidget {
  final List<Booking> allBookings;
  final Function(String, BookingStatus) onUpdateStatus;
  final String? merchantId; // Add merchant filter if needed

  const QueuePage({
    Key? key,
    required this.allBookings,
    required this.onUpdateStatus,
    this.merchantId,
  }) : super(key: key);

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  int _calculateTotalMinutes(List<Booking> bookings) {
    int totalMinutes = 0;
    for (final booking in bookings) {
      totalMinutes += booking.serviceDuration ?? 30;
    }
    return totalMinutes;
  }

  @override
  Widget build(BuildContext context) {
    // Filter confirmed bookings and sort by booking time
    List<Booking> confirmedBookings = widget.allBookings
        .where((b) => b.status == BookingStatus.confirmed)
        .toList();

    // Filter by merchant if specified
    if (widget.merchantId != null) {
      confirmedBookings = confirmedBookings
          .where((b) => b.merchantId == widget.merchantId)
          .toList();
    }

    // Sort by booking time
    confirmedBookings.sort((a, b) => a.bookingTime.compareTo(b.bookingTime));

    final totalQueueTime = _calculateTotalMinutes(confirmedBookings);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Management'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              QueueStatusHeader(
                bookingsCount: confirmedBookings.length,
                totalWaitTime: totalQueueTime,
              ),
              const SizedBox(height: 16),
              if (confirmedBookings.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.queue, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No confirmed bookings in queue',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Confirmed bookings will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: confirmedBookings.length,
                    itemBuilder: (context, index) => QueueTile(
                      booking: confirmedBookings[index],
                      position: index,
                      allConfirmedBookings: confirmedBookings,
                      onUpdateStatus: widget.onUpdateStatus,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
