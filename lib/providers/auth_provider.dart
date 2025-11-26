// lib/services/auth_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/constants.dart';  // Import para sa BASE_URL
import '../models/auth_model.dart';  // Para sa User model

class AuthService {
  // Base URL from constants
  static const String baseUrl = Constants.BASE_URL;

  // Existing methods mo (hal. register, login, etc.)—i-keep mo ang original, i-add lang ang bagong ones

  /// Existing register method (sample; i-adjust mo base sa original mo)
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final uri = Uri.parse('$baseUrl/api/auth/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    ).timeout(const Duration(seconds: Constants.TIMEOUT_SECONDS));

    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true, 'message': 'Registered successfully'};
    } else {
      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      return {
        'success': false,
        'message': data?['message'] ?? 'Registration failed: ${response.statusCode}',
      };
    }
  }

  /// Existing login method (sample; i-adjust mo base sa original mo)
  Future<Map<String, dynamic>> login(String studentId, String password) async {
    final uri = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId, 'password': password}),
    ).timeout(const Duration(seconds: Constants.TIMEOUT_SECONDS));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final user = User.fromJson(data['user']);  // Assume backend returns user JSON
      return {'success': true, 'user': user, 'studentId': data['studentId']};
    } else {
      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      return {
        'success': false,
        'message': data?['message'] ?? 'Login failed: ${response.statusCode}',
      };
    }
  }

  /// Existing requestPasswordReset (sample)
  Future<Map<String, dynamic>> requestPasswordReset(String studentId) async {
    final uri = Uri.parse('$baseUrl/api/auth/forgot-password');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId}),
    ).timeout(const Duration(seconds: Constants.TIMEOUT_SECONDS));

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Reset link sent'};
    } else {
      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      return {
        'success': false,
        'message': data?['message'] ?? 'Reset request failed',
      };
    }
  }

  /// Existing resetPassword (sample)
  Future<Map<String, dynamic>> resetPassword(
    String studentId, String token, String newPassword, String confirmPassword) async {
    final uri = Uri.parse('$baseUrl/api/auth/reset-password');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    ).timeout(const Duration(seconds: Constants.TIMEOUT_SECONDS));

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Password reset successfully'};
    } else {
      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      return {
        'success': false,
        'message': data?['message'] ?? 'Reset failed',
      };
    }
  }

  /// NEW: Verify email OTP and generate student ID
  Future<Map<String, dynamic>> verifyEmail(String email, String otp) async {
    final uri = Uri.parse('$baseUrl/api/auth/verify');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'userType': 'student',  // Default para sa ID generation
      }),
    ).timeout(const Duration(seconds: Constants.TIMEOUT_SECONDS));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Assume backend returns {'success': true, 'studentId': 'STU-abc123', 'user': {...}}
      return data;
    } else {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
      return {
        'success': false,
        'message': errorData?['message'] ?? 'Verification failed: ${response.statusCode}',
      };
    }
  }

  /// NEW: Resend OTP to email
  Future<Map<String, dynamic>> resendOTP(String email) async {
    final uri = Uri.parse('$baseUrl/api/auth/resend-otp');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
      }),
    ).timeout(const Duration(seconds: Constants.TIMEOUT_SECONDS));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Assume backend returns {'success': true, 'message': 'OTP resent'}
      return data;
    } else {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
      return {
        'success': false,
        'message': errorData?['message'] ?? 'Resend failed: ${response.statusCode}',
      };
    }
  }
}