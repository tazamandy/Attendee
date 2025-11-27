import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _userDataKey = 'user_data';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(userData));
    await prefs.setString(_userIdKey, userData['user_id'] ?? '');
    await prefs.setString(_userRoleKey, userData['role'] ?? 'student');
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    
    return null;
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
  }
}