import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings with ChangeNotifier {
  bool _isDarkMode = false;
  String _currentLanguage = 'en'; // متغير لتخزين اللغة الحالية

  UserSettings() {
    _loadSettings();
  }

  bool get isDarkMode => _isDarkMode;
  String get currentLanguage => _currentLanguage; // Getter للغة الحالية

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _currentLanguage = prefs.getString('currentLanguage') ?? 'en'; // تحميل اللغة
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _currentLanguage = languageCode; // تحديث اللغة
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(' currentLanguage', languageCode); // حفظ اللغة في SharedPreferences
    notifyListeners();
  }
}
