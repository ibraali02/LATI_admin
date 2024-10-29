import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // انتظر قليلاً قبل الانتقال إلى الصفحة التالية
    await Future.delayed(const Duration(seconds: 2));

    if (token != null) {
      // إذا كان هناك توكن، انتقل إلى الصفحة الرئيسية
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // إذا لم يكن هناك توكن، انتقل إلى صفحة تسجيل الدخول
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(), // مؤشر تحميل
            const SizedBox(height: 20),
            const Text('جاري التحقق من الحالة...'), // رسالة الانتظار
          ],
        ),
      ),
    );
  }
}