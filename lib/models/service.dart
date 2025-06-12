class ServiceModel {
  final String businessName;
  final String serviceName;
  final String description;
  final double price;
  final int duration;

  ServiceModel({
    required this.businessName,
    required this.serviceName,
    required this.description,
    required this.price,
    required this.duration,
  });

  /// Factory constructor to build from a raw map (Firestore) + businessName
  factory ServiceModel.fromMap(Map<String, dynamic> map, String businessName) {
    return ServiceModel(
      businessName: businessName,
      serviceName: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      duration: (map['duration'] as num?)?.toInt() ?? 0,
    );
  }
}
