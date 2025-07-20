class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String username;
  final bool isVerified;
  final double balance;
  final String? keycloakId;
  final String? profileUrl;
  final bool verified;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.isVerified,
    required this.username,
    required this.balance,
    this.keycloakId,
    this.profileUrl,
    this.verified = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      isVerified: map['isVerified'] ?? false,
      balance: (map['balance'] != null) ? (map['balance'] is int ? (map['balance'] as int).toDouble() : map['balance'] as double) : 0.0,
      keycloakId: map['keycloakId'],
      profileUrl: map['profileUrl'],
      verified: map['verified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
      'balance': balance,
      'keycloakId': keycloakId,
      'profileUrl': profileUrl,
      'verified': verified,
    };
  }
}
