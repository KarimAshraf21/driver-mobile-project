class UserProfile {
  final String id;
  final String firstname;
  final String email;
  final String phone;

  UserProfile({
    required this.id,
    required this.firstname,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstname': firstname,
      'email': email,
      'phone': phone,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      firstname: map['firstname'],
      email: map['email'],
      phone: map['phone'],
    );
  }
}
