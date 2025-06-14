class AppUser {
  final String name;
  final String email;

  AppUser({required this.name, required this.email});

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }
}