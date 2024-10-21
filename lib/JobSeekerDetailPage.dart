import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // استيراد الحزمة اللازمة

class JobSeekerDetailPage extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String cv;
  final String image;

  const JobSeekerDetailPage({
    Key? key,
    required this.name,
    required this.email,
    required this.phone,
    required this.cv,
    required this.image,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ النص إلى الحافظة!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: const Color(0xFF980E0E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Image.network(
                  image,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Name: $name',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Email: $email', context, email),
              const SizedBox(height: 8),
              _buildInfoRow('Phone: $phone', context, phone),
              const SizedBox(height: 16),
              Text(
                'CV: $cv',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // هنا يمكنك إضافة أي إجراء آخر
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF980E0E), // لون الخلفية
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text(
                  'Download CV',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, BuildContext context, String text) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => _copyToClipboard(context, text),
        ),
      ],
    );
  }
}