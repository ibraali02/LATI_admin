import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../course_detail_page.dart';

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
  List<dynamic> contentList = [];
  List<dynamic> externalContents = [];
  List<dynamic> suggestedCourses = [];

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
        isLoading = false;
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
            title = courseData['title'] ?? "عنوان الدورة غير متوفر";
            description = courseData['description'] ?? "لا توجد تفاصيل";
            duration = courseData['duration'] ?? "مدة غير متوفرة";
            location = courseData['location'] ?? "موقع غير متوفر";
            category = courseData['category'] ?? "فئة غير متوفرة";
            imageUrl = courseData['imageUrl'] ?? "";
            publishedDate = courseData['publishedDate'] != null
                ? (courseData['publishedDate'] as Timestamp).toDate()
                : DateTime.now();
            startDate = courseData['startTime'] != null
                ? (courseData['startTime'] as Timestamp).toDate()
                : DateTime.now();
            isStarted = courseData['isStarted'] ?? false;
            isLoading = false;
          });

          await _fetchContentForCourse(courseDoc.id);
          await _fetchExternalContents(courseDoc.id);
          return;
        }
      }

      await _fetchSuggestedCourses();
    } catch (e) {
      print("Error fetching course for user: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchSuggestedCourses() async {
    try {
      QuerySnapshot suggestedCoursesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('isStarted', isEqualTo: false)
          .where('isEnded', isEqualTo: false)
          .get();

      setState(() {
        suggestedCourses = suggestedCoursesSnapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching suggested courses: $e");
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

  Widget _suggestedCoursesSection(BuildContext context) {
    if (suggestedCourses.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Suggested Courses",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...suggestedCourses.map((course) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      course['imageUrl'] != null && course['imageUrl'].isNotEmpty
                          ? Image.network(course['imageUrl'], height: 120, width: double.infinity, fit: BoxFit.cover)
                          : const SizedBox(height: 120, width: double.infinity),
                      const SizedBox(height: 8),
                      Text(
                        course['title'] ?? "Course Title",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course['description'] ?? "No Description",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Category: ${course['category'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Duration: ${course['duration'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Location: ${course['location'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Price: ${course['price'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Published on: ${course['publishedDate'] != null ? DateFormat.yMMMd().format((course['publishedDate'] as Timestamp).toDate()) : 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Is Finished: ${course['isFinished'] ? 'Yes' : 'No'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetailPage(
                                courseId: course['id'],
                                title: course['title'] ?? "عنوان الدورة غير متوفر",
                                description: course['description'] ?? "لا توجد تفاصيل",
                                duration: course['duration'] ?? "مدة غير متوفرة",
                                imageUrl: course['imageUrl'] ?? "",
                                location: course['location'] ?? "موقع غير متوفر",
                                category: course['category'] ?? "فئة غير متوفرة",
                                publishedDate: DateFormat.yMMMd().format((course['publishedDate'] as Timestamp).toDate()),
                                price: course['price'] ?? "0",
                              ),
                            ),
                          );
                        },
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
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
                    const SizedBox(height: 8),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
          child: Column(
            children: [
              _continueLearningSection(context),
              const SizedBox(height: 16),
              _externalContentSection(context),
              const SizedBox(height: 16),
              _contentSection(context),
              const SizedBox(height: 16),
              _suggestedCoursesSection(context),
            ],
          ),
        ),
      ),
    );
  }
}