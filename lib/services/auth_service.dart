import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService with ChangeNotifier {
  String? _token;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;

  String? _userId;
  String? get userId => _userId;

  String? selectedBabyId; // ← تُستخدم لربط الموعد بالطفل المناسب

  final String baseUrl = "http://localhost:3000/api/users";

  // Getter يستخدم بسهولة في الربط بالباك
  Map<String, String> get authHeaders {
    return {
      "Authorization": "Bearer $_token",
      "Content-Type": "application/json",
    };
  }

  // تسجيل الدخول
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

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['token'] != null) {
        _token = responseData['token'];
        _isLoggedIn = true;
        _userId = responseData['user']['_id'];
        notifyListeners();
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print("Login error: $e");
      _isLoggedIn = false;
    }
  }
//لتحديث الواجهة
  Future<void> setSelectedBabyId(String id) async {
  selectedBabyId = id;
  notifyListeners();
}


  // تسجيل حساب جديد ثم تسجيل دخول تلقائي
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
        await login(email, password);
        return _isLoggedIn;
      } else {
        final error = jsonDecode(response.body)['message'];
        print("Register error: $error");
        return false;
      }
    } catch (e) {
      print("Exception during registration: $e");
      return false;
    }
  }

  void logout() {
    _token = null;
    _userId = null;
    selectedBabyId = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
