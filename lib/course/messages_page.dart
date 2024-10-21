import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة تجريبية من الرسائل
    final List<Message> messages = [
      Message(sender: 'Alice', time: '2:00 PM', content: 'Hello everyone!'),
      Message(sender: 'Bob', time: '2:01 PM', content: 'Hi Alice, how are you?'),
      Message(sender: 'Charlie', time: '2:02 PM', content: 'Did everyone complete the assignment?'),
      Message(sender: 'You', time: '2:03 PM', content: 'I finished it yesterday!'), // رسالة من المستخدم
      Message(sender: 'Eva', time: '2:04 PM', content: 'Great job, David!'),
      Message(sender: 'Alice', time: '2:05 PM', content: 'Let’s discuss the project tomorrow.'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF980E0E), // اللون الأحمر الداكن
              Color(0xFFFF5A5A), // اللون الأحمر الفاتح
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Course Chat',
            style: TextStyle(
              fontSize: 24, // حجم الخط
              fontWeight: FontWeight.bold, // جعل الخط عريض
              color: Colors.white, // يجب تعيين لون الخط إلى الأبيض لكي يظهر التدرج
            ),
          ),
        ),
        centerTitle: true, // توسيط العنوان
        backgroundColor: Colors.transparent, // خلفية شفافة
        elevation: 0, // إزالة الظل
      ),
      body: Column(
        children: [
          const Divider(thickness: 2, color: Colors.grey), // خط تحت العنوان
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    // تحديد الفقاعة بناءً على من أرسل الرسالة
    final isMe = message.sender == 'You'; // افترض أن المستخدم هو 'You'

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
            colors: [
              Color(0xFFFF8C00), // برتقالي غامق
              Color(0xFFFFA500), // برتقالي فاتح
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : const LinearGradient(
            colors: [
              Color(0xFF980E0E), // أحمر غامق
              Color(0xFF330000), // أحمر داكن
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(color: isMe ? Colors.white : Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              message.time,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              // يمكنك إضافة وظيفة لإرسال الرسالة هنا
            },
          ),
        ],
      ),
    );
  }
}

// نموذج الرسالة
class Message {
  final String sender;
  final String time;
  final String content;

  Message({
    required this.sender,
    required this.time,
    required this.content,
  });
}
