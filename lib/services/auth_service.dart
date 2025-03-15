import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://libarybackend.fudedevelopments.workers.dev',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );
  static const String _tokenKey = 'auth_token';
  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Make sure SharedPreferences is initialized
      if (!_initialized) {
        await init();
      }

      final response = await _dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );
      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _prefs?.setString(_tokenKey, token);
        return response.data;
      }
      throw Exception('Login failed');
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    if (!_initialized) {
      await init();
    }
    await _prefs?.remove(_tokenKey);
  }

  Future<String?> getToken() async {
    if (!_initialized) {
      await init();
    }
    return _prefs?.getString(_tokenKey);
  }
}
