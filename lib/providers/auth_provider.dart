// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../config/constants.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _resetToken;
  String? _resetStudentId;
  String? _pendingEmail; // NEW: Store email for verification flow
  String? _pendingStudentId; // NEW: Store student ID for verification flow

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get resetToken => _resetToken;
  String? get resetStudentId => _resetStudentId;
  String? get pendingEmail => _pendingEmail; // NEW: Getter for pending email
  String? get pendingStudentId => _pendingStudentId; // NEW: Getter for pending student ID

  // Helper getters for user properties
  String? get userId => _currentUser?['student_id'] ?? _currentUser?['userId'];
  String? get email => _currentUser?['email'];
  String? get username => _currentUser?['username'] ?? _currentUser?['first_name'];
  String? get role => _currentUser?['role'];
  bool get isVerified => _currentUser?['is_verified'] ?? _currentUser?['verified'] ?? false;
  String? get firstName => _currentUser?['first_name'] ?? _currentUser?['firstName'];
  String? get lastName => _currentUser?['last_name'] ?? _currentUser?['lastName'];
  String? get course => _currentUser?['course'];
  String? get yearLevel => _currentUser?['year_level']?.toString() ?? _currentUser?['yearLevel']?.toString();
  String? get qrCodeData => _currentUser?['qr_code_data'] ?? _currentUser?['qrCodeData'];
  String? get qrCodeType => _currentUser?['qr_code_type'] ?? _currentUser?['qrCodeType'];

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _errorMessage = null;
    _pendingEmail = null;
    _pendingStudentId = null;
    
    print('🔐 AUTH PROVIDER - Starting registration');
    print('📤 Sending data: $userData');

    try {
      final result = await _authService.register(userData);
      _setLoading(false);

      print('📥 Auth Provider Response: $result');
      print('🎯 REGISTRATION RESULT: ${result['success']}');

      // ENHANCED: Check for successful registration that requires verification
      if (result['success'] == true || _isVerificationRequired(result)) {
        print('✅ AUTH PROVIDER - Registration successful, verification required');
        
        // Store pending registration data for verification flow
        _pendingEmail = userData['email'];
        _pendingStudentId = userData['student_id'];
        
        return {
          'success': true,
          'requiresVerification': true,
          'message': result['message'] ?? 'Registration successful. Please check your email for verification.',
          'email': _pendingEmail,
          'studentId': _pendingStudentId,
        };
      } else {
        _errorMessage = result['message'] ?? 'Registration failed';
        print('❌ AUTH PROVIDER - Registration failed: $_errorMessage');
        
        return {
          'success': false,
          'requiresVerification': false,
          'message': _errorMessage,
        };
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Registration error: $e';
      print('💥 AUTH PROVIDER - Registration exception: $e');
      
      return {
        'success': false,
        'requiresVerification': false,
        'message': _errorMessage,
      };
    }
  }

  // NEW: Helper method to check if verification is required
  bool _isVerificationRequired(Map<String, dynamic> result) {
    final message = result['message']?.toString().toLowerCase() ?? '';
    return message.contains('check your email') ||
           message.contains('verification code') ||
           message.contains('verify your email') ||
           message.contains('pending verification');
  }

  // UPDATED: Login method remains the same
  Future<bool> login(String studentId, String password) async {
    _setLoading(true);
    _errorMessage = null;

    print('🔐 AUTH PROVIDER - Starting login for: $studentId');

    try {
      final result = await _authService.login(studentId, password);
      _setLoading(false);

      print('📥 Login Response: $result');

      if (result['success'] == true && result['user'] != null) {
        _currentUser = _extractUserData(result['user']);
        
        // Save user data to storage
        await _storageService.saveUserData(_currentUser!);
        
        print('✅ AUTH PROVIDER - Login successful for: ${_currentUser?['email']}');
        print('👤 User data saved: $_currentUser');
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        print('❌ AUTH PROVIDER - Login failed: $_errorMessage');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Login error: $e';
      print('💥 AUTH PROVIDER - Login exception: $e');
      return false;
    }
  }

  // NEW: Method to verify email after registration
  Future<bool> verifyRegistrationEmail(String email, String code) async {
    _setLoading(true);
    _errorMessage = null;

    print('🔐 AUTH PROVIDER - Verifying registration email: $email');

    try {
      final result = await _authService.verifyEmail(email, code);
      _setLoading(false);

      print('📥 Verify Registration Email Response: $result');

      if (result['success'] == true) {
        print('✅ AUTH PROVIDER - Registration email verification successful');
        
        // Clear pending data after successful verification
        _pendingEmail = null;
        _pendingStudentId = null;
        
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Email verification failed';
        print('❌ AUTH PROVIDER - Registration email verification failed: $_errorMessage');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString();
      print('💥 AUTH PROVIDER - Registration email verification exception: $e');
      return false;
    }
  }

  // NEW: Method to clear pending registration
  void clearPendingRegistration() {
    _pendingEmail = null;
    _pendingStudentId = null;
    _errorMessage = null;
    notifyListeners();
  }

  // NEW: Check if there's a pending registration that needs verification
  bool get hasPendingVerification => _pendingEmail != null && _pendingStudentId != null;

  // Rest of your existing methods remain the same...
  Future<bool> requestPasswordReset(String studentId) async {
    _setLoading(true);
    _errorMessage = null;
    _resetToken = null;
    _resetStudentId = null;

    print('🔐 AUTH PROVIDER - Requesting password reset for: $studentId');

    try {
      final result = await _authService.requestPasswordReset(studentId);
      _setLoading(false);

      print('📥 Request Password Reset Response: $result');

      if (result['success'] == true) {
        print('✅ AUTH PROVIDER - Password reset request successful');
        print('📧 Email: ${result['email']}');
        print('🎫 Student ID: ${result['student_id']}');
        
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to request password reset';
        print('❌ AUTH PROVIDER - Password reset request failed: $_errorMessage');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString();
      print('💥 AUTH PROVIDER - Password reset request exception: $e');
      return false;
    }
  }

  Future<bool> verifyResetCode(String studentId, String code) async {
    _setLoading(true);
    _errorMessage = null;
    _resetToken = null;

    print('🔐 AUTH PROVIDER - Verifying reset code');
    print('📤 Student ID: $studentId, Code: $code');

    try {
      final result = await _authService.verifyResetCode(studentId, code);
      _setLoading(false);

      print('📥 Verify Reset Code Provider Response: $result');

      if (result['success'] == true) {
        _resetToken = _extractToken(result);
        _resetStudentId = studentId;
        
        if (_resetToken == null) {
          _errorMessage = 'Reset token not found in response';
          print('❌ AUTH PROVIDER - Token extraction failed');
          return false;
        }

        print('✅ AUTH PROVIDER - Reset code verification successful');
        print('🎯 Token: $_resetToken');
        print('📧 Email: ${result['email']}');
        print('🎫 Student ID: ${result['student_id']}');
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Verification failed';
        print('❌ AUTH PROVIDER - Reset code verification failed: $_errorMessage');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Verification error: $e';
      print('💥 AUTH PROVIDER - Reset code verification exception: $e');
      return false;
    }
  }

  Future<bool> resetPassword(
    String studentId,
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    print('🔐 AUTH PROVIDER - Resetting password');
    print('📤 Student ID: $studentId, Token: $token');

    if (token.isEmpty) {
      _setLoading(false);
      _errorMessage = 'Reset token is required';
      print('❌ AUTH PROVIDER - Reset token is empty');
      return false;
    }

    if (newPassword != confirmPassword) {
      _setLoading(false);
      _errorMessage = 'Passwords do not match';
      print('❌ AUTH PROVIDER - Passwords do not match');
      return false;
    }

    try {
      final result = await _authService.resetPassword(
        studentId,
        token,
        newPassword,
        confirmPassword,
      );
      _setLoading(false);

      print('📥 Reset Password Response: $result');

      if (result['success'] == true) {
        print('✅ AUTH PROVIDER - Password reset successful');
        _clearResetData();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to reset password';
        print('❌ AUTH PROVIDER - Password reset failed: $_errorMessage');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString();
      print('💥 AUTH PROVIDER - Password reset exception: $e');
      return false;
    }
  }

  String? _extractToken(Map<String, dynamic> result) {
    final token = result['token'] ?? 
                 result['reset_token'] ?? 
                 result['resetToken'] ?? 
                 result['access_token'];
    
    if (token != null) {
      return token.toString();
    }
    
    print('🔍 DEBUG - Searching for token in response keys: ${result.keys}');
    
    for (var key in result.keys) {
      if (key.toString().toLowerCase().contains('token')) {
        print('🎯 Found potential token key: $key = ${result[key]}');
        return result[key]?.toString();
      }
    }
    
    return null;
  }

  Map<String, dynamic> _extractUserData(dynamic userData) {
    if (userData is Map<String, dynamic>) {
      return userData;
    }
    
    // Fallback: create basic user data structure
    return {
      'student_id': userData?.toString() ?? '',
      'email': '',
      'first_name': '',
      'last_name': '',
    };
  }

  void _clearResetData() {
    _resetToken = null;
    _resetStudentId = null;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    final userData = await _storageService.getUserData();
    if (userData != null) {
      _currentUser = userData;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _clearResetData();
    _pendingEmail = null;
    _pendingStudentId = null;
    await _storageService.clearUserData();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearResetToken() {
    _clearResetData();
  }

  void debugResetToken() {
    print('🔍 DEBUG - Reset Token: $_resetToken');
    print('🔍 DEBUG - Reset Token Type: ${_resetToken?.runtimeType}');
    print('🔍 DEBUG - Reset Token Length: ${_resetToken?.length}');
    print('🔍 DEBUG - Reset Student ID: $_resetStudentId');
    print('🔍 DEBUG - Has Token: ${_resetToken != null && _resetToken!.isNotEmpty}');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  bool isResetFlowReady() {
    return _resetToken != null && 
           _resetToken!.isNotEmpty && 
           _resetStudentId != null;
  }

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null && _currentUser!['student_id'] != null;

  // Get user display name
  String get displayName {
    if (_currentUser == null) return '';
    
    final firstName = _currentUser!['first_name'] ?? _currentUser!['firstName'] ?? '';
    final lastName = _currentUser!['last_name'] ?? _currentUser!['lastName'] ?? '';
    
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    }
    
    return _currentUser!['username'] ?? _currentUser!['email'] ?? '';
  }
}