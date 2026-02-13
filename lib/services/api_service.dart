import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final _storage = const FlutterSecureStorage();
  String? _token;

  String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://192.168.100.19:8000';
    }
    return 'http://192.168.100.19:8000';
  }

  /// Charge le token depuis FlutterSecureStorage si non déjà chargé
  Future<void> loadTokenIfNeeded() async {
    if (_token == null) {
      _token = await _storage.read(key: 'token');
      developer.log(
        'Token loaded: ${_token != null ? "present (${_token!.substring(0, 20)}...)" : "MISSING"}',
        name: 'ApiService'
      );
    }
  }

  /// Définit ou met à jour le token manuellement
  void setToken(String? token) {
    _token = token;
    if (token != null) {
      _storage.write(key: 'token', value: token);
      developer.log('Token saved: ${token.substring(0, 20)}...', name: 'ApiService');
    } else {
      _storage.delete(key: 'token');
      developer.log('Token cleared', name: 'ApiService');
    }
  }

  /// GET request avec token automatique
  Future<http.Response> get(String endpoint) async {
    await loadTokenIfNeeded();

    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    developer.log(
      'GET $endpoint - Token: ${_token != null ? "present" : "MISSING"}',
      name: 'ApiService'
    );

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      developer.log('GET $endpoint: ${response.statusCode}', name: 'ApiService');
      if (response.statusCode == 401) {
        developer.log('401 Unauthorized - Headers sent: $headers', name: 'ApiService');
      }
      return response;
    } catch (e) {
      developer.log('Error GET $endpoint', name: 'ApiService', error: e);
      rethrow;
    }
  }

  /// POST request avec token automatique
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    await loadTokenIfNeeded();

    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    developer.log(
      'POST $endpoint - Token: ${_token != null ? "present" : "MISSING"}',
      name: 'ApiService'
    );

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      developer.log('POST $endpoint: ${response.statusCode}', name: 'ApiService');
      if (response.statusCode == 401) {
        developer.log('401 Unauthorized - Headers sent: $headers', name: 'ApiService');
      }
      return response;
    } catch (e) {
      developer.log('Error POST $endpoint', name: 'ApiService', error: e);
      rethrow;
    }
  }

  /// PUT request avec token automatique
  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    await loadTokenIfNeeded();

    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    developer.log(
      'PUT $endpoint - Token: ${_token != null ? "present" : "MISSING"}',
      name: 'ApiService'
    );

    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      developer.log('PUT $endpoint: ${response.statusCode}', name: 'ApiService');
      if (response.statusCode == 401) {
        developer.log('401 Unauthorized - Headers sent: $headers', name: 'ApiService');
      }
      return response;
    } catch (e) {
      developer.log('Error PUT $endpoint', name: 'ApiService', error: e);
      rethrow;
    }
  }

  /// Supprime le token stocké et mémoire
  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: 'token');
    developer.log('Token cleared from storage', name: 'ApiService');
  }
}


