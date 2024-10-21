import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'course_detail_page.dart'; // تأكد من استيراد صفحة التفاصيل هنا

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Courses', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF980E0E),
                Color(0xFF330000),
              ],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _filterButtonsWithImages(),
              const SizedBox(height: 16),
              _sortDropdown(),
              const SizedBox(height: 16),
              _coursesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterButtonsWithImages() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterButton('All', Icons.list),
          const SizedBox(width: 8),
          _filterButton('Programming', 'images/cod.png'),
          const SizedBox(width: 8),
          _filterButton('Design', 'images/dis.png'),
          const SizedBox(width: 8),
          _filterButton('Cybersecurity', 'images/sy.png'),
          const SizedBox(width: 8),
          _filterButton('App Development', 'images/app.png'),
        ],
      ),
    );
  }

  Widget _filterButton(String title, dynamic icon) {
    bool isSelected = selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = (isSelected && title == 'All') ? null : title;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.red[100] : Colors.white,
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Text(title, style: const TextStyle(color: Colors.black)),
            const SizedBox(width: 8),
            icon is IconData
                ? Icon(icon, size: 40)
                : SizedBox(
              width: 40,
              height: 40,
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

  Widget _sortDropdown() {
    return DropdownButton<String>(
      isExpanded: true,
      hint: const Text('Sort by'),
      items: <String>[
        'Popular',
        'Newest',
        'Price: Low to High',
        'Price: High to Low'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        // إضافة منطق الفرز هنا
      },
    );
  }

  Widget _coursesList() {
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

        return Column(
          children: filteredCourses.map((doc) {
            final course = doc.data() as Map<String, dynamic>;

            final title = course['title'] ?? 'No Title';
            final description = course['description'] ?? 'No Description';
            final duration = course['duration'] ?? 'N/A';
            final imageUrl = course['imageUrl'] ?? 'https://via.placeholder.com/150';
            final location = course['location'] ?? 'Unknown Location';
            final category = course['category'] ?? 'Unknown Category';
            final publishedDate = (course['publishedDate'] as Timestamp).toDate();
            final timeAgo = timeago.format(publishedDate);

            return GestureDetector(
              onTap: () {
                // الانتقال إلى صفحة تفاصيل الكورس
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CourseDetailPage(
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
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _courseCard(String title, String description, String duration, String imageUrl, String location, String category, String publishedDate) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الكورس
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),

            // تفاصيل الكورس
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF330000),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
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
