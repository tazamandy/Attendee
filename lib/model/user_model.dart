class User {
  final String userId;
  final String email;
  final String username;
  final String role;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? verifiedAt;
  final String? studentNumber;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? course;
  final String? yearLevel;
  final String? section;
  final String? department;
  final String? college;
  final String? contactNumber;
  final String? address;
  final String? qrCodeData;

  User({
    required this.userId,
    required this.email,
    required this.username,
    required this.role,
    required this.isVerified,
    this.createdAt,
    this.verifiedAt,
    this.studentNumber,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.course,
    this.yearLevel,
    this.section,
    this.department,
    this.college,
    this.contactNumber,
    this.address,
    this.qrCodeData,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? 'student',
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      verifiedAt: json['verified_at'] != null ? DateTime.parse(json['verified_at']) : null,
      studentNumber: json['student_number'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      middleName: json['middle_name'],
      course: json['course'],
      yearLevel: json['year_level'],
      section: json['section'],
      department: json['department'],
      college: json['college'],
      contactNumber: json['contact_number'],
      address: json['address'],
      qrCodeData: json['qr_code_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'username': username,
      'role': role,
      'is_verified': isVerified,
      'student_number': studentNumber,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'course': course,
      'year_level': yearLevel,
      'section': section,
      'department': department,
      'college': college,
      'contact_number': contactNumber,
      'address': address,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String username;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? studentNumber;
  final String? course;
  final String? yearLevel;
  final String? section;
  final String? department;
  final String? college;
  final String? contactNumber;
  final String? address;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.studentNumber,
    this.course,
    this.yearLevel,
    this.section,
    this.department,
    this.college,
    this.contactNumber,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'student_number': studentNumber,
      'course': course,
      'year_level': yearLevel,
      'section': section,
      'department': department,
      'college': college,
      'contact_number': contactNumber,
      'address': address,
    };
  }
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ResetPasswordRequest {
  final String token;
  final String newPassword;

  ResetPasswordRequest({required this.token, required this.newPassword});

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'new_password': newPassword,
    };
  }
}