import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // استيراد الحزمة
import 'package:provider/provider.dart';
import 'package:untitled9/splash_screen.dart';
import 'user_settings.dart';
import 'settings_page.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized(); // تأكد من تهيئة Flutter أولاً
  await Firebase.initializeApp(); // تهيئة Firebase
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserSettings(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false, // إزالة شريط التصحيح
// أو الصفحة الرئيسية الخاصة بك
    );
  }
}
