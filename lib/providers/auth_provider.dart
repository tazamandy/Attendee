// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/auth_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _resetToken;
  String? _resetStudentId;
  Map<String, dynamic>? _lastLoginData; // Added missing property

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get resetToken => _resetToken;
  String? get resetStudentId => _resetStudentId;
  Map<String, dynamic>? get lastLoginData => _lastLoginData; // Added missing getter

  // Enhanced register method
  Future<bool> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _errorMessage = null;
    
    print('🔐 AUTH PROVIDER - Starting registration');
    print('📤 Sending data: $userData');

    try {
      final result = await _authService.register(userData);
      _setLoading(false);

      print('📥 Auth Provider Response: $result');

      if (result['success'] == true) {
        print('✅ AUTH PROVIDER - Registration successful');
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Registration failed';
        print('❌ AUTH PROVIDER - Registration failed: $_errorMessage');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Network error: $e';
      print('💥 AUTH PROVIDER - Exception: $e');
      return false;
    }
  }

  // Enhanced login method
  Future<bool> login(String studentId, String password) async {
    _setLoading(true);
    _errorMessage = null;

    print('🔐 AUTH PROVIDER - Starting login for: $studentId');

    try {
      final result = await _authService.login(studentId, password);
      _setLoading(false);

      print('📥 Login Response: $result');

      if (result['success'] == true && result['user'] != null) {
        _currentUser = result['user'];
        
        final userData = {
          'student_id': _currentUser!.userId,
          'email': _currentUser!.email,
          'username': _currentUser!.username,
          'role': _currentUser!.role,
          'is_verified': _currentUser!.isVerified,
          'first_name': _currentUser!.firstName,
          'last_name': _currentUser!.lastName,
          'course': _currentUser!.course,
          'year_level': _currentUser!.yearLevel,
          'qr_code_data': _currentUser!.qrCodeData,
          'qr_code_type': _currentUser!.qrCodeType,
        };
        
        await _storageService.saveUserData(userData);
        
        // Initialize lastLoginData to prevent null errors
        _lastLoginData = {
          'timestamp': DateTime.now().toIso8601String(),
          'student_id': studentId,
          'login_time': DateTime.now().millisecondsSinceEpoch,
        };
        
        print('✅ AUTH PROVIDER - Login successful for: ${_currentUser!.email}');
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

  // ✅ FIXED: Enhanced password reset request method
  Future<bool> requestPasswordReset(String studentId) async {
    _setLoading(true);
    _errorMessage = null;
    _resetToken = null; // Clear previous token
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

  // ✅ FIXED: Enhanced reset code verification with better token handling
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
        // ✅ FIXED: Multiple ways to extract token
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

  // ✅ FIXED: Enhanced reset password with validation
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

    // Validate token presence
    if (token.isEmpty) {
      _setLoading(false);
      _errorMessage = 'Reset token is required';
      print('❌ AUTH PROVIDER - Reset token is empty');
      return false;
    }

    // Validate password match
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
        // Clear reset data after successful reset
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

  // ✅ NEW: Helper method to extract token from response
  String? _extractToken(Map<String, dynamic> result) {
    // Try different possible token keys
    final token = result['token'] ?? 
                 result['reset_token'] ?? 
                 result['resetToken'] ?? 
                 result['access_token'];
    
    if (token != null) {
      return token.toString();
    }
    
    // If no token found in common keys, check the entire response
    print('🔍 DEBUG - Searching for token in response keys: ${result.keys}');
    
    for (var key in result.keys) {
      if (key.toString().toLowerCase().contains('token')) {
        print('🎯 Found potential token key: $key = ${result[key]}');
        return result[key]?.toString();
      }
    }
    
    return null;
  }

  // ✅ NEW: Clear reset data
  void _clearResetData() {
    _resetToken = null;
    _resetStudentId = null;
    notifyListeners();
  }

  // Email verification for registration
  Future<bool> verifyEmail(String email, String code) async {
    _setLoading(true);
    _errorMessage = null;

    print('🔐 AUTH PROVIDER - Verifying email for registration');
    print('📤 Email: $email, Code: $code');

    try {
      final result = await _authService.verifyEmail(email, code);
      _setLoading(false);

      print('📥 Verify Email Response: $result');

      if (result['success'] == true) {
        print('✅ AUTH PROVIDER - Email verification successful');
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Email verification failed';
        print('❌ AUTH PROVIDER - Email verification failed: $_errorMessage');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString();
      print('💥 AUTH PROVIDER - Email verification exception: $e');
      return false;
    }
  }

  Future<void> loadUserData() async {
    final userData = await _storageService.getUserData();
    if (userData != null) {
      _currentUser = User.fromJson(userData);
      
      // Initialize lastLoginData when loading user data
      _lastLoginData = {
        'timestamp': DateTime.now().toIso8601String(),
        'student_id': _currentUser?.userId ?? '',
        'login_time': DateTime.now().millisecondsSinceEpoch,
      };
      
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _lastLoginData = null;
    _clearResetData();
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

  // Method to update last login data
  void updateLastLoginData(Map<String, dynamic> data) {
    _lastLoginData = data;
    notifyListeners();
  }

  // Enhanced debug method
  void debugResetToken() {
    print('🔍 DEBUG - Reset Token: $_resetToken');
    print('🔍 DEBUG - Reset Token Type: ${_resetToken?.runtimeType}');
    print('🔍 DEBUG - Reset Token Length: ${_resetToken?.length}');
    print('🔍 DEBUG - Reset Student ID: $_resetStudentId');
    print('🔍 DEBUG - Has Token: ${_resetToken != null && _resetToken!.isNotEmpty}');
    print('🔍 DEBUG - Last Login Data: $_lastLoginData');
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

  // Helper method to check if user has last login data
  bool get hasLastLoginData => _lastLoginData != null;
}