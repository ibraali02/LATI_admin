import 'package:flutter/material.dart';

class OnlinePage extends StatefulWidget {
  const OnlinePage({super.key});

  @override
  _OnlinePageState createState() => _OnlinePageState();
}

class _OnlinePageState extends State<OnlinePage> {
  void _startLiveStream() {
    // هنا يمكنك إضافة الوظيفة لبدء البث المباشر
    print('Starting live stream...'); // مثال على وظيفة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF980E0E), // اللون الأحمر الداكن
              Color(0xFFFF5A5A), // اللون الأحمر الفاتح
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: AppBar(
            title: const Text('Online'),
            backgroundColor: Colors.transparent, // جعل الخلفية شفافة
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildNoStreamMessage(), // رسالة لا يوجد بث في الوقت الحالي
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoStreamMessage() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10.0), // إضافة زوايا دائرية
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: const Text(
            'لا يوجد بث في الوقت الحالي',
            style: TextStyle(fontSize: 18, color: Colors.black), // لون النص أسود
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}