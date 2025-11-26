import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../service/auth_service.dart';
import '../model/auth_models.dart';

class AuthProvider with ChangeNotifier {
  late final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  bool _initialized = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _initialized;

  AuthProvider() {
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    try {
      // Initialize AuthService after a brief delay to ensure dotenv is ready
      await Future.delayed(const Duration(milliseconds: 100));
      _authService = AuthService();
      _user = await _authService.getCurrentUser();
    } catch (e) {
      print('Error initializing auth: $e');
      _authService = AuthService(); // Still initialize with defaults
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(
        LoginRequest(email: email, password: password),
      );

      _user = User.fromJson(response);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> register(RegisterRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.register(request);
      // For mock mode, registration returns without auto-login
      // User needs to verify email first
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> verifyEmail(String email, String verificationCode) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.verifyEmail(email, verificationCode);
      _user = await _authService.getCurrentUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
