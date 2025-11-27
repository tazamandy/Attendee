class User {
  final String userId;
  final String email;
  final String studentId;
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
    required this.studentId,
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
    return User(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      studentId: json['student_info']['student_id'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? 'student',
      isVerified: json['is_verified'] ?? false,
      firstName: json['student_info']['first_name'] ?? '',
      lastName: json['student_info']['last_name'] ?? '',
      course: json['student_info']['course'] ?? '',
      yearLevel: json['student_info']['year_level'] ?? '',
      qrCodeData: json['qr_code_data'],
      qrCodeType: json['qr_code_type'],
    );
  }

  String get fullName => '$firstName $lastName';
}