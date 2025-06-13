import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService with ChangeNotifier {
  String? _token;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;


  final String baseUrl = "http://localhost:3000/api/users";

  /// تسجيل الدخول
  Future<void> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _token = responseData['token'];
        _isLoggedIn = true;
        notifyListeners();
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Login failed';
        throw Exception(error);
      }
    } catch (e) {
      print("Login error: $e");
      _isLoggedIn = false;
    }
  }

  /// إنشاء حساب جديد
  Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
    required String userType,
  }) async {
    final url = Uri.parse("$baseUrl/register");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
          "userType": userType,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final error = jsonDecode(response.body)['message'];
        print("Register error: $error");
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }

  /// تسجيل الخروج
  void logout() {
    _token = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
