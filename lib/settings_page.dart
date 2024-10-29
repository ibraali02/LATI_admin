import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'user_settings.dart';
import 'login_screen.dart';
import 'profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userSettings = Provider.of<UserSettings>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userSettings.isDarkMode ? 'الإعدادات' : 'Settings',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xffb71111c),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userSettings.isDarkMode ? 'الإعدادات' : 'Settings',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xffb71111c),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(userSettings.isDarkMode ? 'عرض البروفايل' : 'View Profile'),
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
                    title: Text(userSettings.isDarkMode ? 'تغيير اللغة' : 'Change Language'),
                    trailing: DropdownButton<String>(
                      value: userSettings.locale.languageCode,
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'ar', child: Text('العربية')),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          userSettings.changeLanguage(newValue);
                          // لا حاجة لإعادة بناء الصفحة هنا، لأن MaterialApp ستقوم بذلك تلقائيًا
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.dark_mode, color: Color(0xffb71111c)),
                    title: Text(userSettings.isDarkMode ? 'الوضع الداكن' : 'Dark Mode'),
                    trailing: Switch(
                      value: userSettings.isDarkMode,
                      onChanged: (bool value) {
                        userSettings.toggleDarkMode(value);
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.notifications, color: Color(0xffb71111c)),
                    title: Text(userSettings.isDarkMode ? 'الإشعارات' : 'Notifications'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip, color: Color(0xffb71111c)),
                    title: Text(userSettings.isDarkMode ? 'سياسة الخصوصية' : 'Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info, color: Color(0xffb71111c)),
                    title: Text(userSettings.isDarkMode ? 'حول' : 'About'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {},
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
                  backgroundColor: const Color(0xffb71111c),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(userSettings.isDarkMode ? 'تسجيل الخروج' : 'Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}