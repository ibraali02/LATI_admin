import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // استيراد مكتبة Firestore
import 'package:image_picker/image_picker.dart'; // استيراد حزمة اختيار الصورة
import 'dart:io'; // لاستيراد فئة File

class AddJobSeekerPage extends StatefulWidget {
  const AddJobSeekerPage({super.key});

  @override
  _AddJobSeekerPageState createState() => _AddJobSeekerPageState();
}

class _AddJobSeekerPageState extends State<AddJobSeekerPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String phone = '';
  String city = '';
  String university = '';
  int age = 0;
  bool isGraduate = false;
  String cv = 'N/A';
  File? _imageFile;

  List<String> cities = ["Misurata", "Tripoli", "Benghazi"]; // قائمة المدن

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      setState(() {
        _imageFile = File(selectedImage.path);
      });
    }
  }

  Future<void> _addJobSeeker() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        await FirebaseFirestore.instance.collection('job_seekers').add({
          'name': name,
          'email': email,
          'phone': phone,
          'city': city,
          'university': university,
          'age': age,
          'graduate': isGraduate,
          'courses': [],
          'cv': cv,
          'image': _imageFile != null ? _imageFile!.path : null,
        });

        Navigator.pop(context);
      }
    } catch (e) {
      print('Error adding job seeker: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding job seeker: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Job Seeker', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF980E0E), Color(0xFF330000)],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(label: 'Name', onChanged: (value) => setState(() => name = value)),
                _buildTextField(label: 'Email', onChanged: (value) => setState(() => email = value)),
                _buildTextField(label: 'Phone', onChanged: (value) => setState(() => phone = value)),
                _buildDropdownField(),
                _buildTextField(label: 'University', onChanged: (value) => setState(() => university = value)),
                _buildTextField(label: 'Age', keyboardType: TextInputType.number, onChanged: (value) => setState(() => age = int.tryParse(value) ?? 0)),
                CheckboxListTile(
                  title: const Text('Graduate'),
                  value: isGraduate,
                  onChanged: (bool? value) {
                    setState(() {
                      isGraduate = value ?? false;
                    });
                  },
                ),
                _buildTextField(label: 'CV (leave as N/A if not available)', onChanged: (value) => setState(() => cv = value)),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Image.file(
                      _imageFile!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Image:'),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image, size: 18), // أيقونة الصورة
                      label: const Text('Choose Image'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: const Color(0xFF980E0E), // لون النص
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        elevation: 5, // إضافة ظل
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addJobSeeker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF980E0E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    elevation: 5, // إضافة ظل
                  ),
                  child: const Text('Add Job Seeker', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFF980E0E), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFF980E0E), width: 2),
        ),
      ),
      onChanged: onChanged,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'City',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFF980E0E), width: 2),
        ),
      ),
      value: city.isEmpty ? null : city,
      items: cities.map((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          city = value ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a city';
        }
        return null;
      },
    );
  }
}