class User {
  final String id;
  final String? email;  // Email devient optionnel
  final String phoneNumber;  // Numéro obligatoire
  final String? fullName;
  final bool isActive;

  User({
    required this.id,
    this.email,
    required this.phoneNumber,
    this.fullName,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      fullName: json['full_name'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'is_active': isActive,
    };
  }
}


