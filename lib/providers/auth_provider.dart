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

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Enhanced register method with detailed logging
  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    print('🔐 AUTH PROVIDER - Starting registration');
    print('📤 Sending data: $userData');

    try {
      final result = await _authService.register(userData);
      _isLoading = false;

      print('📥 Auth Provider Response: $result');

      if (result['success'] == true) {
        print('✅ AUTH PROVIDER - Registration successful');
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Registration failed';
        print('❌ AUTH PROVIDER - Registration failed: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Network error: $e';
      print('💥 AUTH PROVIDER - Exception: $e');
      notifyListeners();
      return false;
    }
  }

  // Enhanced login method
  Future<bool> login(String studentId, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    print('🔐 AUTH PROVIDER - Starting login for: $studentId');

    try {
      final result = await _authService.login(studentId, password);
      _isLoading = false;

      print('📥 Login Response: $result');

      if (result['success'] == true && result['user'] != null) {
        _currentUser = result['user'];
        
        // Convert User object to Map for storage
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
        print('✅ AUTH PROVIDER - Login successful for: ${_currentUser!.email}');
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        print('❌ AUTH PROVIDER - Login failed: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Login error: $e';
      print('💥 AUTH PROVIDER - Login exception: $e');
      notifyListeners();
      return false;
    }
  }

  // Password reset methods
  Future<bool> requestPasswordReset(String studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.requestPasswordReset(studentId);
      _isLoading = false;

      if (result['success']) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(
    String studentId,
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.resetPassword(
        studentId,
        token,
        newPassword,
        confirmPassword,
      );
      _isLoading = false;

      if (result['success']) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Email verification
  Future<bool> verifyEmail(String email, String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.verifyEmail(email, code);
      _isLoading = false;

      if (result['success']) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUserData() async {
    final userData = await _storageService.getUserData();
    if (userData != null) {
      _currentUser = User.fromJson(userData);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storageService.clearUserData();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}