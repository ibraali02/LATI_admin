import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'settings_page.dart'; // استيراد صفحة الإعدادات

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userName = 'User';
  List<DocumentSnapshot> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchPosts();
  }

  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      });
    }
  }

  Future<void> _fetchPosts() async {
    QuerySnapshot querySnapshot = await _firestore.collection('posts').get();
    setState(() {
      _posts = querySnapshot.docs;
    });
  }

  Future<void> _updateLikes(DocumentSnapshot post, bool isLiked) async {
    int currentLikes = post['likes'] ?? 0;
    int newLikes = isLiked ? currentLikes + 1 : currentLikes - 1;
    await _firestore.collection('posts').doc(post.id).update({'likes': newLikes});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _customAppBar(context),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: _posts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return _postCard(_posts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _customAppBar(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.38,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF980E0E),
            Color(0xFF330000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome, $_userName 👋',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {
                        // Navigate to notifications page
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsPage()), // الانتقال إلى صفحة الإعدادات
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Latest Posts',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _postCard(DocumentSnapshot post) {
    Map<String, dynamic> data = post.data() as Map<String, dynamic>;
    bool isLiked = false; // Track if the post is liked

    return StatefulBuilder(
      builder: (context, setState) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Published by: الأكاديمية الليبية للاتصالات والمعلوماتية',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  data['title'] ?? 'No Title',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Image.network(
                  data['image'] ?? '',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                Text(data['content'] ?? 'No Content'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.thumb_up,
                            color: isLiked ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              isLiked = !isLiked; // Toggle the liked state
                            });
                            _updateLikes(post, isLiked); // Update likes in Firestore
                          },
                        ),
                        const SizedBox(width: 4),
                        Text('${data['likes'] ?? 0}', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 16),
                        const Icon(Icons.share, color: Colors.grey, size: 18),
                        const SizedBox(width: 4),
                        Text('${data['shares'] ?? 0}', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 16),
                        Text(
                          _formatPostDate(data['date']),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatPostDate(String? dateString) {
    if (dateString == null) {
      return 'Unknown';
    }

    try {
      DateTime postDate = DateTime.parse(dateString);
      Duration diff = DateTime.now().difference(postDate);

      if (diff.inDays >= 1) {
        return '${diff.inDays} days ago';
      } else if (diff.inHours >= 1) {
        return '${diff.inHours} hours ago';
      } else if (diff.inMinutes >= 1) {
        return '${diff.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}