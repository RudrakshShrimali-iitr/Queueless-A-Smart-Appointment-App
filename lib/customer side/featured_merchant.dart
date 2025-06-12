// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class FeaturedMerchants extends StatelessWidget {
  const FeaturedMerchants({Key? key}) : super(key: key);

  static const List<Map<String, String>> _merchants = [
    {
      'name': 'StyleCraft',
      'category': 'Salon',
      'rating': '4.8',
      'distance': '0.5 km',
    },
    {
      'name': 'HealthPlus',
      'category': 'Clinic',
      'rating': '4.9',
      'distance': '1.2 km',
    },
    {
      'name': 'AutoFix Pro',
      'category': 'Auto-shop',
      'rating': '4.7',
      'distance': '2.1 km',
    },
    {
      'name': 'Bella Salon',
      'category': 'Salon',
      'rating': '4.6',
      'distance': '0.8 km',
    },
    {
      'name': 'CareCorp',
      'category': 'Clinic',
      'rating': '4.8',
      'distance': '1.5 km',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Featured Merchants',
          onViewAll: () {},
        ),
        SizedBox(height: 15),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _merchants.length,
            itemBuilder: (context, index) => MerchantCard(
              merchant: _merchants[index],
            ),
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Text(
            'View All',
            style: TextStyle(color: Color(0xFF667eea)),
          ),
        ),
      ],
    );
  }
}

class MerchantCard extends StatelessWidget {
  final Map<String, String> merchant;

  const MerchantCard({Key? key, required this.merchant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MerchantImage(name: merchant['name'] ?? 'M'),
          MerchantDetails(merchant: merchant),
        ],
      ),
    );
  }
}

class MerchantImage extends StatelessWidget {
  final String name;

  const MerchantImage({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : 'M',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class MerchantDetails extends StatelessWidget {
  final Map<String, String> merchant;

  const MerchantDetails({Key? key, required this.merchant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            merchant['name'] ?? 'Unknown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 4),
          Text(
            merchant['category'] ?? 'Unknown',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RatingDisplay(rating: merchant['rating'] ?? '0.0'),
              Text(
                merchant['distance'] ?? 'N/A',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RatingDisplay extends StatelessWidget {
  final String rating;

  const RatingDisplay({Key? key, required this.rating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.orange, size: 16),
        SizedBox(width: 4),
        Text(
          rating,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}