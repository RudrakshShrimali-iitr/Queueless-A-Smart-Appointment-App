import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qless_app/merchant%20side/booking%20components/booking_components.dart';
import 'package:qless_app/models/booking.dart';

// Main dashboard home content
class DashboardHomeContent extends StatelessWidget {
  final String? businessName;
  final List<Booking> bookings;

  const DashboardHomeContent({
    Key? key,
    required this.businessName,
    required this.bookings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentMerchantId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final filteredBookings = bookings
        .where((b) => b.merchantId == currentMerchantId)
        .toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WelcomeCard(businessName: businessName),
          const SizedBox(height: 20),
          RealTimeStatusCard(bookingsCount: filteredBookings.length),
          const SizedBox(height: 20),
          const SectionHeader('Upcoming Bookings', Icons.schedule),
          const SizedBox(height: 12),

          BookingsList(bookings: filteredBookings),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Welcome card component
class WelcomeCard extends StatelessWidget {
  final String? businessName;

  const WelcomeCard({Key? key, this.businessName}) : super(key: key);

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

// Real-time status indicator
class RealTimeStatusCard extends StatelessWidget {
  final int bookingsCount;

  const RealTimeStatusCard({Key? key, required this.bookingsCount})
    : super(key: key);

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

// Section header component
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeader(this.title, this.icon, {Key? key}) : super(key: key);

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



// Action button component
class ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionButton(this.title, this.icon, this.color, this.onTap, {Key? key})
    : super(key: key);

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

// Empty state card
class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const EmptyStateCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

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
