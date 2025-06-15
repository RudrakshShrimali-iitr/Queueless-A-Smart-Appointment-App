import 'package:flutter/material.dart';
import 'package:qless_app/merchant%20side/Dashboard_content.dart';
import 'package:qless_app/merchant%20side/booking%20components/booking_helper.dart';
import 'package:qless_app/merchant%20side/dashboard_widget.dart';
import 'package:qless_app/models/booking.dart';


// Main bookings list component
class BookingsList extends StatelessWidget {
  final List<Booking> bookings;

  const BookingsList({Key? key, required this.bookings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const EmptyStateCard(
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
          return BookingTile(booking: bookings[index]);
        },
      ),
    );
  }
}

// Individual booking tile
class BookingTile extends StatelessWidget {
  final Booking booking;

  const BookingTile({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: BookingHelpers.getStatusColor(
          booking.status,
        ).withOpacity(0.2),
        child: Icon(
          Icons.person,
          color: BookingHelpers.getStatusColor(booking.status),
        ),
      ),
      title: Text(booking.customerName),
      subtitle: Text(
        '${booking.serviceName} • ${BookingHelpers.formatTime(booking.bookingTime)}',
      ),
      trailing: Chip(
        label: Text(
          BookingHelpers.getStatusText(booking.status),
          style: const TextStyle(fontSize: 12),
        ),
        backgroundColor: BookingHelpers.getStatusColor(
          booking.status,
        ).withOpacity(0.2),
      ),
      onTap: () => BookingHelpers.showBookingDetails(context, booking),
    );
  }
}

// Filter tabs component
class FilterTabs extends StatelessWidget {
  const FilterTabs({Key? key}) : super(key: key);

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
          Expanded(child: FilterTab('Today', true)),
          Expanded(child: FilterTab('Upcoming', false)),
          Expanded(child: FilterTab('Past', false)),
        ],
      ),
    );
  }
}

// Individual filter tab
class FilterTab extends StatelessWidget {
  final String title;
  final bool isSelected;

  const FilterTab(this.title, this.isSelected, {Key? key}) : super(key: key);

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