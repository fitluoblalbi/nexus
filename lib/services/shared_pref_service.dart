import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User
  static Future<bool> saveUserId(String userId) async {
    return await _prefs.setString('userId', userId);
  }

  static String? getUserId() {
    return _prefs.getString('userId');
  }

  static Future<bool> removeUserId() async {
    return await _prefs.remove('userId');
  }

  static Future<bool> saveUserEmail(String email) async {
    return await _prefs.setString('userEmail', email);
  }

  static String? getUserEmail() {
    return _prefs.getString('userEmail');
  }

  // Theme
  static Future<bool> saveDarkMode(bool isDark) async {
    return await _prefs.setBool('darkMode', isDark);
  }

  static bool? getDarkMode() {
    return _prefs.getBool('darkMode');
  }

  // First launch
  static Future<bool> saveFirstLaunch(bool isFirstLaunch) async {
    return await _prefs.setBool('firstLaunch', isFirstLaunch);
  }

  static bool isFirstLaunch() {
    return _prefs.getBool('firstLaunch') ?? true;
  }

  // Clear all
  static Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}
