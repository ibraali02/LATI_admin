import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      await _fetchUserData();
    }
    setState(() {});
  }

  Future<void> _fetchUserData() async {
    if (_user == null) return;

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          _userData = snapshot.data() as Map<String, dynamic>;
        });
      } else {
        print('No user data found.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _editField(String field) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFieldPage(field: field, initialValue: _userData?[field]),
      ),
    ).then((_) => _fetchUserData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xffb71111c),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _userData != null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _userData!['image_url'] != null
                    ? NetworkImage(_userData!['image_url'])
                    : const AssetImage('assets/default_profile.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            _buildProfileField(Icons.person, 'Full Name', '${_userData?['first_name']} ${_userData?['last_name']}', 'full_name'),
            _buildProfileField(Icons.email, 'Email', _userData?['email'], 'email'),
            _buildProfileField(Icons.phone, 'Phone', _userData?['phone'], 'phone'),
            _buildProfileField(Icons.cake, 'Age', _userData?['age']?.toString(), 'age'),
            _buildProfileField(Icons.wc, 'Gender', _userData?['gender'], 'gender'),
            _buildProfileField(Icons.location_city, 'City', _userData?['city'], 'city'),
            if (_userData?['user_type'] != 'Individual')
              _buildProfileField(Icons.business, 'Company Name', _userData?['company_name'], 'company_name'),
            _buildProfileField(Icons.lock, 'Password', '********', 'password'), // حقل كلمة المرور
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProfileField(IconData icon, String title, String? value, String field) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xffb71111c)), // أيقونة الحقل
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300)), // Smaller, lighter font
                    const SizedBox(height: 5),
                    Text(value ?? 'No data', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Larger, bold font
                  ],
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xffb71111c)),
              onPressed: () => _editField(field),
            ),
          ],
        ),
      ),
    );
  }
}

class EditFieldPage extends StatefulWidget {
  final String field;
  final String? initialValue;

  const EditFieldPage({super.key, required this.field, this.initialValue});

  @override
  _EditFieldPageState createState() => _EditFieldPageState();
}

class _EditFieldPageState extends State<EditFieldPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.field}'),
        backgroundColor: const Color(0xffb71111c),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: widget.field,
                border: const OutlineInputBorder(),
              ),
              obscureText: widget.field == 'password', // إخفاء النص في حقل كلمة المرور
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({widget.field: _controller.text}).then((_) {
                  Navigator.pop(context);
                }).catchError((error) {
                  print('Error updating field: $error');
                });
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
