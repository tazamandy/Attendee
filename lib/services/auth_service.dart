import './api_service.dart';
import '../models/auth_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  // API Endpoint constants for better maintainability
  static const String _registerEndpoint = '/register';
  static const String _loginEndpoint = '/login';
  static const String _verifyEmailEndpoint = '/verify';
  static const String _verifyResetCodeEndpoint = '/verify-reset-code';
  static const String _forgotPasswordEndpoint = '/forgot-password';
  static const String _resetPasswordEndpoint = '/reset-password';
  static const String _userProfileEndpoint = '/user';

  // Success indicators for flexible API response handling
  static const List<String> _successIndicators = ['success', 'status', 'verified'];
  static const List<String> _tokenKeys = ['token', 'reset_token', 'access_token', 'verification_token'];

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      print('🌐 AUTH SERVICE - Sending registration request');
      print('📤 Data being sent: $userData');

      final response = await _apiService.post(_registerEndpoint, userData);
      print('📥 Raw API Response: $response');

      // Enhanced response validation
      final bool isSuccess = _checkSuccess(response);
      final String message = response['message'] ?? 
                            (isSuccess ? 'Registration successful' : 'Registration failed');

      return {
        'success': isSuccess,
        'message': message,
        'data': response,
      };
    } catch (e) {
      print('💥 AUTH SERVICE - Registration error: $e');
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login(String studentId, String password) async {
    try {
      print('🌐 AUTH SERVICE - Sending login request for: $studentId');

      final response = await _apiService.post(
        _loginEndpoint,
        {'student_id': studentId, 'password': password},
      );

      print('📥 Login API Response: $response');

      // Enhanced user data validation
      if (_hasUserData(response)) {
        return {
          'success': true,
          'message': response['message'] ?? 'Login successful',
          'user': User.fromJson(response),
        };
      } else {
        return {
          'success': false,
          'message': response['error'] ?? response['message'] ?? 'Login failed - no user data received',
        };
      }
    } catch (e) {
      print('💥 AUTH SERVICE - Login error: $e');
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    try {
      print('🌐 AUTH SERVICE - Verifying email: $email with code: $code');
      
      final response = await _apiService.post(
        _verifyEmailEndpoint,
        {'email': email, 'code': code},
      );

      print('📥 Verify Email Response: $response');

      final bool isSuccess = _checkSuccess(response);
      final String message = response['message'] ?? 
                            (isSuccess ? 'Email verified successfully' : 'Email verification failed');

      return {
        'success': isSuccess,
        'message': message,
        'data': response,
      };
    } catch (e) {
      print('💥 AUTH SERVICE - Verify email error: $e');
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(String studentId, String code) async {
    try {
      print('🔐 AUTH SERVICE - Verifying reset code for: $studentId');
      print('🔢 Code: $code');

      final response = await _apiService.post(
        _verifyResetCodeEndpoint,
        {'student_id': studentId, 'code': code},
      );

      print('📥 Verify Reset Code RAW Response: $response');
      print('📊 Response Type: ${response.runtimeType}');
      print('🔑 Response Keys: ${response.keys}');

      // Enhanced success checking
      final bool isSuccess = _checkSuccess(response) || response['token'] != null;

      if (isSuccess) {
        final String? token = _extractToken(response);
        print('🎯 Extracted Token: $token');

        if (token != null && token.isNotEmpty) {
          return {
            'success': true,
            'message': response['message'] ?? 'Verification code accepted',
            'token': token,
            'email': response['email'],
            'student_id': response['student_id'] ?? studentId,
          };
        } else {
          return {
            'success': false,
            'message': 'Verification successful but no valid token received',
          };
        }
      } else {
        return {
          'success': false,
          'message': response['error'] ?? response['message'] ?? 'Invalid or expired verification code',
        };
      }
    } catch (e) {
      print('💥 AUTH SERVICE - Verify reset code error: $e');
      return _handleError(e);
    }
  }

  Future<User> getUserProfile(String studentId) async {
    try {
      print('👤 AUTH SERVICE - Fetching user profile for: $studentId');
      final response = await _apiService.get('$_userProfileEndpoint/$studentId');
      return User.fromJson(response);
    } catch (e) {
      print('💥 AUTH SERVICE - Get user profile error: $e');
      rethrow; // Re-throw since this returns User directly
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset(String studentId) async {
    try {
      print('🌐 AUTH SERVICE - Requesting password reset for: $studentId');

      final response = await _apiService.post(
        _forgotPasswordEndpoint,
        {'student_id': studentId},
      );

      print('📥 Request Password Reset Response: $response');

      // Enhanced success detection
      final bool isSuccess = _checkSuccess(response) || 
                           response['message']?.toString().toLowerCase().contains('sent') == true ||
                           response['message']?.toString().toLowerCase().contains('email') == true;

      if (isSuccess) {
        return {
          'success': true,
          'message': response['message'] ?? 'Password reset instructions sent to your email',
          'email': response['email'], 
          'student_id': response['student_id'] ?? studentId,
        };
      } else {
        return {
          'success': false,
          'message': response['error'] ?? response['message'] ?? 'Failed to send reset instructions',
        };
      }
    } catch (e) {
      print('💥 AUTH SERVICE - Request password reset error: $e');
      return _handleError(e);
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
      print('🔐 Token: $token');

      // Validate input before making API call
      if (token.isEmpty) {
        return {
          'success': false,
          'message': 'Reset token is required',
        };
      }

      if (newPassword != confirmPassword) {
        return {
          'success': false,
          'message': 'Passwords do not match',
        };
      }

      final response = await _apiService.post(
        _resetPasswordEndpoint,
        {
          'student_id': studentId,
          'token': token,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      print('📥 Reset Password Response: $response');

      // Enhanced success detection
      final bool isSuccess = _checkSuccess(response) || 
                           response['message']?.toString().toLowerCase().contains('success') == true ||
                           response['message']?.toString().toLowerCase().contains('reset') == true;

      if (isSuccess) {
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
      return _handleError(e);
    }
  }

  // ============ HELPER METHODS ============

  /// Checks if the response indicates success using multiple indicators
  bool _checkSuccess(Map<String, dynamic> response) {
    for (final indicator in _successIndicators) {
      final value = response[indicator];
      if (value == true || value == 'success' || value == 'verified') {
        return true;
      }
    }
    return false;
  }

  /// Extracts token from response using multiple possible keys
  String? _extractToken(Map<String, dynamic> response) {
    for (final key in _tokenKeys) {
      final token = response[key];
      if (token != null && token.toString().isNotEmpty) {
        return token.toString();
      }
    }
    
    // Debug: Log available keys for token detection
    print('🔍 DEBUG - Available keys: ${response.keys}');
    for (final key in response.keys) {
      if (key.toString().toLowerCase().contains('token')) {
        print('🎯 Found potential token key: $key = ${response[key]}');
        final token = response[key];
        if (token != null && token.toString().isNotEmpty) {
          return token.toString();
        }
      }
    }
    
    return null;
  }

  /// Checks if response contains valid user data
  bool _hasUserData(Map<String, dynamic> response) {
    return response['student_id'] != null && 
           response['student_id'].toString().isNotEmpty;
  }

  /// Standardized error handling
  Map<String, dynamic> _handleError(dynamic error) {
    String errorMessage = error.toString();
    
    // Provide more user-friendly error messages
    if (errorMessage.contains('Connection') || errorMessage.contains('Network')) {
      errorMessage = 'Network connection error. Please check your internet connection.';
    } else if (errorMessage.contains('Timeout')) {
      errorMessage = 'Request timeout. Please try again.';
    } else if (errorMessage.contains('401') || errorMessage.contains('Unauthorized')) {
      errorMessage = 'Authentication failed. Please check your credentials.';
    } else if (errorMessage.contains('500') || errorMessage.contains('Internal Server')) {
      errorMessage = 'Server error. Please try again later.';
    }

    return {
      'success': false,
      'message': errorMessage,
    };
  }

  /// Utility method to validate password strength
  static bool isPasswordStrong(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  /// Utility method to validate student ID format
  static bool isValidStudentId(String studentId) {
    return studentId.isNotEmpty && studentId.length >= 3;
  }
}