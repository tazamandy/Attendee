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
      print('🌐 API SERVICE - POST Request to: $baseUrl$endpoint');
      print('📤 Request Data: $data');

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      print('📥 API Response Status: ${response.statusCode}');
      print('📥 API Response Body: ${response.body}');

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    } on http.ClientException catch (e) {
      throw Exception('HTTP Client error: $e');
    } catch (e) {
      // Handle timeout and all other exceptions
      if (e.toString().contains('Timeout') || e.toString().contains('timed out')) {
        throw Exception('Request timeout. Please try again.');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      print('🌐 API SERVICE - GET Request to: $baseUrl$endpoint');

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📥 API Response Status: ${response.statusCode}');
      print('📥 API Response Body: ${response.body}');

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    } on http.ClientException catch (e) {
      throw Exception('HTTP Client error: $e');
    } catch (e) {
      // Handle timeout and all other exceptions
      if (e.toString().contains('Timeout') || e.toString().contains('timed out')) {
        throw Exception('Request timeout. Please try again.');
      }
      throw Exception('Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    // Handle empty response body
    if (response.body.isEmpty) {
      if (statusCode >= 200 && statusCode < 300) {
        return {};
      } else {
        throw Exception('Server returned empty response with status: $statusCode');
      }
    }

    // Handle JSON decoding errors
    dynamic responseBody;
    try {
      responseBody = json.decode(response.body);
    } catch (e) {
      throw Exception('Invalid server response format');
    }

    print('🔧 API SERVICE - Handling response with status: $statusCode');

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else {
      // Extract error message from response body
      String errorMessage = 'Unknown error occurred';
      
      if (responseBody is Map<String, dynamic>) {
        errorMessage = responseBody['error'] ?? 
                      responseBody['message'] ?? 
                      responseBody['detail'] ?? 
                      'Server error: $statusCode';
      } else if (responseBody is String) {
        errorMessage = responseBody;
      }
      
      // Preserve specific error messages from backend
      if (errorMessage.contains('Email already registered and pending verification')) {
        throw Exception('Email already registered and pending verification. Please check your email or wait for the verification to expire.');
      } else if (errorMessage.contains('Email already exists')) {
        throw Exception('Email already exists');
      } else if (errorMessage.contains('Student ID already exists')) {
        throw Exception('Student ID already exists');
      }
      
      throw Exception(errorMessage);
    }
  }
}