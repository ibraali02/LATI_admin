import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // استيراد مكتبة Google Fonts

import 'course/AIChatPage.dart';
import 'course/messages_page.dart';
import 'course/online_page.dart';
import 'course/posts_page.dart';
import 'course/rate_page.dart';
import 'course/video_page.dart'; // استيراد صفحة الفيديو

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _currentPage = 'Home'; // تعيين الصفحة الافتراضية إلى Home
  Widget _currentContent = const PostsPage(); // تعيين المحتوى الافتراضي إلى PostsPage

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.forward(); // بدء الرسوم المتحركة عند فتح الصفحة
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0), // تعيين ارتفاع AppBar
        child: _customAppBar(context), // استخدام AppBar المخصص
      ),
      body: _currentContent, // عرض محتوى الصفحة الحالية
    );
  }

  Widget _customAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF980E0E), // اللون الأحمر الفاتح
            Color(0xFF330000), // اللون الأحمر الداكن
          ],
          begin: Alignment.topCenter, // يبدأ التدرج من الأعلى
          end: Alignment.bottomCenter, // وينتهي في الأسفل
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent, // يجعل AppBar شفافاً لعرض التدرج اللوني
        title: Text(
          'My Courses',
          style: GoogleFonts.poppins( // استخدام خط Poppins
            color: Colors.orange, // تعيين اللون إلى برتقالي جميل
            fontWeight: FontWeight.bold, // تعيين وزن الخط إلى عريض
            fontSize:15, // تصغير حجم الخط هنا
          ),
        ),
        actions: [
          _buildIconButton(Icons.home, 'Home', const PostsPage()),
          _buildIconButton(Icons.message, 'Messages', const MessagesPage()),
          _buildIconButton(Icons.star, 'Rate', const RatePage()),
          _buildIconButton(Icons.online_prediction, 'Online', const OnlinePage()),
          _buildIconButton(Icons.video_call, 'Video', const VideoPage()),
          _buildImageButton(), // زر AI بصورة
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String page, Widget content) {
    // تحديد لون الزر بناءً على الصفحة الحالية
    final isSelected = _currentPage == page;
    final color = isSelected ? Colors.orange : Colors.white;

    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: page,
      onPressed: () {
        setState(() {
          _currentPage = page; // تحديث الصفحة الحالية
          _currentContent = content; // تغيير المحتوى إلى الصفحة المطلوبة
        });
      },
    );
  }

  Widget _buildImageButton() {
    return IconButton(
      icon: Image.asset('images/img.png', height: 30), // تعيين ارتفاع الصورة
      tooltip: 'AI',
      onPressed: () {
        setState(() {
          _currentPage = 'AI'; // تحديث الصفحة الحالية إلى AI
          _currentContent = const AIChatPage(); // تغيير المحتوى إلى صفحة AI
        });
      },
    );
  }

  Widget _continueLearningSection() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0), // إضافة margin إلى الكارد
      child: Padding(
        padding: const EdgeInsets.all(8.0), // تقليل padding داخل الكارد
        child: Row(
          children: [
            Image.asset('images/im1.png', height: 60, width: 60, fit: BoxFit.cover), // تقليل حجم الصورة
            const SizedBox(width: 8), // تقليل المسافة بين الصورة والنص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('APP', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4), // تقليل المسافة بين النصوص
                  const Text(
                    'Bootcamp of Mobile App From Scratch',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // تقليل حجم الخط
                  ),
                  const SizedBox(height: 8), // تقليل المسافة
                  LinearProgressIndicator(
                    minHeight: 8, // تقليل ارتفاع شريط التقدم
                    borderRadius: BorderRadius.circular(5),
                    value: 0.75,
                    backgroundColor: Colors.grey,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC02626)),
                  ),
                  const SizedBox(height: 4), // تقليل المسافة
                  const Text(
                    '23 of 33 Lessons • 75% completed',
                    style: TextStyle(color: Colors.grey, fontSize: 12), // تقليل حجم الخط
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}