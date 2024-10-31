import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'user_settings.dart';
import 'login_screen.dart';
import 'profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // الحصول على إعدادات المستخدم من Provider
    final userSettings = Provider.of<UserSettings>(context);
    bool isDarkMode = userSettings.isDarkMode;
    String selectedLanguage = userSettings.currentLanguage;

    Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    Color appBarColor = const Color(0xffb71111c);
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    Color buttonColor = const Color(0xffb71111c);
    Color cardColor = isDarkMode ? const Color(0xff333333) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedLanguage == 'ar' ? 'الإعدادات' : 'Settings',
          style: const TextStyle(color: Colors.white), // تعيين لون النص إلى الأبيض
        ),
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // تعيين لون الأيقونة إلى الأبيض
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Card(
              color: cardColor,
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xffb71111c)),
                    title: Text(selectedLanguage == 'ar' ? 'عرض الملف الشخصي' : 'View Profile', style: TextStyle(color: textColor)),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.language, color: Color(0xffb71111c)),
                    title: Text(selectedLanguage == 'ar' ? 'تغيير اللغة' : 'Change Language', style: TextStyle(color: textColor)),
                    trailing: DropdownButton<String>(
                      value: selectedLanguage,
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'ar', child: Text('العربية')),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          userSettings.changeLanguage(newValue); // تغيير اللغة من خلال provider
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.dark_mode, color: Color(0xffb71111c)),
                    title: Text(selectedLanguage == 'ar' ? 'الوضع الداكن' : 'Dark Mode', style: TextStyle(color: textColor)),
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (bool value) {
                        userSettings.toggleDarkMode(value); // تغيير وضع الظلام
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.notifications, color: Color(0xffb71111c)),
                    title: Text(selectedLanguage == 'ar' ? 'الإشعارات' : 'Notifications', style: TextStyle(color: textColor)),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // يمكن إضافة صفحة الإشعارات هنا
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip, color: Color(0xffb71111c)),
                    title: Text(selectedLanguage == 'ar' ? 'سياسة الخصوصية' : 'Privacy Policy', style: TextStyle(color: textColor)),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // يمكن إضافة صفحة سياسة الخصوصية هنا
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info, color: Color(0xffb71111c)),
                    title: Text(selectedLanguage == 'ar' ? 'حول' : 'About', style: TextStyle(color: textColor)),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // يمكن إضافة صفحة حول التطبيق هنا
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(selectedLanguage == 'ar' ? 'تسجيل الخروج' : 'Logout', style: const TextStyle(color: Colors.white)), // تعيين لون النص إلى الأبيض
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // قم بإضافة أي عمليات تنظيف أخرى إذا لزم الأمر
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
