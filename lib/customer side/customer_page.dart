import 'package:flutter/material.dart';
import 'package:qless_app/customer%20side/Profile_page.dart';
import 'package:qless_app/models/service.dart';
import 'home_content.dart';
import 'Booking_page.dart'; // New bookings page

class CustomerHomePage extends StatefulWidget {
  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>
    with TickerProviderStateMixin {
  String _selectedCategory = 'All';
  String _selectedFilter = 'Recent';
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<ServiceModel> _bookedServices = [];

  void _onBookService(ServiceModel service) {
    setState(() {
      _bookedServices.add(service);
    });
    // Optionally switch to Bookings tab automatically after booking:
    // setState(() {
    //   _currentIndex = 1;
    // });
  }

  void _onCategoryChanged(String newCategory) {
    setState(() {
      _selectedCategory = newCategory;
    });
  }

  void _onFilterChanged(String newFilter) {
    setState(() {
      _selectedFilter = newFilter;
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea).withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildCurrentPage(),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return HomeContent(
          selectedCategory: _selectedCategory,
          onCategoryChanged: _onCategoryChanged,
          selectedFilter: _selectedFilter,
          onFilterChanged: _onFilterChanged,
          onBookService: _onBookService,
          bookedServices: _bookedServices,
        );
      case 1:
        return BookingsPage(
          bookings: _bookedServices, // past or completed bookings
          upcomingBookings:
              _bookedServices, // future bookings (or filter separately)
        );
      case 2:
        return Center(child: Text("Wallet Feature Coming Soon"));
      case 3:
        return ProfilePage();
      default:
        return Center(child: Text("Coming Soon"));
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF667eea),
          unselectedItemColor: Colors.grey[400],
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
