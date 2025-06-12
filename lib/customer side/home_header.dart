// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          'Please log in to continue',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error loading user data');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('User not found');
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final userName = userData['name']?.toString() ?? 'Guest';

        return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WelcomeSection(userName: userName),
              HeaderActions(userName: userName),
            ],
          ),
        );
      },
    );
  }
}

class WelcomeSection extends StatelessWidget {
  final String userName;

  const WelcomeSection({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        SizedBox(height: 4),
        Text(
          userName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }
}

class HeaderActions extends StatelessWidget {
  final String userName;

  const HeaderActions({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NotificationButton(),
        SizedBox(width: 12),
        ProfileAvatar(userName: userName),
      ],
    );
  }
}

class NotificationButton extends StatelessWidget {
  const NotificationButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Stack(
          children: [
            Icon(
              Icons.notifications_outlined,
              color: Color(0xFF667eea),
              size: 24,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        onPressed: () => _showNotifications(context),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications'),
        content: Text('Your appointment is coming up in 1 hour!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final String userName;

  const ProfileAvatar({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProfileMenu(context),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF667eea).withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            userName.isNotEmpty
                ? userName.substring(0, userName.length >= 2 ? 2 : 1).toUpperCase()
                : 'G',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}