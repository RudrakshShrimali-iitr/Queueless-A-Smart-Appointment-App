// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:qless_app/models/service.dart';
import 'package:qless_app/services/firestore_repository.dart';
import 'home_header.dart';
import 'search_section.dart';
import 'featured_merchant.dart';
import 'service_categories.dart';
import 'service_list.dart';
import 'upcoming_booking.dart';

class HomeContent extends StatefulWidget {
  final String selectedCategory;
  final String selectedFilter;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onFilterChanged;

  const HomeContent({
    Key? key,
    required this.selectedCategory,
    required this.selectedFilter,
    required this.onCategoryChanged,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<List<ServiceModel>> _futureServices;
  List<ServiceModel> _allServices = [];
  String? _error;
  
  final List<String> filters = ['Recent', 'Popular', 'Nearby'];
  final List<String> categories = ['All', 'Salon', 'Clinic', 'Auto-shop'];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    _futureServices = FirestoreRepository().fetchAllServices();
    _futureServices.then((services) {
      print("🔁 Loaded services: ${services.length}");
      setState(() {
        _allServices = services;
      });
    }).catchError((e) {
      print("❌ Error loading services: $e");
      setState(() {
        _error = e.toString();
      });
    });
  }

  void _bookService(ServiceModel service) {
    if (!mounted) return;

    String serviceName = service.serviceName;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Booking confirmed for $serviceName!"),
        backgroundColor: Color(0xFF667eea),
      ),
    );
  }

  Widget _buildServicesContent() {
    if (_error != null) {
      return Text('Error loading services: $_error');
    }
    
    if (_allServices.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    
    return ServicesList(
      services: _allServices,
      onBookService: _bookService,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(),
          SizedBox(height: 20),
          UpcomingBookingCard(),
          SizedBox(height: 25),
          SearchSection(
            filters: filters,
            selectedFilter: widget.selectedFilter,
            onFilterChanged: widget.onFilterChanged,
          ),
          SizedBox(height: 25),
          FeaturedMerchants(),
          SizedBox(height: 25),
          ServiceCategories(
            categories: categories,
            selectedCategory: widget.selectedCategory,
            onCategoryChanged: widget.onCategoryChanged,
          ),
          SizedBox(height: 25),
          _buildServicesContent(),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}