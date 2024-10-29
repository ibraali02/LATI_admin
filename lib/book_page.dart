import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'course/AIChatPage.dart';
import 'course/messages_page.dart';
import 'course/online_page.dart';
import 'course/posts_page.dart';
import 'course/rate_page.dart';
import 'course/video_page.dart';

class BookPage extends StatefulWidget {
  const BookPage({Key? key}) : super(key: key);

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.forward();
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
        preferredSize: Size.fromHeight(80.0),
        child: _customAppBar(context),
      ),
      body: const PostsPage(), // الصفحة الرئيسية التي تبقى ثابتة
    );
  }

  Widget _customAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF980E0E),
            Color(0xFF330000),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'My Course',
          style: GoogleFonts.poppins(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [  _buildMessagesButton(),
          _buildAppBarIcon(Icons.star, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RatePage()),
            );
          }),
          _buildAppBarIcon(Icons.online_prediction, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OnlinePage()),
            );
          }),
          _buildAppBarIcon(Icons.video_call, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VideoPage()),
            );
          }),

         _buildImageButton(),
        ],
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onPressed,
    );
  }

  Widget _buildImageButton() {
    return IconButton(
      icon: Image.asset('images/img_3.png', height: 100),
      tooltip: 'AI',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AIChatPage(apiKey: 'AIzaSyBqo8klOOQ9Xqyc-6uNC9sjjpf9wHMzbGE'),
          ),
        );
      },
    );
  }

  Widget _buildMessagesButton() {
    return IconButton(
      icon: const Icon(Icons.message, color: Colors.white),
      tooltip: 'Messages',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MessagesPage(),
          ),
        );
      },
    );
  }
}