import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../../model/user_model.dart';
import '../../model/auth_models.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final String _tokenKey = 'auth_token';
  final String _userKey = 'user_data';
  final String _pendingUserKey = 'pending_user_';
  final String _verificationCodeKey = 'verification_code_';

  // Enable mock mode for testing without backend
  static const bool MOCK_MODE = true;

  Future<bool> verifyEmail(String email, String verificationCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_verificationCodeKey + email);

      if (savedCode == null) {
        throw Exception('No verification code found for this email');
      }

      if (savedCode != verificationCode) {
        throw Exception('Invalid verification code');
      }

      // Get pending user data
      final pendingUserJson = prefs.getString(_pendingUserKey + email);
      if (pendingUserJson == null) {
        throw Exception('User data not found');
      }

      // Save user as verified
      await prefs.setString(_userKey, pendingUserJson);
      await prefs.setString(
        _tokenKey,
        'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Clean up pending data
      await prefs.remove(_verificationCodeKey + email);
      await prefs.remove(_pendingUserKey + email);

      return true;
    } catch (e) {
      throw Exception('Verification failed: $e');
    }
  }

  Future<Map<String, dynamic>> login(LoginRequest request) async {
    try {
      if (MOCK_MODE) {
        return _mockLogin(request);
      }

      final response = await _apiService.post('/auth/login', request.toJson());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(response['user']));
      await prefs.setString(_tokenKey, response['token']);

      return response['user'];
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    try {
      if (MOCK_MODE) {
        return _mockRegister(request);
      }

      final response = await _apiService.post(
        '/auth/register',
        request.toJson(),
      );
      return response;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);

    if (userData != null) {
      try {
        final Map<String, dynamic> userJson = json.decode(userData);
        return User.fromJson(userJson);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey) != null;
  }

  // Mock login for testing
  Future<Map<String, dynamic>> _mockLogin(LoginRequest request) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation
    if (request.email.isEmpty || request.password.isEmpty) {
      throw Exception('Email and password are required');
    }

    // Create mock user
    final mockUser = {
      'id': '123',
      'email': request.email,
      'username': request.email.split('@')[0],
      'firstName': 'John',
      'lastName': 'Doe',
      'role': 'student',
      'course': 'Computer Science',
      'yearLevel': '3rd Year',
    };

    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(mockUser));
    await prefs.setString(
      _tokenKey,
      'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    return mockUser;
  }

  // Mock register for testing
  Future<Map<String, dynamic>> _mockRegister(RegisterRequest request) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation
    if (request.email.isEmpty ||
        request.password.isEmpty ||
        request.username.isEmpty) {
      throw Exception('Email, username and password are required');
    }

    if (request.password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Create mock user (not verified yet)
    final mockUser = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'email': request.email,
      'username': request.username,
      'firstName': request.firstName,
      'lastName': request.lastName,
      'role': 'student',
      'course': request.course,
      'yearLevel': request.yearLevel,
      'isVerified': false,
    };

    // Generate verification code (4 digits)
    final verificationCode = (100000 + DateTime.now().millisecond % 900000)
        .toString()
        .substring(0, 6);

    // Save pending user and verification code
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pendingUserKey + request.email,
      json.encode(mockUser),
    );
    await prefs.setString(
      _verificationCodeKey + request.email,
      verificationCode,
    );

    print('=== VERIFICATION CODE FOR TESTING ===');
    print('Email: ${request.email}');
    print('Code: $verificationCode');
    print('=====================================');

    return {
      'success': true,
      'message': 'Registration successful. Please verify your email.',
      'email': request.email,
      'verificationCode': verificationCode, // For demo purposes
    };
  }
}
