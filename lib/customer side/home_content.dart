import 'package:flutter/material.dart';
import 'package:qless_app/models/service.dart';
import 'package:qless_app/services/firestore_repository.dart';

import 'home_header.dart';
import 'search_section.dart';
import 'service_categories.dart';
import 'service_list.dart';
import 'upcoming_booking.dart';

class HomeContent extends StatefulWidget {
  final String selectedCategory;
  final String selectedFilter;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onFilterChanged;
  final Function(ServiceModel) onBookService;
  final List<ServiceModel> bookedServices;

  const HomeContent({
    Key? key,
    required this.selectedCategory,
    required this.selectedFilter,
    required this.onCategoryChanged,
    required this.onFilterChanged,
    required this.onBookService,
    required this.bookedServices,
  }) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<List<ServiceModel>> _futureServices;
  List<ServiceModel> _allServices = [];
  String? _error;
  String _searchQuery = '';

  final List<String> filters = ['Recent', 'Popular', 'Nearby'];
  final List<String> categories = ['All', 'Salon', 'Clinic', 'Spa', 'Fitness'];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    _futureServices = FirestoreRepository().fetchAllServices();
    _futureServices.then((services) {
      setState(() => _allServices = services);
    }).catchError((e) {
      setState(() => _error = e.toString());
    });
  }

  void _bookService(ServiceModel service) {
    // Call parent's callback to update bookings list
    widget.onBookService(service);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Booking confirmed for ${service.serviceName}!"),
        backgroundColor: const Color(0xFF667eea),
      ),
    );
  }

  Widget _upcomingBookingSection() {
    if (widget.bookedServices.isNotEmpty) {
      // Show the latest booked service as upcoming booking
      final latestBooking = widget.bookedServices.last;
      return UpcomingBookingCard(
        serviceName: latestBooking.serviceName,
        salonName: latestBooking.businessName,
        bookingTime: 'Today, 2:30 PM', // You can extend this to real data later
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
              width: 1.5),
          color: Colors.grey.shade100,
        ),
        child: Text(
          'No upcoming bookings',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeader(),
                const SizedBox(height: 20),

                _upcomingBookingSection(),
                const SizedBox(height: 25),

                SearchSection(
                  filters: filters,
                  selectedFilter: widget.selectedFilter,
                  onFilterChanged: widget.onFilterChanged,
                  onSearchChanged: (query) {
                    setState(() => _searchQuery = query);
                  },
                ),

                const SizedBox(height: 25),

                ServiceCategories(
                  categories: categories,
                  selectedCategory: widget.selectedCategory,
                  onCategoryChanged: widget.onCategoryChanged,
                ),

                const SizedBox(height: 25),

                if (_error != null)
                  Text('Error loading services: $_error')
                else if (_allServices.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  ServicesList(
                    services: _allServices,
                    onBookService: _bookService,
                    searchQuery: _searchQuery, bookedServices: [],
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}
