import 'package:flutter/material.dart';
import 'home_content.dart'; // We'll create this next

class CustomerHomePage extends StatefulWidget {
  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>
    with TickerProviderStateMixin {
    
      String _selectedCategory = 'All';
String _selectedFilter = 'Recent';

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

  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
     
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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
            colors: [
              Color(0xFF667eea).withOpacity(0.1),
              Colors.white,
            ],
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
    selectedFilter: _selectedFilter,
    onCategoryChanged: _onCategoryChanged,
    onFilterChanged: _onFilterChanged,
        ); // Extracted to separate component
      case 1:
        return _buildBookingsPage();
      case 2:
        return _buildWalletPage();
      case 3:
        return _buildProfilePage();
      default:
        return HomeContent(
           selectedCategory: _selectedCategory,
    selectedFilter: _selectedFilter,
    onCategoryChanged: _onCategoryChanged,
    onFilterChanged: _onFilterChanged,
        );
    }
  }

  Widget _buildBookingsPage() {
    return Center(
      child: Text("Bookings Page"),
    );
  }

  Widget _buildWalletPage() {
    return Center(
      child: Text("Wallet Page"),
    );
  }

  Widget _buildProfilePage() {
    return Center(
      child: Text("Profile Page"),
    );
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