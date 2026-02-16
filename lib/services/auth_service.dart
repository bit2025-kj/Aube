import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aube/services/api_service.dart';

class AuthService {
  final ApiService _apiService;
  final _storage = const FlutterSecureStorage();

  AuthService(this._apiService);

  /// Connexion avec email ou numéro de téléphone
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final response = await _apiService.post('/v1/auth/login', {
      'identifier': identifier,  // Peut être email ou numéro
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      // ✅ Hack: Backend now returns user object with id
      if (data['user'] != null && data['user']['id'] != null) {
        await _storage.write(key: 'user_id', value: data['user']['id']);
      }
      await _storage.write(key: 'token', value: token);
      _apiService.setToken(token);
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  /// Inscription avec numéro de téléphone obligatoire et email optionnel
  Future<Map<String, dynamic>> signup({
    required String phoneNumber,
    required String password,
    String? email,
    String? fullName,
  }) async {
    final body = {
      'phone_number': phoneNumber,
      'password': password,
      if (email != null && email.isNotEmpty) 'email': email,
      if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
    };

    final response = await _apiService.post('/v1/auth/signup', body);

    if (response.statusCode == 201) {
      // Signup successful, now login to get token
      return await login(phoneNumber, password);
    } else if (response.statusCode == 409) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Phone number or email already exists');
    } else {
      throw Exception('Signup failed: ${response.body}');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    _apiService.setToken(null);
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      _apiService.setToken(token);
      return true;
    }
    return false;
  }

  Future<String?> getSavedToken() async {
    return await _storage.read(key: 'token');
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }
}


