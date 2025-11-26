class User {
  final String userId;
  final String email;
  final String username;
  final String role;
  final bool isVerified;
  final String firstName;
  final String lastName;
  final String course;
  final String yearLevel;
  final String? qrCodeData;
  final String? qrCodeType;

  User({
    required this.userId,
    required this.email,
    required this.username,
    required this.role,
    required this.isVerified,
    required this.firstName,
    required this.lastName,
    required this.course,
    required this.yearLevel,
    this.qrCodeData,
    this.qrCodeType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle nested student_info structure
    final studentInfo = json['student_info'] ?? {};
    
    return User(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      isVerified: json['is_verified'] ?? false,
      firstName: studentInfo['first_name'] ?? json['first_name'] ?? '',
      lastName: studentInfo['last_name'] ?? json['last_name'] ?? '',
      course: studentInfo['course'] ?? json['course'] ?? '',
      yearLevel: studentInfo['year_level'] ?? json['year_level'] ?? '',
      qrCodeData: json['qr_code_data'],
      qrCodeType: json['qr_code_type'],
    );
  }
}