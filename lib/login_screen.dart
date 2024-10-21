import 'package:flutter/material.dart';
import 'package:untitled9/signup_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _isEmailLogin = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      UserCredential userCredential;

      if (_isEmailLogin) {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // حفظ التوكن في SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', userCredential.user!.uid); // حفظ UID كمثال
      } else {
        throw Exception("Phone login is not implemented yet.");
      }

      // الانتقال إلى الشاشة الرئيسية بعد تسجيل الدخول الناجح
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      String errorMessage;

      if (e is FirebaseAuthException) {
        // التعامل مع الأخطاء المختلفة
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'البريد الإلكتروني غير صالح.';
            break;
          case 'user-not-found':
            errorMessage = 'لا يوجد مستخدم مسجل بهذا البريد الإلكتروني.';
            break;
          case 'wrong-password':
            errorMessage = 'كلمة المرور غير صحيحة.';
            break;
          case 'user-disabled':
            errorMessage = 'تم تعطيل الحساب.';
            break;
          default:
            errorMessage = 'حدث خطأ غير متوقع. حاول مرة أخرى.';
        }
      } else {
        errorMessage = 'حدث خطأ غير متوقع. حاول مرة أخرى.';
      }

      // عرض رسالة الخطأ للمستخدم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // الخلفية المتدرجة
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4A0000),
                  Colors.red[900]!,
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
          // الزوايا البيضاء
          Positioned(
            top: 640,
            right: -70,
            child: ClipPath(
              clipper: TopRightClipper(),
              child: Container(
                color: Colors.white,
                width: 300,
                height: 300,
              ),
            ),
          ),
          Positioned(
            bottom: 600,
            left: -70,
            child: ClipPath(
              clipper: BottomLeftClipper(),
              child: Container(
                color: Colors.white,
                width: 300,
                height: 300,
              ),
            ),
          ),
          // محتوى الشاشة
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // خيارات تسجيل الدخول
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEmailLogin = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: _isEmailLogin ? Colors.white : Colors.black,
                            backgroundColor: _isEmailLogin ? const Color(0xFFCB5E05) : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Email"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEmailLogin = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: !_isEmailLogin ? Colors.white : Colors.black,
                            backgroundColor: !_isEmailLogin ? const Color(0xFFCB5E05) : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Phone"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // حقل الإدخال بناءً على الخيار المحدد
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        _isEmailLogin ? Icons.email : Icons.phone,
                        color: Colors.grey,
                        size: 30,
                      ),
                      hintText: _isEmailLogin ? "Email" : "Phone Number",
                      hintStyle: const TextStyle(color: Colors.grey),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey, size: 30),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.grey),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFF530000),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Login"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // خيارات متابعة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "- OR Continue with -",
                        style: TextStyle(color: Colors.grey.shade300),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 33,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.g_mobiledata, color: Color(0xFF530000), size: 60),
                      ),
                      SizedBox(width: 20),
                      CircleAvatar(
                        radius: 33,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.apple, color: Colors.black, size: 60),
                      ),
                      SizedBox(width: 20),
                      CircleAvatar(
                        radius: 33,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.facebook, color: Color(0xFF1877F2), size: 60),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // تنبيه تسجيل الدخول
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // إضافة مسافة في الأسفل
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper for top right corner
class TopRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.6, size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

// Custom clipper for bottom left corner
class BottomLeftClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.4, 0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}