import 'package:flutter/material.dart';
import 'package:qless_app/models/booking.dart';
// Ensure this model exists

class BookingsPage extends StatefulWidget {
  final List<Booking> bookings;

  const BookingsPage({Key? key, required this.bookings}) : super(key: key);

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  Widget build(BuildContext context) {
    final confirmed = widget.bookings
        .where((b) => b.status == 'confirmed')
        .toList();
    final pending = widget.bookings
        .where((b) => b.status == 'pending')
        .toList();
    final completed = widget.bookings
        .where((b) => b.status == 'completed')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: widget.bookings.isEmpty
          ? const Center(child: Text("No bookings yet."))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (confirmed.isNotEmpty) _buildSection("Confirmed", confirmed),
                if (pending.isNotEmpty) _buildSection("Pending", pending),
                if (completed.isNotEmpty) _buildSection("Completed", completed),
              ],
            ),
    );
  }

  Widget _buildSection(String title, List<Booking> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title Bookings",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (b) => BookingCard(
            type: title,
            serviceName: b.serviceName,
            salonName: b.businessName,
            bookingTime: b.bookingTime.toString(),
            queuePosition: "#${b.queuePosition?.toString() ?? 'N/A'} in line",
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class BookingCard extends StatelessWidget {
  final String type; // Confirmed / Pending / Completed
  final String serviceName;
  final String salonName;
  final String bookingTime;
  final String queuePosition;

  const BookingCard({
    Key? key,
    required this.type,
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
            '$type Booking',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            serviceName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            salonName,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Time: $bookingTime',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
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
                onPressed: () {
                  // TODO: Add QR code logic
                },
                icon: const Icon(Icons.qr_code),
                label: const Text("View QR"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF667eea),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Add cancel logic
                },
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
