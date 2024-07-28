import 'package:dating_app/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class ApiService {
  static String baseUrl = 'http://localhost:8080';
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final logger = Logger();
  // Clear all stored user data
  Future<void> clearUser() async {
    await storage.deleteAll();
  }

  Future<bool> checkUniqueEmail(String email) async {
    try {
      var client = http.Client();
      final response = await client.post(
        Uri.parse('$baseUrl/check-email'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['unique'] ?? false;
      } else {
        logger.e('Email check failed: ${response.body}');
        return false;
      }
    } catch (e) {
      logger.e('Email check error: $e');
      return false;
    }
  }

  // Check if mobile is unique
  Future<bool> checkUniqueMobile(String mobile) async {
    try {
      var client = http.Client();
      final response = await client.post(
        Uri.parse('$baseUrl/check-mobile'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'mobile': mobile}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['unique'] ?? false;
      } else {
        logger.e('Mobile check failed: ${response.body}');
        return false;
      }
    } catch (e) {
      logger.e('Mobile check error: $e');
      return false;
    }
  }

  // Check if user handle is unique
  Future<bool> checkUniqueUserHandle(String userHandle) async {
    try {
      var client = http.Client();
      final response = await client.post(
        Uri.parse('$baseUrl/check-user-handle'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'userHandle': userHandle}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['unique'] ?? false;
      } else {
        logger.e('User handle check failed: ${response.body}');
        return false;
      }
    } catch (e) {
      logger.e('User handle check error: $e');
      return false;
    }
  }

  // Signup request
  Future<void> signupRequest() async {
    String? firstName = await storage.read(key: 'firstName');
    String? lastName = await storage.read(key: 'lastName');
    String? password = await storage.read(key: 'password');
    String? email = await storage.read(key: 'email');
    String? mobile = await storage.read(key: 'mobile');
    String? interests = await storage.read(key: 'interests');
    String? description = await storage.read(key: 'description');
    String? location = await storage.read(key: 'location');
    String? birthDate = await storage.read(key: 'birthDate');
    String? userHandle = await storage.read(key: 'userHandle');

    Map<String, String> requestData = {
      'firstName': firstName ?? '',
      'location': location ?? '',
      'birthDate': birthDate ?? '',
      'lastName': lastName ?? '',
      'email': email ?? '',
      'mobile': mobile ?? '',
      'password': password ?? '',
      'interests': interests ?? '',
      'description': description ?? '',
      'userHandle': userHandle ?? ''
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestData),
      );
      if (response.statusCode == 200) {
        logger.i('Signup successful: ${response.body}');
        await clearUser();
      } else {
        logger.e('Signup failed: ${response.body} ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Signup error: $e');
    }
  }

  // Login request with JWT token storage
  Future<bool?> loginRequest() async {
    if (await isLoggedIn() == false) {
      String? password = await storage.read(key: 'password');
      String? email = await storage.read(key: 'email');
      String? mobile = await storage.read(key: 'mobile');

      Map<String, String> request = {
        'email': email ?? '',
        'mobile': mobile ?? '',
        'password': password ?? '',
      };

      try {
        var client = http.Client();
        final response = await client.post(
          Uri.parse('$baseUrl/login'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(request),
        );
        if (response.statusCode == 200) {
          // Save JWT token
          final responseData = jsonDecode(response.body);
          if (responseData['token'] != null) {
            await storage.write(key: 'jwt_token', value: responseData['token']);
          }
          logger.i('Login successful: ${response.body}');
          return true;
        } else {
          logger.e('Login failed: ${response.body}');
          return false;
        }
      } catch (e) {
        logger.e('Login error: $e');
        return false;
      }
    }
    return false;
  }

  // Check if user is logged in by verifying JWT token existence
  Future<bool> isLoggedIn() async {
    String? token = await storage.read(key: 'jwt_token');
    return token != null && token.isNotEmpty;
  }

  // Logout and clear stored JWT token
  Future<void> logout() async {
    String? token = await storage.read(key: 'jwt_token');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await storage.delete(key: 'jwt_token');
        logger.i('Logout successful');
        clearUser();
      } else {
        logger.e('Logout failed: ${response.body}');
      }
    } catch (e) {
      logger.e('Logout error: $e');
    }
  }

  // Get stored JWT token
  Future<String?> getAuthToken() async {
    return await storage.read(key: 'jwt_token');
  }

  // Example function to make an authenticated request
  Future<Map<String, dynamic>> getUser() async {
    logger.i('Running getuser()');
    String? token = await getAuthToken();
    if (token == null) {
      throw Exception('No JWT token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        logger.i(response.body);
        return jsonDecode(response.body);
      } else {
        logger.e(response.body);
      }
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
    return {};
  }

  // Example function to make an authenticated request
  Future<List<dynamic>> searchUsers() async {
    String? searchTerm = await storage.read(key: 'searchTerm');
    logger.i('Running SearchUsers()');

    String? token = await getAuthToken();
    if (token == null) {
      throw Exception('No JWT token found');
    }

    Map<String, String> request = {
      'searchTerm': searchTerm ?? '',
    };

    try {
      var client = http.Client();
      final response = await client.post(
        Uri.parse('$baseUrl/get-searched-users'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        logger.i('Search successful');
        return responseData;
      } else {
        logger.e('Search failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      logger.e('Search error: $e');
      return [];
    }
  }
}
