import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  String? _token;
  bool _isLoggedIn = false;
  String? _userId;
  String? _selectedBabyId;
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  String? get userId => _userId;
  String? get selectedBabyId => _selectedBabyId;


  final String baseUrl = "http://localhost:3000/api/users";
  List<Map<String, dynamic>> _babies = [];
  List<Map<String, dynamic>> get babies => _babies;

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

        // حفظ البيانات محليًا
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user_id', _userId!);

        // جلب الأطفال
        await fetchBabies();

        // اختيار أول طفل تلقائيًا
        if (_babies.isNotEmpty) {
          _selectedBabyId = _babies[0]['_id'];
          await prefs.setString('selected_baby_id', _selectedBabyId!);
        }

        notifyListeners();
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print("Login error: $e");
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  // جلب بيانات الأطفال
  Future<void> fetchBabies() async {
    if (_token == null || _userId == null) return;

    final uri = Uri.parse("http://localhost:3000/api/users/babies");

    try {
      final response = await http.get(
        uri,
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _babies = List<Map<String, dynamic>>.from(data['babies']);
      if (_babies.isNotEmpty && _selectedBabyId == null) {
        _selectedBabyId = _babies.first['_id'];
        }
        notifyListeners();
      } else {
        print("Failed to fetch babies: ${response.body}");
      }
    } catch (e) {
      print("Error fetching babies: $e");
    }
  }



  // تحديث معرف الطفل المحدد + حفظ في SharedPreferences
  Future<void> setSelectedBabyId(String? id) async {
    _selectedBabyId = id;
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setString('selected_baby_id', id);
    } else {
      await prefs.remove('selected_baby_id');
    }

    notifyListeners();
  }

  // تسجيل الخروج
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _selectedBabyId = null;
    _isLoggedIn = false;
    _babies.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('selected_baby_id');

    notifyListeners();
  }

  //  تسجيل حساب جديد
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
        // تسجيل الدخول تلقائيًا بعد التسجيل
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

  //  تسجيل الدخول التلقائي عند إعادة تشغيل التطبيق
  Future<void> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final babyId = prefs.getString('selected_baby_id');

    if (token != null) {
      _token = token;
      _isLoggedIn = true;
      _userId = prefs.getString('user_id');
      _selectedBabyId = babyId;

      await fetchBabies(); //  جلب الأطفال بعد تسجيل الدخول التلقائي

      if (_babies.isNotEmpty && _selectedBabyId == null) {
        _selectedBabyId = _babies.first['_id'];
        await prefs.setString('selected_baby_id', _selectedBabyId!);
      }

      notifyListeners();
    }
  }

  //  الحصول على بيانات الطفل المحدد
  Map<String, dynamic>? get selectedBaby {
    if (_babies.isEmpty || _selectedBabyId == null) return null;
    return _babies.firstWhere(
      (baby) => baby['_id'] == _selectedBabyId,
      orElse: () => _babies.isNotEmpty ? _babies.first : {},
    );
  }

  //  تحديث بيانات الطفل (مثل الاسم أو الجنس)
  Future<void> updateBabyInfo(String babyId, Map<String, dynamic> updatedData) async {
    final url = Uri.parse("http://localhost:3000/api/babies/info/$babyId");
    final token = _token;

    if (token == null) return;

    try {
      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        //  تحديث البيانات المحلية
        final updatedBaby = jsonDecode(response.body)['baby'];
        final index = _babies.indexWhere((baby) => baby['_id'] == babyId);
        if (index != -1) {
          _babies[index] = updatedBaby;
        }

        notifyListeners();
      } else {
        final error = jsonDecode(response.body)['message'];
        print("Update baby info failed: $error");
      }
    } catch (e) {
      print("Error updating baby info: $e");
    }
  }


  Future<void> loadSelectedBabyId() async {
  final prefs = await SharedPreferences.getInstance();
  _selectedBabyId = prefs.getString('selected_baby_id');
}


  //  إضافة طفل جديد
Future<bool> addNewBaby(Map<String, dynamic> babyData) async {
  final url = Uri.parse("http://localhost:3000/api/users/baby");
  final token = _token;

  if (token == null || _userId == null) return false;

  babyData['user'] = _userId;

  try {
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(babyData),
    );

    if (response.statusCode == 201) {
      final newBaby = jsonDecode(response.body)['baby'];
      _babies.add(newBaby);

      // استخدم الدالة لتخزين babyId في SharedPreferences
      await setSelectedBabyId(newBaby['_id']);

      notifyListeners();
      return true;
    } else {
      print("Failed to add baby: ${jsonDecode(response.body)['message']}");
      return false;
    }
  } catch (e) {
    print("Error adding baby: $e");
    return false;
  }
}


  //  الحصول على بيانات الطفل المحدد
  Future<Map<String, dynamic>?> getSelectedBaby() async {
    if (_token == null || _selectedBabyId == null) return null;

    final url = Uri.parse("http://localhost:3000/api/babies/$selectedBabyId");

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Failed to fetch baby details");
        return null;
      }
    } catch (e) {
      print("Error fetching baby details: $e");
      return null;
    }
  }
}