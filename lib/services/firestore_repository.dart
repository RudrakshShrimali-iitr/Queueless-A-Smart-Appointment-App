

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service.dart';

class FirestoreRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches all services from businesses owned by merchants only.
  Future<List<ServiceModel>> fetchAllServices() async {
    final allServices = <ServiceModel>[];

   
    final merchantSnap = await _db
        .collection('users')
        .where('role', isEqualTo: 'merchant')
        .get();

    for (final userDoc in merchantSnap.docs) {
      final userId = userDoc.id;

      // 2) Fetch businesses for this merchant
      final bizSnap = await _db
          .collection('users')
          .doc(userId)
          .collection('businesses')
          .get();

      for (final bizDoc in bizSnap.docs) {
        final bizData = bizDoc.data();
        final businessName = bizData['businessName'] as String? ?? 'Unknown';

        // 3) Read the services field (expected to be an array)
        if (bizData['services'] is List) {
          final servicesList = List<Map<String, dynamic>>.from(bizData['services']);

          for (final rawService in servicesList) {
            allServices.add(
              ServiceModel.fromMap(rawService, businessName),
            );
          }
        } else {
          print(" No services array found in business: $businessName (${bizDoc.id})");
        }
      }
    }

    return allServices;
  }
}
