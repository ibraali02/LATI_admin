import 'package:flutter/material.dart';
import 'book_page.dart';
import 'home_screen.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // قائمة لتتبع حالة القراءة للإشعارات
  final List<bool> _isRead = List.filled(5, false); // الحالة الابتدائية لكل إشعار

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white), // تغيير لون العنوان إلى الأبيض
        ),
        backgroundColor: const Color(0xffb71111c),
        iconTheme: const IconThemeData(color: Colors.white), // تغيير لون أيقونة الرجوع إلى الأبيض
        actions: [
          // زر بتلات النقاط
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'markAllRead') {
                setState(() {
                  // جعل كل الإشعارات مقروءة
                  for (int i = 0; i < _isRead.length; i++) {
                    _isRead[i] = true;
                  }
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'markAllRead',
                  child: Text('Mark all as read'),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert, color: Colors.white), // تغيير لون زر النقاط إلى الأبيض
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _notificationItem(
            context,
            'New course added: Cloud Computing Bootcamp.',
            'Just Now',
            Icons.cloud,
            0, // الفهرس للإشعار
          ),
          _notificationItem(
            context,
            'Reminder: Your Flutter course starts tomorrow.',
            '2 hours ago',
            Icons.alarm,
            1,
          ),
          _notificationItem(
            context,
            'New job opportunity available: Software Engineer.',
            '1 hour ago',
            Icons.work,
            2,
          ),
          _notificationItem(
            context,
            'Your profile has been viewed.',
            '3 hours ago',
            Icons.visibility,
            3,
          ),
          _notificationItem(
            context,
            'New message from your mentor.',
            '5 hours ago',
            Icons.message,
            4,
          ),
        ],
      ),
    );
  }

  Widget _notificationItem(BuildContext context, String message, String time, IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        // عند الضغط على الإشعار، نقوم بتحديث الحالة إلى مقروء
        setState(() {
          _isRead[index] = true; // تحديث حالة القراءة
        });

        // الانتقال إلى HomeScreen وتحديد الفهرس إلى 4 (BookPage)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen(selectedIndex: 4)),
        );
      },
      child: SizedBox(
        height: 120, // تحديد ارتفاع ثابت لكل بطاقة
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 10),
          color: _isRead[index] ? Colors.white : Colors.red[50], // تغيير لون الخلفية ليكون باهتًا
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, size: 40, color: Colors.blue),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}