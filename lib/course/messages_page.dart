import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  late CollectionReference _coursesRef;
  String? _userId;
  String? _userName;
  String? _courseToken;
  bool isLoading = true;
  bool isEnrolledInCourse = false; // افتراضيًا، غير مسجل في أي كورس

  @override
  void initState() {
    super.initState();
    _coursesRef = FirebaseFirestore.instance.collection('courses');
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('token');

    if (_userId != null) {
      await _fetchUserDetails(_userId!);
      await _fetchUserTokenAndCourseData();
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUserDetails(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        if (mounted) {
          setState(() {
            _userName = (userDoc.data() as Map<String, dynamic>)['first_name'];
          });
        }
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Future<void> _fetchUserTokenAndCourseData() async {
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('token');

    if (userToken != null) {
      await _fetchCourseForUser(userToken);
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCourseForUser(String userToken) async {
    try {
      QuerySnapshot coursesSnapshot = await _coursesRef
          .where('isStarted', isEqualTo: true)
          .get();

      bool courseFound = false;

      for (var courseDoc in coursesSnapshot.docs) {
        var courseData = courseDoc.data() as Map<String, dynamic>;

        QuerySnapshot acceptedStudentsSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseDoc.id)
            .collection('accepted_students')
            .where('userToken', isEqualTo: userToken)
            .get();

        if (acceptedStudentsSnapshot.docs.isNotEmpty) {
          if (mounted) {
            setState(() {
              _courseToken = courseDoc.id;
              isLoading = false;
              isEnrolledInCourse = true; // تم العثور على الكورس
            });
          }
          courseFound = true;
          break;
        }
      }

      if (!courseFound) {
        if (mounted) {
          setState(() {
            isLoading = false;
            isEnrolledInCourse = false; // لم يتم العثور على الكورس
          });
        }
      }
    } catch (e) {
      print("Error fetching courses for user: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage(String messageContent) async {
    if (_courseToken != null && messageContent.isNotEmpty) {
      try {
        await _coursesRef
            .doc(_courseToken)
            .collection('messages')
            .add({
          'sender': _userId,
          'senderName': _userName,
          'time': FieldValue.serverTimestamp(),
          'content': messageContent,
          'courseId': _courseToken,
        });

        _messageController.clear();
      } catch (e) {
        print("Error sending message: $e");
      }
    } else {
      print("Course token is null or message is empty.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Chat'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isEnrolledInCourse
          ? Column(
        children: [
          const Divider(thickness: 2, color: Colors.grey),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _courseToken != null
                  ? _coursesRef
                  .doc(_courseToken)
                  .collection('messages')
                  .orderBy('time')
                  .snapshots()
                  : Stream.empty(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                final messages = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Message(
                    sender: data['senderName'] ?? data['sender'],
                    time: (data['time'] as Timestamp?)?.toDate().toLocal().toString().substring(10, 15) ?? '',
                    content: data['content'] ?? '',
                  );
                }).toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      )
          : const Center(child: Text('لست مسجلاً في كورس مبدوء.')),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.sender == _userName;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.orange : Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.sender,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              message.content,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              message.time,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
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
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                _sendMessage(_messageController.text);
              } else {
                print("Message is empty!");
              }
            },
          ),
        ],
      ),
    );
  }
}

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