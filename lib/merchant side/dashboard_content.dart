// ignore_for_file: deprecated_member_use, file_names

import 'package:flutter/material.dart';

class DashboardContent extends StatelessWidget {
  final String? businessName;
  final bool isBookingsPage;
  final bool isQueuePage;

  const DashboardContent({
    super.key,
    this.businessName,
    this.isBookingsPage = false,
    this.isQueuePage = false,
  });

  const DashboardContent.bookingsPage({super.key})
      : businessName = null,
        isBookingsPage = true,
        isQueuePage = false;

  const DashboardContent.queuePage({super.key})
      : businessName = null,
        isBookingsPage = false,
        isQueuePage = true;

  // Sample data - in a real app, these would come from parameters or state management
  static const List<Map<String, dynamic>> upcomingBookings = [
    {
      'customerName': 'John Doe',
      'service': 'Haircut',
      'time': '10:30 AM',
      'status': 'Confirmed',
      'price': 25.0,
    },
    {
      'customerName': 'Sarah Smith',
      'service': 'Hair Color',
      'time': '11:00 AM',
      'status': 'Pending',
      'price': 80.0,
    },
    {
      'customerName': 'Mike Johnson',
      'service': 'Beard Trim',
      'time': '11:30 AM',
      'status': 'Confirmed',
      'price': 15.0,
    },
  ];

  static const List<Map<String, dynamic>> queueCustomers = [
    {
      'name': 'Alex Wilson',
      'service': 'Haircut',
      'waitTime': '5 min',
      'status': 'Next',
    },
    {
      'name': 'Emma Davis',
      'service': 'Hair Color',
      'waitTime': '35 min',
      'status': 'Waiting',
    },
    {
      'name': 'James Brown',
      'service': 'Beard Trim',
      'waitTime': '50 min',
      'status': 'Waiting',
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (isBookingsPage) {
      return _buildBookingsPage(context);
    } else if (isQueuePage) {
      return _buildQueuePage(context);
    } else {
      return _buildDashboard(context);
    }
  }

  Widget _buildDashboard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
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
          ),
          const SizedBox(height: 20),

          // Upcoming Bookings
          _buildSectionHeader('Upcoming Bookings', Icons.schedule),
          const SizedBox(height: 12),
          Container(
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
              itemCount: upcomingBookings.length,
              itemBuilder: (context, index) {
                final booking = upcomingBookings[index];
                return _buildBookingTile(context, booking);
              },
            ),
          ),
          const SizedBox(height: 20),

          // Quick Actions
          _buildSectionHeader('Quick Actions', Icons.flash_on),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Add Service',
                  Icons.add_business,
                  Colors.blue,
                  () => _addService(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'View Analytics',
                  Icons.analytics,
                  Colors.green,
                  () => _viewAnalytics(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Filter Tabs
          Container(
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
                Expanded(child: _buildFilterTab('Today', true)),
                Expanded(child: _buildFilterTab('Upcoming', false)),
                Expanded(child: _buildFilterTab('Past', false)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bookings List
          Expanded(
            child: ListView.builder(
              itemCount: upcomingBookings.length,
              itemBuilder: (context, index) {
                final booking = upcomingBookings[index];
                return _buildDetailedBookingCard(context, booking);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueuePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Queue Status
          Container(
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${queueCustomers.length} customers waiting',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Queue List
          Expanded(
            child: ListView.builder(
              itemCount: queueCustomers.length,
              itemBuilder: (context, index) {
                final customer = queueCustomers[index];
                return _buildQueueTile(context, customer, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
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

  Widget _buildBookingTile(BuildContext context, Map<String, dynamic> booking) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: booking['status'] == 'Confirmed'
            ? Colors.green.withOpacity(0.2)
            : Colors.orange.withOpacity(0.2),
        child: Icon(
          Icons.person,
          color: booking['status'] == 'Confirmed' ? Colors.green : Colors.orange,
        ),
      ),
      title: Text(booking['customerName']),
      subtitle: Text('${booking['service']} • ${booking['time']}'),
      trailing: Chip(
        label: Text(booking['status'], style: const TextStyle(fontSize: 12)),
        backgroundColor: booking['status'] == 'Confirmed'
            ? Colors.green.withOpacity(0.2)
            : Colors.orange.withOpacity(0.2),
      ),
      onTap: () => _showBookingDetails(context, booking),
    );
  }

  Widget _buildDetailedBookingCard(BuildContext context, Map<String, dynamic> booking) {
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
                  booking['customerName'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(booking['status']),
                  backgroundColor: booking['status'] == 'Confirmed'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.room_service, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(booking['service']),
                const Spacer(),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(booking['time']),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                Text('\$${booking['price']}'),
                const Spacer(),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueTile(BuildContext context, Map<String, dynamic> customer, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: customer['status'] == 'Next'
              ? Colors.green.withOpacity(0.2)
              : Colors.blue.withOpacity(0.2),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: customer['status'] == 'Next' ? Colors.green : Colors.blue,
            ),
          ),
        ),
        title: Text(customer['name']),
        subtitle: Text(
          '${customer['service']} • Wait: ${customer['waitTime']}',
        ),
        trailing: customer['status'] == 'Next'
            ? ElevatedButton(
                onPressed: () => _checkInCustomer(context, customer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Check In'),
              )
            : Chip(
                label: Text(customer['status']),
                backgroundColor: Colors.blue.withOpacity(0.2),
              ),
      ),
    );
  }

  Widget _buildFilterTab(String title, bool isSelected) {
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

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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

  // Action methods
  void _addService(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Add Service page')),
    );
  }

  void _viewAnalytics(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Analytics page')),
    );
  }

  void _showBookingDetails(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${booking['customerName']}'),
            Text('Service: ${booking['service']}'),
            Text('Time: ${booking['time']}'),
            Text('Price: \$${booking['price']}'),
            Text('Status: ${booking['status']}'),
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

  void _editBooking(BuildContext context, Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit booking for ${booking['customerName']}')),
    );
  }

  void _cancelBooking(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Cancel booking for ${booking['customerName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled')),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _checkInCustomer(BuildContext context, Map<String, dynamic> customer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${customer['name']} checked in successfully')),
    );
  }
}