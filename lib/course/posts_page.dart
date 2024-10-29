import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  String? title;
  String? description;
  String? duration;
  String? location;
  String? category;
  String? imageUrl;
  DateTime? publishedDate;
  DateTime? startDate;
  bool isStarted = false;
  bool isLoading = true;
  List<dynamic> contentList = []; // To hold content data
  List<dynamic> externalContents = []; // To hold external content data

  @override
  void initState() {
    super.initState();
    _fetchUserTokenAndCourseData();
  }

  Future<void> _fetchUserTokenAndCourseData() async {
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('token');

    if (userToken != null) {
      await _fetchCourseForUser(userToken);
    } else {
      setState(() {
        isLoading = false; // Stop loading if token is null
      });
    }
  }

  Future<void> _fetchCourseForUser(String userToken) async {
    try {
      QuerySnapshot coursesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('isStarted', isEqualTo: true)
          .get();

      for (var courseDoc in coursesSnapshot.docs) {
        var courseData = courseDoc.data() as Map<String, dynamic>;

        QuerySnapshot acceptedStudentsSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseDoc.id)
            .collection('accepted_students')
            .where('userToken', isEqualTo: userToken)
            .get();

        if (acceptedStudentsSnapshot.docs.isNotEmpty) {
          setState(() {
            title = courseData['title'] ?? "Course Title";
            description = courseData['description'] ?? "No Description";
            duration = courseData['duration'] ?? "Duration Not Available";
            location = courseData['location'] ?? "Location Not Available";
            category = courseData['category'] ?? "No Category";
            imageUrl = courseData['imageUrl'] ?? "";
            publishedDate = courseData['publishedDate'] != null
                ? (courseData['publishedDate'] as Timestamp).toDate()
                : null;
            startDate = courseData['startTime'] != null
                ? (courseData['startTime'] as Timestamp).toDate()
                : null;
            isStarted = courseData['isStarted'] ?? false;
            isLoading = false; // Stop loading after finding the course
          });

          // Fetch content for this course
          await _fetchContentForCourse(courseDoc.id);
          // Fetch external contents for this course
          await _fetchExternalContents(courseDoc.id);
          return; // Exit after finding the first matching course
        }
      }

      // If no course found, stop loading
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching course for user: $e");
      setState(() {
        isLoading = false; // Stop loading on error
      });
    }
  }

  Future<void> _fetchContentForCourse(String courseId) async {
    try {
      QuerySnapshot contentSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('contents')
          .get();

      setState(() {
        contentList = contentSnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print("Error fetching content for course: $e");
    }
  }

  Future<void> _fetchExternalContents(String courseId) async {
    try {
      QuerySnapshot externalContentSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('external_contents')
          .get();

      setState(() {
        externalContents = externalContentSnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print("Error fetching external contents for course: $e");
    }
  }

  Widget _continueLearningSection(BuildContext context) {
    if (publishedDate == null || startDate == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final durationParts = duration?.split(' ');
    final durationValue = durationParts?.first;
    final totalDurationMonths = durationValue != null ? int.parse(durationValue) : 0;

    final totalDurationDays = totalDurationMonths * 30; // Approx. 30 days in a month
    final totalDuration = Duration(days: totalDurationDays);
    final difference = now.difference(startDate!);
    final completedPercentage = (difference.inDays / totalDuration.inDays).clamp(0, 1);

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(imageUrl!, height: 120, width: double.infinity, fit: BoxFit.cover)
                : const SizedBox(height: 120, width: double.infinity),
            const SizedBox(height: 8),
            Text(
              title ?? "Course Title",
              style: TextStyle(fontSize: 18 * MediaQuery.textScaleFactorOf(context), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description ?? "No Description",
              style: TextStyle(fontSize: 16 * MediaQuery.textScaleFactorOf(context), color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              "Category: $category",
              style: TextStyle(fontSize: 16 * MediaQuery.textScaleFactorOf(context)),
            ),
            const SizedBox(height: 4),
            Text(
              "Duration: $duration",
              style: TextStyle(fontSize: 16 * MediaQuery.textScaleFactorOf(context)),
            ),
            const SizedBox(height: 4),
            Text(
              "Location: $location",
              style: TextStyle(fontSize: 16 * MediaQuery.textScaleFactorOf(context)),
            ),
            const SizedBox(height: 4),
            Text(
              "Published on: ${publishedDate != null ? DateFormat.yMMMd().format(publishedDate!) : 'N/A'}",
              style: TextStyle(fontSize: 16 * MediaQuery.textScaleFactorOf(context)),
            ),
            const SizedBox(height: 4),
            Text(
              "Starts on: ${DateFormat.yMMMd().format(startDate!)}",
              style: TextStyle(fontSize: 16 * MediaQuery.textScaleFactorOf(context)),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              minHeight: 8,
              value: completedPercentage.toDouble(),
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC02626)),
            ),
            const SizedBox(height: 4),
            Text(
              '${(completedPercentage * 100).toStringAsFixed(0)}% Complete',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _externalContentSection(BuildContext context) {
    if (externalContents.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            ...externalContents.map((content) {
              return ListTile(
                title: Text(content['title'] ?? "External Content Title"),
                subtitle: Text(content['description'] ?? "No Description"),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _contentSection(BuildContext context) {
    if (contentList.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 8),
              ...contentList.map((content) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(content['title'] ?? "Content Title"),
                      subtitle: Text(content['description'] ?? "No Description"),
                    ),
                    Text("Type: ${content['type'] ?? 'N/A'}"),
                    Text("Start Time: ${content['startTime'] != null ? DateFormat.jm().format((content['startTime'] as Timestamp).toDate()) : 'N/A'}"),
                    Text("End Time: ${content['endTime'] != null ? DateFormat.jm().format((content['endTime'] as Timestamp).toDate()) : 'N/A'}"),
                    const SizedBox(height: 8), // Spacing between items
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(

      body: SingleChildScrollView( // إضافة SingleChildScrollView هنا
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
          child: Column(
            children: [
              _continueLearningSection(context),
              const SizedBox(height: 16),
              const Text(
                "External Course Contents",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ), // Title for external contents
              const SizedBox(height: 8),
              _externalContentSection(context), // Show the external content section below the title
              const SizedBox(height: 16),
              _contentSection(context), // Show the content section below the external content
            ],
          ),
        ),
      ),
    );
  }
}