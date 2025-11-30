import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userEmail;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userEmail => _userEmail;

  // Base URL - PALITAN MO ITO NG IYONG TUNAY NA API URL
  final String baseUrl = 'https://your-api-url.com/api';

  // Login method
  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _userEmail = email;
        _isAuthenticated = true;
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: Unable to connect to server');
    }
  }

  // Register method
  Future<void> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration successful
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: Unable to connect to server');
    }
  }

  // VERIFY EMAIL METHOD - KAILANGAN ITO
  Future<void> verifyEmail(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'code': code,
          'verification_code': code, // Alternative key name
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Set authentication after successful verification
        _token = data['token'] ?? '';
        _userEmail = email;
        _isAuthenticated = true;
        
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid verification code');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: Unable to verify email');
    }
  }

  // RESEND VERIFICATION CODE METHOD - KAILANGAN DIN ITO
  Future<void> resendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resend-verification'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        // Successfully resent
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to resend code');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: Unable to resend code');
    }
  }

  // Forgot Password method
  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send reset link');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: Unable to process request');
    }
  }

  // Reset Password method
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
          'password': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: Unable to reset password');
    }
  }

  // Logout method
  Future<void> logout() async {
    _token = null;
    _userEmail = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Check if user is authenticated
  bool checkAuth() {
    return _isAuthenticated && _token != null;
  }
}