import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddJobSeekerPage.dart';

class JobSeekersPage extends StatefulWidget {
  const JobSeekersPage({Key? key}) : super(key: key);

  @override
  _JobSeekersPageState createState() => _JobSeekersPageState();
}

class _JobSeekersPageState extends State<JobSeekersPage> {
  List<Map<String, dynamic>> jobSeekers = [];
  List<String> selectedCourses = [];
  bool isGraduate = false;
  String selectedCity = 'All Cities';
  bool isLoading = true; // حالة التحميل

  @override
  void initState() {
    super.initState();
    _fetchJobSeekers();
  }

  Future<void> _fetchJobSeekers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('job_seekers_accepted').get();
      List<Map<String, dynamic>> fetchedJobSeekers = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'],
          'email': data['email'],
          'phone': data['phone'],
          'cv_image': data['cv_image'] ?? 'N/A',
          'image': data['image'] ?? 'https://firebasestorage.googleapis.com/v0/b/lati2-73bf9.appspot.com/o/job_seekers%2F1729182040160.png?alt=media&token=74c341c3-7eeb-4f3a-873d-cde29f9c6fc5',
          'courses': List<String>.from(data['courses'] ?? []),
          'graduate': data['graduate'] ? 'Graduate' : 'Student',
          'city': data['city'] ?? 'Unknown',
          'age': data['age'],
          'university': data['university'],
        };
      }).toList();

      setState(() {
        jobSeekers = fetchedJobSeekers;
        isLoading = false; // تعيين حالة التحميل إلى false بعد الانتهاء
      });
    } catch (e) {
      print('Error fetching job seekers: $e');
      setState(() {
        isLoading = false; // تعيين حالة التحميل إلى false حتى في حالة الخطأ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Seekers', style: TextStyle(color: Colors.white)),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // عرض مؤشر التحميل
          : Column(
        children: [
          _buildCityFilters(),
          _buildFilters(),
          Expanded(child: _buildJobSeekersList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF980E0E),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddJobSeekerPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCityFilters() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.grey[200],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['All Cities', 'Misrata', 'Tripoli', 'Benghazi'].map((city) {
            final isSelected = selectedCity == city;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCity = city;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF980E0E) : Colors.white,
                  border: Border.all(color: isSelected ? Colors.white : const Color(0xFF980E0E)),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.only(right: 10),
                child: Text(
                  city,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF980E0E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        _buildCourseFilters(),
        _buildGraduateCheckbox(),
      ],
    );
  }

  Widget _buildCourseFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['App Development', 'Cyber Security', 'Cloud Computing'].map((course) {
          final isSelected = selectedCourses.contains(course);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedCourses.remove(course);
                } else {
                  selectedCourses.add(course);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF980E0E) : Colors.white,
                border: Border.all(color: isSelected ? Colors.white : const Color(0xFF980E0E)),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: const EdgeInsets.only(right: 10),
              child: Text(
                course,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF980E0E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGraduateCheckbox() {
    return CheckboxListTile(
      title: const Text("Graduate"),
      value: isGraduate,
      onChanged: (bool? value) {
        setState(() {
          isGraduate = value ?? false;
        });
      },
    );
  }

  Widget _buildJobSeekersList() {
    final filteredJobSeekers = jobSeekers.where((seeker) {
      if (selectedCity != 'All Cities' && seeker['city'] != selectedCity) return false;
      bool matchesCourses = selectedCourses.isEmpty || seeker['courses'].any((course) => selectedCourses.contains(course));
      bool matchesGraduate = isGraduate ? seeker['graduate'] == 'Graduate' : true;
      return matchesCourses && matchesGraduate;
    }).toList();

    if (filteredJobSeekers.isEmpty) {
      return Center(
        child: Text(
          'No job seekers available',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredJobSeekers.length,
      itemBuilder: (context, index) {
        final seeker = filteredJobSeekers[index];
        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        seeker['name'],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        seeker['city'],
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          seeker['image'] ?? 'https://firebasestorage.googleapis.com/v0/b/lati2-73bf9.appspot.com/o/job_seekers%2F1729182040160.png?alt=media&token=74c341c3-7eeb-4f3a-873d-cde29f9c6fc5',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('University: ${seeker['university']}', style: TextStyle(color: Colors.grey[600])),
                            Text('Age: ${seeker['age']}', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: seeker['courses'].map<Widget>((course) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          course,
                          style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle view details action
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF980E0E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}