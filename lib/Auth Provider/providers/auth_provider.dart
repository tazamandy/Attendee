import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final result = await _authService.login(email, password);
      if (result['success']) {
        _token = result['data']['token'];
        _user = await _authService.getProfile(_token!);
        notifyListeners();
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    try {
      final result = await _authService.register(request);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final result = await _authService.forgotPassword(email);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    try {
      final result = await _authService.resetPassword(token, newPassword);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}