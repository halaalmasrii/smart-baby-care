
class ValidationUtils {
  // ✅ التحقق من صحة الإيميل
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
      multiLine: false,
    );
    return emailRegex.hasMatch(email);
  }

  // ✅ التحقق من طول الباسورد
  static bool isValidPassword(String? password) {
    return password != null && password.length >= 8;
  }
}