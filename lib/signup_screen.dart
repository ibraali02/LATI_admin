import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Male';
  String _userType = 'Individual';
  String _selectedCity = 'Tripoli';
  bool _isGraduated = false;
  bool _isNotGraduated = false;
  bool _isLoading = false;
  File? _image;

  final List<String> _cities = [
    'Tripoli', 'Benghazi', 'Misrata', 'Zliten', 'Tobruk', 'Derna',
    'Sabratha', 'Ajdabiya', 'Al Khums', 'Sirte', 'Bani Walid', 'Sabha',
    'Murzuq', 'Ghat', 'Jalu', 'Nalut', 'Zawiya', 'Al Bayda', 'Al Marj',
    'Kufra', 'Ras Lanuf', 'Brak', 'Al Jufra', 'Qasr Libya',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _showSnackBar(String message) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? selectedImage = await picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(userCredential.user!.uid);
      }
      await _saveUserData(userCredential.user, imageUrl);
    } catch (e) {
      await _showSnackBar('فشل إنشاء الحساب: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _uploadImage(String userId) async {
    try {
      final Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
      await storageRef.putFile(_image!);
      String imageUrl = await storageRef.getDownloadURL();
      return imageUrl;
    } catch (e) {
      await _showSnackBar('فشل تحميل الصورة: $e');
      return null;
    }
  }

  Future<void> _saveUserData(User? user, String? imageUrl) async {
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'user_type': _userType,
        'city': _userType == 'Individual' ? _selectedCity : null,
        'age': _userType == 'Individual' ? int.tryParse(_ageController.text.trim()) : null,
        'gender': _userType == 'Individual' ? _gender : null,
        'graduation_status': _isGraduated ? 'Graduated' : (_isNotGraduated ? 'Not Graduated' : null),
        'company_name': _userType == 'Company' ? _companyNameController.text.trim() : null,
        'image_url': imageUrl, // حفظ رابط الصورة
        'created_at': Timestamp.now(),
      });
      await _showSnackBar('تم إنشاء الحساب بنجاح!');
      Navigator.pop(context);
    } catch (e) {
      await _showSnackBar('فشل حفظ بيانات المستخدم: $e');
    }
  }

  void _showCompanyInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("معلومات مهمة"),
          content: const Text("إذا قمت بالتسجيل كحساب شركة، لا يمكنك عرض سيرتك الذاتية في الباحثين عن العمل ولا يمكنك التسجيل في الدورات."),
          actions: [
            TextButton(onPressed: () { Navigator.of(context).pop(); }, child: const Text("حسنا")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8B0000),
                  Color(0xFF800000),
                  Color(0xFFFF5E5E),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "تسجيل حساب",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _userTypeButton("فرد"),
                      const SizedBox(width: 10),
                      _userTypeButton("شركة"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    margin: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF8B0000), width: 3),
                                  ),
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: _image != null ? FileImage(_image!) : null,
                                    child: _image == null
                                        ? const Icon(Icons.camera_alt, color: Colors.white)
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_userType == 'Individual') ...[
                              Row(
                                children: [
                                  Expanded(child: _buildTextField(_firstNameController, "الاسم الأول", Icons.person)),
                                  const SizedBox(width: 10),
                                  Expanded(child: _buildTextField(_lastNameController, "الاسم الأخير", Icons.person)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _buildDropdownField(),
                              const SizedBox(height: 10),
                              _buildTextField(_ageController, "العمر", Icons.calendar_today, TextInputType.number),
                              const SizedBox(height: 10),
                              _buildGenderField(),
                              const SizedBox(height: 10),
                              _buildGraduationStatusField(),
                            ],
                            const SizedBox(height: 10),
                            _buildTextField(_emailController, "البريد الإلكتروني", Icons.email),
                            const SizedBox(height: 10),
                            _buildTextField(_phoneController, "رقم الهاتف", Icons.phone),
                            const SizedBox(height: 10),
                            if (_userType == 'Company') ...[
                              _buildTextField(_companyNameController, "اسم الشركة", Icons.business),
                            ],
                            const SizedBox(height: 20),
                            _buildPasswordField(_passwordController, "كلمة المرور", Icons.lock),
                            const SizedBox(height: 10),
                            _buildPasswordField(_confirmPasswordController, "تأكيد كلمة المرور", Icons.lock),
                            const SizedBox(height: 20),
                            _buildSignUpButton(),
                            const SizedBox(height: 20),
                            _buildLoginLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userTypeButton(String userType) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _userType = userType;
          if (userType == 'Company') _showCompanyInfoDialog();
        });
      },
      child: Text(userType),
      style: ElevatedButton.styleFrom(
        foregroundColor: _userType == userType ? Colors.white : Colors.grey[800],
        backgroundColor: _userType == userType ? const Color(0xFF600000) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("الجنس:", style: TextStyle(color: Colors.black, fontSize: 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _genderButton("ذكر", 'Male'),
            _genderButton("أنثى", 'Female'),
          ],
        ),
      ],
    );
  }

  Widget _genderButton(String text, String value) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _gender = value;
        });
      },
      child: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: _gender == value ? Colors.white : const Color(0xFF8B0000),
        backgroundColor: _gender == value ? const Color(0xFF8B0000) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildGraduationStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("حالة التخرج:", style: TextStyle(color: Colors.black, fontSize: 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _graduationButton("متخرج", true),
            _graduationButton("غير متخرج", false),
          ],
        ),
      ],
    );
  }

  Widget _graduationButton(String text, bool isGraduated) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isGraduated = isGraduated;
          _isNotGraduated = !isGraduated;
        });
      },
      child: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: _isGraduated == isGraduated ? Colors.white : const Color(0xFF8B0000),
        backgroundColor: _isGraduated == isGraduated ? const Color(0xFF8B0000) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedCity,
      decoration: InputDecoration(
        labelText: "المدينة",
        prefixIcon: const Icon(Icons.location_city, color: Color(0xFF8B0000)),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF8B0000), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF8B0000), width: 2),
        ),
      ),
      items: _cities.map<DropdownMenuItem<String>>((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city, style: const TextStyle(color: Color(0xFF8B0000))),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCity = newValue!;
        });
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF8B0000)),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8B0000)),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF8B0000), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF8B0000), width: 2),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'يرجى إدخال $hintText';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hintText, IconData icon) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF8B0000)),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8B0000)),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF8B0000), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF8B0000), width: 2),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'يرجى إدخال $hintText';
        }
        return null;
      },
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signUp,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF600000),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _isLoading ? const CircularProgressIndicator() : const Text("إنشاء حساب"),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("هل لديك حساب بالفعل؟", style: TextStyle(color: Colors.black)),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Text(
            "تسجيل الدخول",
            style: TextStyle(color: Colors.black, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}