import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'NotificationsPage.dart';
import 'settings_page.dart'; // استيراد صفحة الإعدادات
import 'package:provider/provider.dart';
import 'user_settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
    bool isDarkMode = userSettings.isDarkMode;
    String currentLanguage = userSettings.currentLanguage;

    return Scaffold(
      body: Stack(
        children: [
          _customAppBar(context, isDarkMode, currentLanguage),
          DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      return _postCard(_posts[index], isDarkMode, currentLanguage);
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

  Widget _customAppBar(BuildContext context, bool isDarkMode, String currentLanguage) {
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
                  currentLanguage == 'en'
                      ? 'Welcome, $_userName 👋'
                      : 'أهلا بك، $_userName 👋',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationsPage()), // Navigate to NotificationsPage
                        );
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
            Text(
              currentLanguage == 'en' ? 'Latest Posts' : 'آخر المشاركات',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _postCard(DocumentSnapshot post, bool isDarkMode, String currentLanguage) {
    Map<String, dynamic> data = post.data() as Map<String, dynamic>;
    bool isLiked = false; // Track if the post is liked

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentLanguage == 'en'
                      ? 'Published by: الأكاديمية الليبية للاتصالات والمعلوماتية'
                      : 'تم النشر بواسطة: الأكاديمية الليبية للاتصالات والمعلوماتية',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  data['title'] ?? (currentLanguage == 'en' ? 'No Title' : 'لا يوجد عنوان'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    data['image'] ?? '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data['content'] ?? (currentLanguage == 'en' ? 'No Content' : 'لا توجد محتويات'),
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
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
                          _formatPostDate(data['date']), // استدعاء دالة تنسيق التاريخ
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

  String _formatPostDate(dynamic date) {
    if (date is Timestamp) {
      DateTime dateTime = date.toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (date is String) {
      return date; // أو يمكنك إضافة منطق لتحويل السلسلة إلى تاريخ إذا كان ذلك ممكنًا
    }
    return 'Unknown date';
  }
}
