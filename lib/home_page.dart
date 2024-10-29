import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'settings_page.dart'; // استيراد صفحة الإعدادات
import 'package:provider/provider.dart';
import 'user_settings.dart'; // استيراد UserSettings

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
    final userSettings = Provider.of<UserSettings>(context);

    return Scaffold(
      body: Stack(
        children: [
          _customAppBar(context, userSettings.isDarkMode),
          DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: userSettings.isDarkMode ? Colors.grey[850] : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      return _postCard(_posts[index], userSettings.isDarkMode);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _customAppBar(BuildContext context, bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: MediaQuery.of(context).size.height * 0.38,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.black, Colors.grey[850]!]
              : [Color(0xFF980E0E), Color(0xFF330000)],
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
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
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

  Widget _postCard(DocumentSnapshot post, bool isDarkMode) {
    Map<String, dynamic> data = post.data() as Map<String, dynamic>;
    bool isLiked = false; // Track if the post is liked

    return StatefulBuilder(
      builder: (context, setState) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          color: isDarkMode ? Colors.grey[800] : Colors.white,
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
                Text(data['content'] ?? 'No Content', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
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