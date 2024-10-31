import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Updates'),
        backgroundColor: Colors.red[800], // Dark red background for the app bar
      ),
      body: Column(
        children: [
          Expanded(child: _buildRecentCourses()),
          const Divider(),
          Expanded(child: _buildRecentJobs()),
        ],
      ),
    );
  }

  Widget _buildRecentCourses() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('courses').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching courses'));
        }

        final courses = snapshot.data?.docs;

        return ListView.builder(
          itemCount: courses?.length ?? 0,
          itemBuilder: (context, index) {
            final course = courses![index].data() as Map<String, dynamic>;
            return _courseCard(course);
          },
        );
      },
    );
  }

  Widget _courseCard(Map<String, dynamic> course) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.blue[100], // Light blue background for courses
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.school, color: Colors.blue[900]), // Course icon
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue, // Title color
                    ),


                  ),
                  const SizedBox(height: 8),
                  Text(
                    course['description'] ?? 'No Description',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(course['date']),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentJobs() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('new_jobs').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching jobs'));
        }

        final jobs = snapshot.data?.docs;

        return ListView.builder(
          itemCount: jobs?.length ?? 0,
          itemBuilder: (context, index) {
            final job = jobs![index].data() as Map<String, dynamic>;
            return _jobCard(job);
          },
        );
      },
    );
  }

  Widget _jobCard(Map<String, dynamic> job) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.green[100], // Light green background for jobs
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.work, color: Colors.green[900]), // Job icon
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // Title color
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['description'] ?? 'No Description',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(job['date']),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      DateTime dateTime = date.toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (date is String) {
      return date; // أو يمكنك إضافة منطق لتحويل السلسلة إلى تاريخ إذا كان ذلك ممكنًا
    }
    return 'Unknown date';
  }
}
