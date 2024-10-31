import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseDetailPage extends StatelessWidget {
  final String courseId;
  final String title;
  final String description;
  final String duration;
  final String imageUrl;
  final String location;
  final String category;
  final String publishedDate;
  final String price;

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
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String fullName = '';
    String phone = '';
    String email = '';
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
        title: Text(title.isNotEmpty ? title : "عنوان غير متوفر"),
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
                child: Container(
                  color: Colors.white,
                  child: Image.network(
                    imageUrl.isNotEmpty ? imageUrl : "رابط صورة افتراضية",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // تفاصيل الدورة
              Text(
                title.isNotEmpty ? title : "عنوان غير متوفر",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF330000),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description.isNotEmpty ? description : "لا توجد تفاصيل",
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              // تفاصيل إضافية
              _buildDetailRow(Icons.location_pin, location.isNotEmpty ? location : "موقع غير متوفر", Colors.red),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.calendar_today, 'Duration: ${duration.isNotEmpty ? duration : "مدة غير متوفرة"}', Colors.red),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.category, 'Category: ${category.isNotEmpty ? category : "فئة غير متوفرة"}', Colors.red),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.schedule, 'Published: ${publishedDate.isNotEmpty ? publishedDate : "تاريخ غير متوفر"}', Colors.red),
              const SizedBox(height: 16),
              // عرض السعر
              Text(
                'Price: ${price.isNotEmpty && price != '0' ? '\$${price}' : 'مجاني'}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 16),
              // زر الدفع
              if (price.isNotEmpty && price != '0')
                ElevatedButton(
                  onPressed: () {
                    _showPaymentOptions(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF980E0E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('ادفع الآن', style: TextStyle(color: Colors.white)),
                ),
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
                    _buildTextField('Email', (value) => email = value),
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
                            String? userToken = prefs.getString('token');

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
                              'userToken': userToken,
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

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildPaymentOption('images/sdad.png', context),
                    _buildPaymentOption('images/mobe.png', context),
                    _buildPaymentOption('images/bay.png', context),
                    _buildPaymentOption('images/yosr.png', context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(String imagePath, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showPaymentDialog(context);
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white),
        ),
        alignment: Alignment.center,
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    final _dialogKey = GlobalKey<FormState>();
    String accountCode = '';
    String paymentAmount = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Information'),
          content: Form(
            key: _dialogKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'User Account Code'),
                  onChanged: (value) => accountCode = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your account code';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Payment Amount'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => paymentAmount = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the payment amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Note: The amount is non-refundable unless you visit the company headquarters and will not be refunded once the course starts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_dialogKey.currentState!.validate()) {
                  // هنا يمكنك إضافة منطق الدفع
                  print('User Account Code: $accountCode');
                  print('Payment Amount: $paymentAmount');
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment processed successfully!')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
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