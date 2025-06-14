class ServiceModel {
  final String businessName;
  final String businessId;
  final String merchantId;
  final String serviceName;
  final String description;
  final double price;
  final int duration;
  final String imageUrl;

  ServiceModel({
    required this.businessName,
    required this.businessId,
    required this.merchantId,
    required this.serviceName,
    required this.description,
    required this.price,
    required this.duration,
    required this.imageUrl,
  });

  /// Factory constructor to build from a raw map (Firestore) + businessName + merchantId
  factory ServiceModel.fromMap(
    Map<String, dynamic> map, {
    required String businessName,
    required String merchantId,
  }) {
    return ServiceModel(
      businessName: businessName,
      businessId: map['businessId'] as String? ?? '',
      merchantId: merchantId,
      serviceName: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] as String? ?? '',
    );
  }
}
