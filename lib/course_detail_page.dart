import 'package:flutter/material.dart';

class CourseDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String duration;
  final String imageUrl;
  final String location;
  final String category;
  final String publishedDate;

  const CourseDetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.duration,
    required this.imageUrl,
    required this.location,
    required this.category,
    required this.publishedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF980E0E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الكورس
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              // تفاصيل الكورس
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF330000),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              // تفاصيل إضافية
              _buildDetailRow(Icons.location_pin, location, Colors.red),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.calendar_today, 'Duration: $duration', Colors.blue),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.category, 'Category: $category', Colors.green),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.schedule, 'Published: $publishedDate', Colors.orange),
              const SizedBox(height: 16),
              // حقول التسجيل
              Text(
                'Register Now:',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF330000),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('Name'),
              const SizedBox(height: 16),
              _buildTextField('Email'),
              const SizedBox(height: 16),
              _buildTextField('Phone Number'),
              const SizedBox(height: 16),
              _buildTextField('City'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // منطق التسجيل يمكن إضافته هنا
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registered successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF980E0E), // لون الزر
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Submit Registration'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget _buildTextField(String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}
