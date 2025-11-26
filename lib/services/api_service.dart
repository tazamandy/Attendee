import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = AppConstants.baseUrl;

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = json.decode(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else {
      final errorMessage = responseBody['error'] ?? 'Unknown error occurred';
      throw Exception(errorMessage);
    }
  }
}