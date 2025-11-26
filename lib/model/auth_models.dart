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
  final String course;
  final String yearLevel;
  final String? middleName;
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
    required this.course,
    required this.yearLevel,
    this.middleName,
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
      'course': course,
      'year_level': yearLevel,
      'middle_name': middleName,
      'section': section,
      'department': department,
      'college': college,
      'contact_number': contactNumber,
      'address': address,
    };
  }
}