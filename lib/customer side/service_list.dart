import 'package:flutter/material.dart';
import 'package:qless_app/models/service.dart';

class ServicesList extends StatelessWidget {
  final List<ServiceModel> services;
  final Function(ServiceModel) onBookService;

  const ServicesList({
    Key? key,
    required this.services,
    required this.onBookService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: services.length,
          itemBuilder: (context, index) => ServiceCard(
            service: services[index],
            onBook: () => onBookService(services[index]),
          ),
        ),
      ],
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onBook;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.onBook,
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
          ServiceIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: ServiceDetails(service: service),
          ),
          ServiceActions(
            price: service.price,
            onBook: onBook,
          ),
        ],
      ),
    );
  }
}

class ServiceIcon extends StatelessWidget {
  const ServiceIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
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

  const ServiceActions({
    Key? key,
    required this.price,
    required this.onBook,
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
          onPressed: onBook,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Book Now', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}