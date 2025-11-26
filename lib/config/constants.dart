// lib/config/constants.dart
class AppConstants {
  static const String appName = "Attendance System";
  // FIX: Make sure this matches your backend URL
  static const String baseUrl = "http://192.168.1.13:9090";
  
  // API Endpoints
  static const String loginEndpoint = "/login";
  static const String registerEndpoint = "/register";
  static const String verifyEmailEndpoint = "/verify";
  static const String forgotPasswordEndpoint = "/forgot-password";
  static const String resetPasswordEndpoint = "/reset-password";
  static const String userProfileEndpoint = "/user/";
}