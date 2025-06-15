class AppUser {
  final String name;
  final String email;
  final String phone;
  AppUser({required this.name, required this.email, required this.phone});

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
    );
  }
}
