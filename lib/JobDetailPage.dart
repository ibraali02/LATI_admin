import 'package:flutter/material.dart';

class JobDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String salary;
  final String imageUrl;
  final String category;
  final DateTime publishedDate;

  const JobDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.salary,
    required this.imageUrl,
    required this.category,
    required this.publishedDate,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final duration = now.difference(publishedDate);
    String publishedText;

    if (duration.inDays >= 1) {
      publishedText = '${duration.inDays} days ago';
    } else if (duration.inHours >= 1) {
      publishedText = '${duration.inHours} hours ago';
    } else {
      publishedText = '${duration.inMinutes} minutes ago';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.red[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Salary: $salary', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Category: $category', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Published: $publishedText', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(description),
          ],
        ),
      ),
    );
  }
}