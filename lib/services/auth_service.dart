import './api_service.dart';
import '../models/auth_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String studentId, String password) async {
    try {
      final response = await _apiService.post(
        '/login',
        {'student_id': studentId, 'password': password}, // PALITAN DITO
      );

      return {
        'success': true,
        'message': response['message'],
        'user': User.fromJson(response),
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post(
        '/register',
        userData,
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
        '/auth/reset-password',
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

  // Optional: For testing without backend
  Future<Map<String, dynamic>> requestPasswordResetSimulated(String studentId) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    
    if (studentId.isNotEmpty) {
      return {
        'success': true,
        'message': 'Password reset link sent to your registered email',
        'email': 'user@example.com', // Simulated email
        'token': 'simulated_token_${DateTime.now().millisecondsSinceEpoch}', // Simulated token
      };
    } else {
      return {
        'success': false,
        'message': 'Student ID is required',
      };
    }
  }

  Future<Map<String, dynamic>> resetPasswordSimulated(
    String studentId,
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    await Future.delayed(const Duration(seconds: 2)); 
    
    if (newPassword != confirmPassword) {
      return {
        'success': false,
        'message': 'Passwords do not match',
      };
    }
    
    if (newPassword.length < 6) {
      return {
        'success': false,
        'message': 'Password must be at least 6 characters',
      };
    }
    
    return {
      'success': true,
      'message': 'Password reset successfully',
    };
  }
}