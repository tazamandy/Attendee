import 'dart:convert';
import '../models/user_model.dart';
import './api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _apiService.post(ApiConstants.login, request.toJson());
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'message': error['message'] ?? 'Login failed'};
    }
  }

  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    final response = await _apiService.post(ApiConstants.register, request.toJson());
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'message': error['message'] ?? 'Registration failed'};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final request = ForgotPasswordRequest(email: email);
    final response = await _apiService.post(ApiConstants.forgotPassword, request.toJson());
    
    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Password reset email sent'};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'message': error['message'] ?? 'Failed to send reset email'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    final request = ResetPasswordRequest(token: token, newPassword: newPassword);
    final response = await _apiService.post(ApiConstants.resetPassword, request.toJson());
    
    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Password reset successful'};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'message': error['message'] ?? 'Password reset failed'};
    }
  }

  Future<User?> getProfile(String token) async {
    final response = await _apiService.get(ApiConstants.profile, token: token);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    }
    return null;
  }
}