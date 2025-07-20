class AdminUser {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String username;
  final double balance;
  final String? keycloakId;
  final bool verified;

  AdminUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.username,
    required this.balance,
    this.keycloakId,
    required this.verified,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      username: json['username'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      keycloakId: json['keycloakId'],
      verified: json['verified'] ?? false,
    );
  }
} 