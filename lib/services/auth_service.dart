import './api_service.dart';
import '../models/auth_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      print('🌐 AUTH SERVICE - Sending registration request');
      print('📤 Data being sent: $userData');

      final response = await _apiService.post(
        '/register',
        userData,
      );

      print('📥 Raw API Response: $response');

      return {
        'success': true,
        'message': response['message'] ?? 'Registration successful',
        'data': response,
      };
    } catch (e) {
      print('💥 AUTH SERVICE - Registration error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> login(String studentId, String password) async {
    try {
      print('🌐 AUTH SERVICE - Sending login request for: $studentId');

      final response = await _apiService.post(
        '/login',
        {'student_id': studentId, 'password': password},
      );

      print('📥 Login API Response: $response');

      // Check if response contains user data
      if (response['student_id'] != null) {
        return {
          'success': true,
          'message': response['message'] ?? 'Login successful',
          'user': User.fromJson(response),
        };
      } else {
        return {
          'success': false,
          'message': response['error'] ?? 'Login failed - no user data',
        };
      }
    } catch (e) {
      print('💥 AUTH SERVICE - Login error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    try {
      final response = await _apiService.post(
        '/verify',
        {'email': email, 'code': code},
      );

      return {
        'success': true,
        'message': response['message'],
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<User> getUserProfile(String studentId) async { 
    final response = await _apiService.get('/user/$studentId');
    return User.fromJson(response);
  }

  Future<Map<String, dynamic>> requestPasswordReset(String studentId) async {
    try {
      final response = await _apiService.post(
        '/forgot-password',
        {'student_id': studentId},
      );

      return {
        'success': true,
        'message': response['message'],
        'email': response['email'], 
        'token': response['token'], 
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String studentId,
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await _apiService.post(
        '/reset-password', // Fixed endpoint - removed /auth prefix
        {
          'student_id': studentId,
          'token': token,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      return {
        'success': true,
        'message': response['message'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}