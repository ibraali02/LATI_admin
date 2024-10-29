import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_fonts/google_fonts.dart';
import 'course_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'user_settings.dart'; // تأكد من استيراد UserSettings

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String? selectedCategory;
  String? selectedSortOption;
  String? userToken;
  List<String> enrolledCourses = [];

  @override
  void initState() {
    super.initState();
    _loadUserToken();
  }

  Future<void> _loadUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('token');
    });
    if (userToken != null) {
      _fetchEnrolledCourses();
    }
  }

  Future<void> _fetchEnrolledCourses() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('accepted_courses')
          .where('userToken', isEqualTo: userToken)
          .get();

      setState(() {
        enrolledCourses = snapshot.docs.map((doc) => doc['courseId'] as String).toList();
      });
    } catch (e) {
      print("Error fetching enrolled courses: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userSettings = Provider.of<UserSettings>(context);
    final isDarkMode = userSettings.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('Explore Courses'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              userSettings.toggleDarkMode(!isDarkMode);
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 50,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: isDarkMode
                      ? const LinearGradient(
                    colors: [
                      Color(0xFF980E0E),
                      Color(0xFF330000),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : const LinearGradient(
                    colors: [
                      Color(0xFFFFC107),
                      Color(0xFFFF9800),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Explore Courses',
                    style: GoogleFonts.lato(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _filterButtonsWithImages(isDarkMode),
                const SizedBox(height: 16),
                _sortDropdown(isDarkMode),
                const SizedBox(height: 16),
                _coursesList(isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButtonsWithImages(bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterButton('All', Icons.list, isDarkMode),
          const SizedBox(width: 8),
          _filterButton('Programming', 'images/cod.png', isDarkMode),
          const SizedBox(width: 8),
          _filterButton('Design', 'images/dis.png', isDarkMode),
          const SizedBox(width: 8),
          _filterButton('Cybersecurity', 'images/sy.png', isDarkMode),
          const SizedBox(width: 8),
          _filterButton('App Development', 'images/app.png', isDarkMode),
        ],
      ),
    );
  }

  Widget _filterButton(String title, dynamic icon, bool isDarkMode) {
    bool isSelected = selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = (isSelected && title == 'All') ? null : title;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.red : Colors.grey),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.red[100] : (isDarkMode ? Colors.grey[800] : Colors.white),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(right: 8),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.lato(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
            ),
            const SizedBox(width: 4),
            icon is IconData
                ? Icon(icon, size: 24, color: isDarkMode ? Colors.white : Colors.black)
                : SizedBox(
              width: 24,
              height: 24,
              child: ClipOval(
                child: Image.asset(
                  icon,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortDropdown(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Text('Sort by', style: GoogleFonts.lato(color: isDarkMode ? Colors.white54 : Colors.black54)),
        value: selectedSortOption,
        items: <String>[
          'Duration: Shortest First',
          'Duration: Longest First',
          'Popular',
          'Newest'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: GoogleFonts.lato(color: isDarkMode ? Colors.white : Colors.black)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedSortOption = newValue;
          });
        },
        underline: const SizedBox(),
      ),
    );
  }

  Widget _coursesList(bool isDarkMode) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No courses available.'));
        }

        final filteredCourses = snapshot.data!.docs.where((doc) {
          if (selectedCategory == null || selectedCategory == 'All') {
            return true;
          }
          return doc['category'] == selectedCategory;
        }).toList();

        if (selectedSortOption == 'Duration: Shortest First') {
          filteredCourses.sort((a, b) => a['duration'].compareTo(b['duration']));
        } else if (selectedSortOption == 'Duration: Longest First') {
          filteredCourses.sort((a, b) => b['duration'].compareTo(a['duration']));
        } else if (selectedSortOption == 'Newest') {
          filteredCourses.sort((a, b) => b['publishedDate'].compareTo(a['publishedDate']));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredCourses.length,
          itemBuilder: (context, index) {
            final doc = filteredCourses[index];
            final course = doc.data() as Map<String, dynamic>;

            final title = course['title'] ?? 'No Title';
            final description = course['description'] ?? 'No Description';
            final duration = course['duration'] ?? 'N/A';
            final imageUrl = course['imageUrl'] ?? 'https://via.placeholder.com/150';
            final location = course['location'] ?? 'Unknown Location';
            final category = course['category'] ?? 'Unknown Category';
            final publishedDate = (course['publishedDate'] as Timestamp).toDate();
            final timeAgo = timeago.format(publishedDate);

            // Check if the user is enrolled in this course
            bool isEnrolled = enrolledCourses.contains(doc.id);

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CourseDetailPage(
                      courseId: doc.id,
                      title: title,
                      description: description,
                      duration: duration,
                      imageUrl: imageUrl,
                      location: location,
                      category: category,
                      publishedDate: timeAgo,
                    ),
                  ),
                );
              },
              child: _courseCard(
                title,
                description,
                duration,
                imageUrl,
                location,
                category,
                timeAgo,
                isEnrolled,
                isDarkMode,
              ),
            );
          },
        );
      },
    );
  }

  Widget _courseCard(String title, String description, String duration, String imageUrl, String location, String category, String publishedDate, bool isEnrolled, bool isDarkMode) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_pin, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      'Duration: $duration',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.category, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      category,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      'Published: $publishedDate',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                // Add a registration status button
                const SizedBox(height: 8),
                if (isEnrolled)
                  ElevatedButton(
                    onPressed: () {
                      // Action when the user is already enrolled
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('You are already enrolled in this course.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Already Enrolled'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}