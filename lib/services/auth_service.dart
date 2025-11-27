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
      print('🌐 AUTH SERVICE - Verifying email: $email with code: $code');
      
      final response = await _apiService.post(
        '/verify',
        {'email': email, 'code': code},
      );

      print('📥 Verify Email Response: $response');

      return {
        'success': true,
        'message': response['message'],
        'data': response,
      };
    } catch (e) {
      print('💥 AUTH SERVICE - Verify email error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }



Future<Map<String, dynamic>> verifyResetCode(String studentId, String code) async {
  try {
    print(' AUTH SERVICE - Verifying reset code for: $studentId');
    print(' Code: $code');


    final response = await _apiService.post(
      '/verify-reset-code', // This should be your verification endpoint
      {
        'student_id': studentId,
        'code': code,
      },
    );

    print(' Verify Reset Code RAW Response: $response');
    print(' Response Type: ${response.runtimeType}');
    print(' Response Keys: ${response.keys}');

  
    bool success = response['success'] == true || 
                  response['status'] == 'success' || 
                  response['verified'] == true ||
                  response['token'] != null;

    if (success) {
    
      String? token = response['token'] ?? 
                     response['reset_token'] ?? 
                     response['access_token'] ?? 
                     response['verification_token'];

      print('🎯 Extracted Token: $token');

      if (token != null) {
        return {
          'success': true,
          'message': response['message'] ?? 'Code verified successfully',
          'token': token,
          'email': response['email'],
          'student_id': response['student_id'] ?? studentId,
        };
      } else {
        return {
          'success': false,
          'message': 'Verification successful but no token received',
        };
      }
    } else {
      return {
        'success': false,
        'message': response['error'] ?? response['message'] ?? 'Invalid verification code',
      };
    }
  } catch (e) {
    print('💥 AUTH SERVICE - Verify reset code error: $e');
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
      print('🌐 AUTH SERVICE - Requesting password reset for: $studentId');

      final response = await _apiService.post(
        '/forgot-password',
        {'student_id': studentId},
      );

      print('📥 Request Password Reset Response: $response');

      // Check if the response indicates success
      if (response['success'] == true || response['message']?.contains('sent') == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Verification code sent to your email',
          'email': response['email'], 
          'student_id': response['student_id'],
        };
      } else {
        return {
          'success': false,
          'message': response['error'] ?? response['message'] ?? 'Failed to send reset code',
        };
      }
    } catch (e) {
      print('💥 AUTH SERVICE - Request password reset error: $e');
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
      print('🌐 AUTH SERVICE - Resetting password for: $studentId');
      print('📤 Token: $token, New Password: $newPassword');

      final response = await _apiService.post(
        '/reset-password',
        {
          'student_id': studentId,
          'token': token,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      print('📥 Reset Password Response: $response');

      // Check if password reset was successful
      if (response['success'] == true || response['message']?.contains('success') == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Password reset successfully',
        };
      } else {
        return {
          'success': false,
          'message': response['error'] ?? response['message'] ?? 'Failed to reset password',
        };
      }
    } catch (e) {
      print('💥 AUTH SERVICE - Reset password error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}