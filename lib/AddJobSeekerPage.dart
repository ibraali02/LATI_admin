import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  String gender = 'Male';
  File? _imageFile;
  File? _cvImageFile;

  List<String> cities = ["Misurata", "Tripoli", "Benghazi"];
  List<String> genders = ['Male', 'Female'];

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      setState(() {
        _imageFile = File(selectedImage.path);
      });
    }
  }

  Future<void> _pickCVImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? selectedCVImage = await _picker.pickImage(source: ImageSource.gallery);

    if (selectedCVImage != null) {
      setState(() {
        _cvImageFile = File(selectedCVImage.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _fetchUserData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          name = userDoc['name'] ?? '';
          email = userDoc['email'] ?? '';
          phone = userDoc['phone'] ?? '';
          city = userDoc['city'] ?? '';
          university = userDoc['university'] ?? '';
          age = userDoc['age'] ?? 0;
          isGraduate = userDoc['graduate'] ?? false;
          gender = userDoc['gender'] ?? 'Male';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  Future<void> _addJobSeeker() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        String? profileImageUrl;
        String? cvImageUrl;

        if (_imageFile != null) {
          profileImageUrl = await _uploadImage(_imageFile!, 'profile_images/${FirebaseAuth.instance.currentUser!.uid}.jpg');
        }

        if (_cvImageFile != null) {
          cvImageUrl = await _uploadImage(_cvImageFile!, 'cv_images/${FirebaseAuth.instance.currentUser!.uid}.jpg');
        }

        await FirebaseFirestore.instance.collection('job_seekers').add({
          'name': name,
          'email': email,
          'phone': phone,
          'city': city,
          'university': university,
          'age': age,
          'graduate': isGraduate,
          'gender': gender,
          'courses': [],
          'cv_image': cvImageUrl ?? 'N/A',
          'image': profileImageUrl ?? null,
        });

        Navigator.pop(context);
      }
    } catch (e) {
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
                ElevatedButton(
                  onPressed: _fetchUserData,
                  child: const Text('Fill with User Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF980E0E),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Image.file(
                      _imageFile!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image, size: 18),
                  label: const Text('Choose Profile Image'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF980E0E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    elevation: 5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(label: 'Name', onChanged: (value) => setState(() => name = value)),
                _buildTextField(label: 'Email', onChanged: (value) => setState(() => email = value)),
                _buildTextField(label: 'Phone', onChanged: (value) => setState(() => phone = value)),
                _buildDropdownField(),
                _buildTextField(label: 'University', onChanged: (value) => setState(() => university = value)),
                _buildTextField(label: 'Age', keyboardType: TextInputType.number, onChanged: (value) => setState(() => age = int.tryParse(value) ?? 0)),
                _buildGenderField(),
                CheckboxListTile(
                  title: const Text('Graduate'),
                  value: isGraduate,
                  onChanged: (bool? value) {
                    setState(() {
                      isGraduate = value ?? false;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CV Image:'),
                    ElevatedButton.icon(
                      onPressed: _pickCVImage,
                      icon: const Icon(Icons.image, size: 18),
                      label: const Text('Choose CV Image'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF980E0E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
                if (_cvImageFile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Image.file(
                      _cvImageFile!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addJobSeeker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF980E0E),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, TextInputType keyboardType = TextInputType.text, required Function(String) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: city,
        items: cities.map((String city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            city = newValue ?? '';
          });
        },
        decoration: const InputDecoration(
          labelText: 'City',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: gender,
        items: genders.map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(gender),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            gender = newValue ?? 'Male';
          });
        },
        decoration: const InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}