import 'package:flutter/material.dart';
import 'package:qless_app/models/service.dart';

class BookingsPage extends StatefulWidget {
  final List<ServiceModel> upcomingBookings;
  final List<ServiceModel> bookings;

  const BookingsPage({
    Key? key,
    required this.upcomingBookings,
    required this.bookings,
  }) : super(key: key);

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: widget.upcomingBookings.isEmpty
            ? const Center(
                child: Text(
                  "No upcoming bookings.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: widget.upcomingBookings.length,
                itemBuilder: (context, index) {
                  final booking = widget.upcomingBookings[index];
                  return BookingCard(
                    serviceName: booking.serviceName,
                    salonName: booking.businessName,
                    bookingTime:
                        "Today, 2:30 PM", // Replace with actual time if available
                    queuePosition:
                        "#${index + 1} in line", // Dummy, replace with real position
                  );
                },
              ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final String serviceName;
  final String salonName;
  final String bookingTime;
  final String queuePosition;

  const BookingCard({
    Key? key,
    required this.serviceName,
    required this.salonName,
    required this.bookingTime,
    required this.queuePosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Booking',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            serviceName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            salonName,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Time: $bookingTime',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              queuePosition,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.qr_code),
                label: const Text("View QR"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF667eea),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.cancel),
                label: const Text("Cancel"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
