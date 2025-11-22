class UserModel {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final bool isActive;
  final bool isEmailVerified;
  final String? emailVerifiedAt;
  final String? lastLogin;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isActive,
    required this.isEmailVerified,
    this.emailVerifiedAt,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      emailVerifiedAt: json['emailVerifiedAt'],
      lastLogin: json['lastLogin'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'emailVerifiedAt': emailVerifiedAt,
      'lastLogin': lastLogin,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    bool? isActive,
    bool? isEmailVerified,
    String? emailVerifiedAt,
    String? lastLogin,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get full name
  String get fullName => '$firstName $lastName'.trim();

  // Get display name (username or full name)
  String get displayName => fullName.isNotEmpty ? fullName : username;

  // Check if user is verified
  bool get isVerified => isEmailVerified && isActive;

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, fullName: $fullName, role: $role, isActive: $isActive, isEmailVerified: $isEmailVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.role == role &&
        other.isActive == isActive &&
        other.isEmailVerified == isEmailVerified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        role.hashCode ^
        isActive.hashCode ^
        isEmailVerified.hashCode;
  }
}
