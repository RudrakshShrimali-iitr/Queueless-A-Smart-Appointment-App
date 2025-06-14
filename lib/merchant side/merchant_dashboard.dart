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
  const MerchantDashboard({Key? key, required this.businessId, required this.merchantId}) : super(key: key);

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  late String _businessId;
  String? _businessName;
  List<Map<String, dynamic>> _services = [];
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadBusinessIdAndServices();
    // Initialize booking data
    context.read<BookingBloc>().add(LoadBookings(widget.businessId));
  }

  Future<void> _loadBusinessIdAndServices() async {
    _businessId = widget.businessId;
    await _fetchServices();
  }

  Future<void> _fetchServices() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('businesses')
        .doc(_businessId)
        .get();

    if (!snapshot.exists) {
      log('❌ Business doc not found');
      return;
    }

    final businessData = snapshot.data()!;
    setState(() {
      _businessName = businessData['businessName'] ?? 'Unnamed Business';
    });

    final servicesFromBusiness = businessData['services'] as List<dynamic>?;
    if (servicesFromBusiness != null) {
      setState(() {
        _services = servicesFromBusiness
            .map((s) => Map<String, dynamic>.from(s))
            .toList();
      });
    } else {
      setState(() {
        _services = [];
      });
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
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavBar(),
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
              bookings: state is BookingLoaded ? state.bookings : [], initialBookings: [],
            );
          case 1:
            return DashboardContent.bookingsPage(
              bookings: state is BookingLoaded ? state.bookings : [], initialBookings: [],
            );
          case 2:
            return DashboardContent.queuePage(
              bookings: state is BookingLoaded ? state.bookings : [], initialBookings: [],
            );
          case 3:
            return MerchantServices(
              businessId: _businessId,
              services: _services,
              onServicesChanged: _refreshServices,
            );
          default:
            return DashboardContent(
              businessName: _businessName,
              bookings: state is BookingLoaded ? state.bookings : [], initialBookings: [],
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigate to Settings page')));
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
