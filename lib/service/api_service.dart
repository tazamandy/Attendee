import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  late final String baseUrl;

  ApiService() {
    // Get base URL safely with fallback
    baseUrl = _getBaseUrl();
  }

  String _getBaseUrl() {
    try {
      return dotenv.env['API_BASE_URL'] ?? 'http://localhost:9090';
    } catch (e) {
      print('Warning: Could not get API_BASE_URL from env: $e');
      return 'http://localhost:9090';
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      print('API Call: $baseUrl$endpoint');
      print('Data: $data');

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('API call error: $e');
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers ?? {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
