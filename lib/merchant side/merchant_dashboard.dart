import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qless_app/bloc/booking/booking_bloc.dart';
import 'package:qless_app/bloc/booking/booking_event.dart';
import 'package:qless_app/bloc/booking/booking_state.dart';
import 'package:qless_app/merchant%20side/business_form.dart';
import 'dashboard_content.dart';
import 'service.dart';

class MerchantDashboard extends StatefulWidget {
  final String businessId;
  final String merchantId;
  const MerchantDashboard({
    Key? key,
    required this.businessId,
    required this.merchantId,
  }) : super(key: key);

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  String? _businessName;
  List<Map<String, dynamic>> _services = [];
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
    // Initialize booking data with the correct merchantId
    context.read<BookingBloc>().add(LoadBookings(widget.merchantId));
  }

  Future<void> _loadBusinessData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _fetchBusinessInfo();
      await _fetchServices();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      log('❌ Error loading business data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load business data: $e';
      });
    }
  }

  Future<void> _fetchBusinessInfo() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    log('📊 Fetching business info for userId: $userId, businessId: ${widget.businessId}');

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('businesses')
        .doc(widget.businessId)
        .get();

    if (!snapshot.exists) {
      log('❌ Business document not found');
      throw Exception('Business not found');
    }

    final businessData = snapshot.data()!;
    final businessName = businessData['businessName'] as String?;
    
    log('✅ Business name fetched: $businessName');
    
    setState(() {
      _businessName = businessName ?? 'Unnamed Business';
    });
  }

  Future<void> _fetchServices() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('businesses')
        .doc(widget.businessId)
        .get();

    if (!snapshot.exists) {
      log('❌ Business document not found for services');
      return;
    }

    final businessData = snapshot.data()!;
    final servicesFromBusiness = businessData['services'] as List<dynamic>?;
    
    if (servicesFromBusiness != null) {
      setState(() {
        _services = servicesFromBusiness
            .map((s) => Map<String, dynamic>.from(s))
            .toList();
      });
      log('✅ Services loaded: ${_services.length} services');
    } else {
      setState(() {
        _services = [];
      });
      log('ℹ️ No services found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: _isLoading ? _buildLoadingBody() : 
              _errorMessage != null ? _buildErrorBody() : _buildBody(),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildLoadingBody() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading business data...'),
        ],
      ),
    );
  }

  Widget _buildErrorBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadBusinessData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF1E88E5),
      title: Row(
        children: [
          const Icon(Icons.store, color: Colors.white),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _businessName ?? "Loading...",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Merchant Dashboard',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      actions: [_buildNotificationButton(), _buildMenuButton()],
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () => _showNotifications(context),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: const Text(
              '3',
              style: TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) {
        switch (value) {
          case 'profile':
            _editBusinessInfo();
            break;
          case 'settings':
            _showSettings();
            break;
          case 'logout':
            _logout();
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.business),
              SizedBox(width: 8),
              Text('Edit Business Info'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings),
              SizedBox(width: 8),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [Icon(Icons.logout), SizedBox(width: 8), Text('Logout')],
          ),
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E88E5),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.queue), label: 'Queue'),
        BottomNavigationBarItem(
          icon: Icon(Icons.room_service),
          label: 'Services',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        switch (_selectedIndex) {
          case 0:
            return DashboardContent(
              businessName: _businessName,
              merchantId: widget.merchantId, // Pass the merchantId here
              bookings: state is BookingLoaded ? state.bookings : [],
              initialBookings: [],
            );
          case 1:
            return DashboardContent.bookingsPage(
              bookings: state is BookingLoaded ? state.bookings : [],
              initialBookings: [],
              merchantId: widget.merchantId, // Pass the merchantId here
            );
          case 2:
            return DashboardContent.queuePage(
              bookings: state is BookingLoaded ? state.bookings : [],
              initialBookings: [],
              merchantId: widget.merchantId, // Pass the merchantId here
            );
          case 3:
            return MerchantServices(
              businessId: widget.businessId, // Use businessId for services
              services: _services,
              onServicesChanged: _refreshServices,
            );
          default:
            return DashboardContent(
              businessName: _businessName,
              merchantId: widget.merchantId, // Pass the merchantId here
              bookings: state is BookingLoaded ? state.bookings : [],
              initialBookings: [],
            );
        }
      },
    );
  }

  void _refreshServices() {
    _fetchServices();
  }

  // Action Methods
  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.blue),
              title: Text('New booking from Sarah Smith'),
              subtitle: Text('2 minutes ago'),
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
              title: Text('Booking cancelled by Mike Johnson'),
              subtitle: Text('15 minutes ago'),
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Customer checked in'),
              subtitle: Text('30 minutes ago'),
            ),
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

  void _editBusinessInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Edit Business Info page')),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Settings page')),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}