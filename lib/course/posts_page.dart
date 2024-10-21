import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // استيراد خطوط Google

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        backgroundColor: Colors.white, // لون خلفية العنوان أبيض
        foregroundColor: const Color(0xFF980E0E), // لون النص في الـ AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildWorkshopCard(
              context, // تمرير context هنا
              title: 'Workshop on Flutter Development',
              date: 'October 25, 2024',
              time: '3:00 PM - 5:00 PM',
              description: 'Join us for an exciting workshop on Flutter development where you will learn to build beautiful apps.',
            ),
            const SizedBox(height: 16),
            _buildWorkshopCard(
              context, // تمرير context هنا
              title: 'UI/UX Design Principles',
              date: 'November 1, 2024',
              time: '10:00 AM - 1:00 PM',
              description: 'Explore the fundamentals of UI/UX design and how to create user-friendly interfaces.',
            ),
            const SizedBox(height: 16),
            _buildWorkshopCard(
              context, // تمرير context هنا
              title: 'Backend Development with Node.js',
              date: 'November 8, 2024',
              time: '2:00 PM - 4:00 PM',
              description: 'Learn how to create scalable backend services using Node.js and Express.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkshopCard(
      BuildContext context, { // إضافة BuildContext كمعامل
        required String title,
        required String date,
        required String time,
        required String description,
      }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // زوايا دائرية للكارد
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF980E0E), // لون النص
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // وظيفة عند الضغط على الزر
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registered for the workshop!')),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: const Color(0xFF980E0E), // لون نص الزر
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // زوايا دائرية للزر
                ),
              ),
              child: const Text('Register Now'),
            ),
          ],
        ),
      ),
    );
  }
}
