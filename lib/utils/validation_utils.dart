
class ValidationUtils {
  //  التحقق من صيغة الاسم
  static bool isValidName(String? name) {
    if (name == null || name.isEmpty) return false;
    final nameRegex = RegExp(r'^[a-zA-Z ]+$');
    return name.length >= 3 && nameRegex.hasMatch(name);
  }

  //  التحقق من صيغة الإيميل
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  //  التحقق من طول الباسورد
  static bool isValidPassword(String? password) {
    return password != null && password.length >= 8;
  }

  //  التحقق من أن الباسورد والتأكيد متطابقان
  static bool passwordsMatch(String? password, String? confirmPassword) {
    return password != null && confirmPassword != null && password == confirmPassword;
  }

  //  التحقق من أن التاريخ غير فارغ ولا يحتوي على تاريخ مستقبلي
  static bool isDateValid(DateTime? date) {
    return date != null && !date.isAfter(DateTime.now());
  }

  //  التحقق من أن الحقل يحتوي على رقم فقط
  static bool isNumeric(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }

  //  التحقق من أن الرقم موجب (لا يمكن أن يكون سالبًا)
  static bool isPositiveNumeric(String? value) {
    if (!isNumeric(value)) return false;
    final number = int.tryParse(value!);
    return number != null && number > 0;
  }
}