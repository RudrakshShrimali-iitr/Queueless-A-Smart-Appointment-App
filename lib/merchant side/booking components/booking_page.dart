import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qless_app/merchant side/booking components/booking_components.dart'
    as booking_components;
import 'package:qless_app/models/booking.dart';
import 'detailed_booking_card.dart';
import 'queue_page.dart';

/// Bookings Page Content with RTDB Stream
class BookingsPageContent extends StatelessWidget {
  final String? merchantId;
  final Function(String, BookingStatus) onUpdateStatus;

  const BookingsPageContent({
    Key? key,
    required this.merchantId,
    required this.onUpdateStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookingsRef = FirebaseDatabase.instance.ref(
      'merchants/$merchantId/bookings',
    );

    return StreamBuilder<DatabaseEvent>(
      stream: bookingsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading bookings: ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final ds = snapshot.data!.snapshot;
        if (!ds.exists || ds.value == null) {
          return const Center(
            child: booking_components.EmptyStateCard(
              icon: Icons.calendar_today,
              title: 'No bookings found',
              description: 'Your bookings will appear here',
            ),
          );
        }

        final raw = Map<String, dynamic>.from(ds.value as Map);
        final bookings = raw.entries.map((e) {
          final json = Map<String, dynamic>.from(e.value);
          json['id'] = e.key;
          return Booking.fromJson(json);
        }).toList()
          ..sort((a, b) => b.bookingTime.compareTo(a.bookingTime));

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const booking_components.FilterTabs(),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    return DetailedBookingCard(booking: bookings[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Mobile-Optimized Queue Page Content with RTDB Stream
class QueuePageContent extends StatefulWidget {
  final String? merchantId;
  final Function(String, BookingStatus) onUpdateStatus;

  const QueuePageContent({
    Key? key,
    required this.merchantId,
    required this.onUpdateStatus,
  }) : super(key: key);

  @override
  State<QueuePageContent> createState() => _QueuePageContentState();
}

class _QueuePageContentState extends State<QueuePageContent>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  // Cache for wait time calculations to avoid recalculating on every build
  final Map<String, String> _waitTimeCache = {};
  final Map<String, String> _estimatedTimeCache = {};

  void _updateWaitTimeCache(List<Booking> queueBookings) {
    _waitTimeCache.clear();
    _estimatedTimeCache.clear();
    
    final currentTime = DateTime.now();
    int cumulativeWaitMinutes = 0;
    
    for (int i = 0; i < queueBookings.length; i++) {
      final booking = queueBookings[i];
      
      if (i == 0) {
        _waitTimeCache[booking.id] = 'Your turn!';
        _estimatedTimeCache[booking.id] = 'Now';
      } else {
        _waitTimeCache[booking.id] = _formatWaitTime(cumulativeWaitMinutes);
        final estimatedStartTime = currentTime.add(Duration(minutes: cumulativeWaitMinutes));
        _estimatedTimeCache[booking.id] = 'Est. ${_formatTime(estimatedStartTime)}';
      }
      
      cumulativeWaitMinutes += booking.serviceDuration ?? 30;
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
    super.build(context);
    
    final bookingsRef = FirebaseDatabase.instance.ref(
      'merchants/${widget.merchantId}/bookings',
    );

    return StreamBuilder<DatabaseEvent>(
      stream: bookingsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorScaffold('Error loading queue: ${snapshot.error}');
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScaffold();
        }

        final ds = snapshot.data!.snapshot;
        if (!ds.exists || ds.value == null) {
          return _buildEmptyScaffold();
        }

        final raw = Map<String, dynamic>.from(ds.value as Map);
        final allBookings = raw.entries.map((e) {
          final json = Map<String, dynamic>.from(e.value);
          json['id'] = e.key;
          return Booking.fromJson(json);
        }).toList();

        // Filter and sort queue bookings
        final queueBookings = allBookings
            .where((b) => b.status == BookingStatus.confirmed)
            .toList()
          ..sort((a, b) => a.bookingTime.compareTo(b.bookingTime));

        if (queueBookings.isEmpty) {
          return _buildEmptyScaffold();
        }

        // Update wait time cache
        _updateWaitTimeCache(queueBookings);

        // Calculate total wait time
        final int totalWaitTime = queueBookings.fold<int>(
          0,
          (sum, booking) => sum + (booking.serviceDuration ?? 30),
        );

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
            child: Column(
              children: [
                // Fixed header - no padding issues on mobile
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: QueueStatusHeader(
                    bookingsCount: queueBookings.length,
                    totalWaitTime: totalWaitTime,
                  ),
                ),
                
                // Scrollable queue list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: queueBookings.length,
                    itemBuilder: (context, index) {
                      return _buildMobileQueueTile(
                        queueBookings[index],
                        index,
                        queueBookings,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileQueueTile(Booking booking, int position, List<Booking> allBookings) {
    final isNext = position == 0;
    final serviceTime = booking.serviceDuration ?? 30;
    final waitTime = _waitTimeCache[booking.id] ?? 'Calculating...';
    final estimatedTime = _estimatedTimeCache[booking.id] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: isNext ? 6 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isNext ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with position and next indicator
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isNext
                        ? Colors.green.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.2),
                    child: Text(
                      '${position + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isNext ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      booking.customerName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isNext)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'NEXT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Service info row
              Row(
                children: [
                  Icon(Icons.content_cut, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.serviceName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '${serviceTime}min',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Wait time and estimated time row
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Wait: $waitTime',
                    style: TextStyle(
                      color: isNext ? Colors.green[700] : Colors.grey[600],
                      fontSize: 14,
                      fontWeight: isNext ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (estimatedTime.isNotEmpty && !isNext) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.schedule_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      estimatedTime,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Bottom row with price and action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${booking.price}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (isNext)
                    ElevatedButton(
                      onPressed: () => widget.onUpdateStatus(
                        booking.id,
                        BookingStatus.completed,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Complete',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Waiting',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Management'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Management'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Center(child: Text(error)),
      ),
    );
  }

  Widget _buildEmptyScaffold() {
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
      ),
    );
  }
}