import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'profile_page.dart'; // تأكد من استيراد صفحة البروفايل

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isArabic = false; // حالة اللغة
  bool _isDarkMode = false; // حالة الوضع الداكن

  Future<void> _logout(BuildContext context) async {
    // تسجيل الخروج من Firebase
    await FirebaseAuth.instance.signOut();

    // حذف التوكن من SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // افترض أن التوكن محفوظ تحت هذا المفتاح

    // الانتقال إلى صفحة تسجيل الدخول
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            _isArabic ? 'الإعدادات' : 'Settings',
            style: const TextStyle(color: Colors.white), // لون العنوان أبيض
          ),
          backgroundColor: const Color(0xffb71111c),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white), // زر الرجوع باللون الأبيض
            onPressed: () {
              Navigator.pop(context); // العودة إلى الصفحة السابقة
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isArabic ? 'الإعدادات' : 'Settings',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // زر البروفايل مع الأيقونة
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()), // الانتقال إلى صفحة البروفايل
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xffb71111c), // لون الزر
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, color: Colors.white), // أيقونة البروفايل
                      const SizedBox(width: 10),
                      Text(_isArabic ? 'عرض البروفايل' : 'View Profile'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language, color: Color(0xffb71111c)),
                      title: Text(_isArabic ? 'تغيير اللغة' : 'Change Language'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('العربية'),
                          Checkbox(
                            value: _isArabic,
                            onChanged: (bool? value) {
                              setState(() {
                                _isArabic = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.dark_mode, color: Color(0xffb71111c)),
                      title: Text(_isArabic ? 'الوضع الداكن' : 'Dark Mode'),
                      trailing: Switch(
                        value: _isDarkMode,
                        onChanged: (bool value) {
                          setState(() {
                            _isDarkMode = value;
                          });
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.notifications, color: Color(0xffb71111c)),
                      title: Text(_isArabic ? 'الإشعارات' : 'Notifications'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        // Implement notifications settings functionality
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip, color: Color(0xffb71111c)),
                      title: Text(_isArabic ? 'سياسة الخصوصية' : 'Privacy Policy'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        // Implement privacy policy functionality
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.info, color: Color(0xffb71111c)),
                      title: Text(_isArabic ? 'حول' : 'About'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        // Implement about functionality
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _logout(context), // استدعاء دالة تسجيل الخروج
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xffb71111c), // لون الزر
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(_isArabic ? 'تسجيل الخروج' : 'Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}