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

  // ADD THE MISSING PASSWORD RESET METHODS:

  // Request password reset method
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

  // Reset password method
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

  // Existing verifyEmail method
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

  // Existing login method
  Future<bool> login(String studentId, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(studentId, password);
      _isLoading = false;

      if (result['success']) {
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

  // Existing register method
  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(userData);
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

  // Existing methods
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
}