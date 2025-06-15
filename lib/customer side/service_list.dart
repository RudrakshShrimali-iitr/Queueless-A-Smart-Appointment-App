import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qless_app/customer side/upcoming_booking.dart';
import 'package:qless_app/models/service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qless_app/services/booking_service.dart';

class ServicesList extends StatefulWidget {
  final List<ServiceModel> services;
  final String searchQuery;
  final List<ServiceModel> bookedServices;
  final void Function(ServiceModel service) onBookService;

  const ServicesList({
    Key? key,
    required this.services,
    required this.searchQuery,
    required this.bookedServices,
    required this.onBookService,
  }) : super(key: key);

  @override
  State<ServicesList> createState() => _ServicesListState();
}

class _ServicesListState extends State<ServicesList> {
  // Track which services are currently being booked or already booked
  final Set<String> _bookingInProgress = <String>{};
  final Set<String> _alreadyBooked = <String>{};

  @override
  void initState() {
    super.initState();
    // Initialize already booked services
    for (final service in widget.bookedServices) {
      _alreadyBooked.add(service.serviceName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredServices = widget.services.where((service) {
      final query = widget.searchQuery.toLowerCase();
      return service.serviceName.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.bookedServices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: UpcomingBookingCard(
              serviceName: widget.bookedServices.last.serviceName,
              salonName: widget.bookedServices.last.businessName,
              bookingTime: 'Today, 2:30 PM',
            ),
          ),
        Text(
          'Available Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 15),
        if (filteredServices.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'No services match your search.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: filteredServices.length,
          itemBuilder: (context, index) {
            final service = filteredServices[index];
            final serviceKey = '${service.serviceName}_${service.merchantId}';
            final isBookingInProgress = _bookingInProgress.contains(serviceKey);
            final isAlreadyBooked = _alreadyBooked.contains(
              service.serviceName,
            );

            return ServiceCard(
              service: service,
              isBookingInProgress: isBookingInProgress,
              isAlreadyBooked: isAlreadyBooked,
              onBook: () async {
                // Check if already booked
                if (isAlreadyBooked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'You have already booked ${service.serviceName}',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Check if booking is in progress
                if (isBookingInProgress) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking is already in progress...'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You must be logged in')),
                  );
                  return;
                }

                // Set booking in progress
                setState(() {
                  _bookingInProgress.add(serviceKey);
                });

                try {
                  final userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get();

                  final customerName = userDoc.data()?['name'] ?? 'Guest';

                  await BookingService().createBooking(
                    merchantId: service.merchantId,
                    serviceDuration: service.duration,
                    businessName: service.businessName,
                    customerId: user.uid,
                    customerName: customerName,
                    serviceType: " ", // ← must supply
                    timeSlot: DateTime.now().add(const Duration(hours: 1)),
                    serviceName: service.serviceName, // ← must supply
                    price: service.price,
                  );

                  // Mark as booked successfully
                  setState(() {
                    _alreadyBooked.add(service.serviceName);
                    _bookingInProgress.remove(serviceKey);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${service.serviceName} booked successfully!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Call the callback
                  widget.onBookService(service);
                } catch (e) {
                  // Remove from booking in progress on error
                  setState(() {
                    _bookingInProgress.remove(serviceKey);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to book: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final Future<void> Function() onBook;
  final bool isBookingInProgress;
  final bool isAlreadyBooked;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.onBook,
    required this.isBookingInProgress,
    required this.isAlreadyBooked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ServiceIcon(category: service.serviceName),
          const SizedBox(width: 16),
          Expanded(child: ServiceDetails(service: service)),
          ServiceActions(
            price: service.price,
            onBook: onBook,
            isBookingInProgress: isBookingInProgress,
            isAlreadyBooked: isAlreadyBooked,
          ),
        ],
      ),
    );
  }
}

class ServiceIcon extends StatelessWidget {
  final String category;

  const ServiceIcon({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String emoji = getEmojiForCategory(category);

    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 28)),
    );
  }

  String getEmojiForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'salon':
        return '💇‍♀️';
      case 'healthcare':
        return '🩺';
      case 'spa':
        return '💆‍♀️';
      case 'fitness':
        return '🏋️‍♂️';
      case 'massage':
        return '💆';
      default:
        return '✨';
    }
  }
}

class ServiceDetails extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetails({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          service.serviceName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          service.businessName,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        ServiceMetrics(duration: service.duration),
      ],
    );
  }
}

class ServiceMetrics extends StatelessWidget {
  final int duration;

  const ServiceMetrics({Key? key, required this.duration}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          '$duration min',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.star, size: 16, color: Colors.orange),
        const SizedBox(width: 4),
      ],
    );
  }
}

class ServiceActions extends StatelessWidget {
  final double price;
  final VoidCallback onBook;
  final bool isBookingInProgress;
  final bool isAlreadyBooked;

  const ServiceActions({
    Key? key,
    required this.price,
    required this.onBook,
    required this.isBookingInProgress,
    required this.isAlreadyBooked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '₹${price.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667eea),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: (isBookingInProgress || isAlreadyBooked) ? null : onBook,
          style: ElevatedButton.styleFrom(
            backgroundColor: isAlreadyBooked
                ? Colors.green
                : (isBookingInProgress ? Colors.grey : const Color(0xFF667eea)),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBackgroundColor: isAlreadyBooked
                ? Colors.green
                : Colors.grey,
            disabledForegroundColor: Colors.white,
          ),
          child: isBookingInProgress
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  isAlreadyBooked ? 'Booked' : 'Book Now',
                  style: const TextStyle(fontSize: 12),
                ),
        ),
      ],
    );
  }
}
