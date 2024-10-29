import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseDetailPage extends StatelessWidget {
  final String courseId; // معرف الكورس
  final String title;
  final String description;
  final String duration;
  final String imageUrl;
  final String location;
  final String category;
  final String publishedDate;

  const CourseDetailPage({
    Key? key,
    required this.courseId,
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
    final _formKey = GlobalKey<FormState>();
    String fullName = '';
    String phone = '';
    String email = ''; // متغير لحفظ البريد الإلكتروني
    String age = '';
    bool isGraduated = false;
    String residence = '';
    String nearestCity = '';
    bool hasJob = false;
    String qualification = '';
    String institution = '';
    String graduationDate = '';
    bool hasComputer = false;

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
              // صورة الدورة
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
              // تفاصيل الدورة
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
              _buildDetailRow(Icons.calendar_today, 'Duration: $duration', Colors.red),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.category, 'Category: $category', Colors.red),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.schedule, 'Published: $publishedDate', Colors.red),
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
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField('Full Name', (value) => fullName = value),
                    const SizedBox(height: 16),
                    _buildTextField('Phone Number', (value) => phone = value),
                    const SizedBox(height: 16),
                    _buildTextField('Email', (value) => email = value), // حقل البريد الإلكتروني
                    const SizedBox(height: 16),
                    _buildTextField('Age', (value) => age = value),
                    const SizedBox(height: 16),
                    _buildTextField('Residence', (value) => residence = value),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Nearest City',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF980E0E)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        DropdownMenuItem(value: 'Misrata', child: Text('Misrata')),
                        DropdownMenuItem(value: 'Tripoli', child: Text('Tripoli')),
                        DropdownMenuItem(value: 'Benghazi', child: Text('Benghazi')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          nearestCity = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField('Highest Qualification', (value) => qualification = value),
                    const SizedBox(height: 16),
                    _buildTextField('Institution', (value) => institution = value),
                    const SizedBox(height: 16),
                    _buildTextField('Graduation Date', (value) => graduationDate = value),
                    const SizedBox(height: 20),
                    // Checkboxes في النهاية
                    _buildCheckbox('Graduated?', isGraduated, (value) {
                      if (value != null) {
                        isGraduated = value;
                      }
                    }),
                    _buildCheckbox('Do you have a job?', hasJob, (value) {
                      if (value != null) {
                        hasJob = value;
                      }
                    }),
                    _buildCheckbox('Do you have a personal computer?', hasComputer, (value) {
                      if (value != null) {
                        hasComputer = value;
                      }
                    }),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          print("Validation successful, proceeding to registration");
                          try {
                            // إحضار التوكن من SharedPreferences
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String? userToken = prefs.getString('token'); // افترض أن التوكن مخزن هنا

                            // إضافة بيانات التسجيل إلى Firestore
                            await FirebaseFirestore.instance.collection('registration_requests').add({
                              'courseId': courseId,
                              'fullName': fullName,
                              'phone': phone,
                              'email': email,
                              'age': age,
                              'residence': residence,
                              'nearestCity': nearestCity,
                              'qualification': qualification,
                              'institution': institution,
                              'graduationDate': graduationDate,
                              'isGraduated': isGraduated,
                              'hasJob': hasJob,
                              'hasComputer': hasComputer,
                              'userToken': userToken, // إضافة التوكن إلى البيانات
                            });
                            print("Registration successful");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Registration successful!')),
                            );
                          } catch (e) {
                            print("Error during registration: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Registration failed: $e')),
                            );
                          }
                        } else {
                          print("Validation failed");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF980E0E),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Submit Registration', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
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

  Widget _buildTextField(String label, Function(String) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF980E0E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF980E0E)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF980E0E),
        ),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}