import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatePage extends StatefulWidget {
  const RatePage({super.key});

  @override
  _RatePageState createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  List<Map<String, dynamic>> _ratings = [];
  bool _isLoading = true;
  String _userToken = '';

  @override
  void initState() {
    super.initState();
    _loadUserToken();
  }

  Future<void> _loadUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userToken = prefs.getString('token') ?? '';
    await _fetchRatings();
  }

  Future<void> _fetchRatings() async {
    if (_userToken.isNotEmpty) {
      try {
        // ابحث عن الطالب في مجموعة accepted_students للكورس
        QuerySnapshot acceptedStudentsSnapshot = await FirebaseFirestore.instance
            .collection('courses') // تأكد من أن هذه المجموعة صحيحة
            .doc('courseId') // استبدل 'courseId' بمعرف الكورس
            .collection('accepted_students')
            .where('userToken', isEqualTo: _userToken)
            .get();

        if (acceptedStudentsSnapshot.docs.isNotEmpty) {
          // إذا تم العثور على الطالب، اجلب التقييمات من مجموعة ratings الخاصة بالكورس
          QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
              .collection('courses')
              .doc('courseId') // استخدم نفس معرف الكورس
              .collection('ratings') // تأكد من وجود مجموعة ratings
              .get();

          if (ratingsSnapshot.docs.isNotEmpty) {
            setState(() {
              _ratings = ratingsSnapshot.docs.map((ratingDoc) {
                return {
                  'title': ratingDoc['title'], // تأكد من وجود حقل title
                  'rating': ratingDoc['rating'] ?? 0, // تأكد من وجود حقل rating
                };
              }).toList();
            });
          } else {
            setState(() {
              _ratings = []; // لا توجد تقييمات
            });
          }
        } else {
          setState(() {
            _ratings = []; // الطالب غير موجود، لا توجد تقييمات
          });
        }
      } catch (e) {
        print("Error fetching ratings: $e");
      }
    } else {
      print("User token is empty.");
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _showRatingDialog(String title, int index) {
    double rating = _ratings[index]['rating'].toDouble();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF980E0E),
                  const Color(0xFFFF5A5A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rate $title',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      value: rating,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: rating.round().toString(),
                      activeColor: Colors.yellow,
                      inactiveColor: Colors.grey,
                      onChanged: (double value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),
                    Text(
                      'Rating: ${rating.round()}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _ratings[index]['rating'] = rating.round();
                              // تحديث التقييم في Firestore
                              _updateRatingInFirestore(title, rating.round());
                            });
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.yellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          ),
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateRatingInFirestore(String title, int rating) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc('courseId') // استخدم ID المستند المناسب
          .collection('ratings')
          .doc(title) // استخدم عنوان الكورس كمعرف المستند
          .update({'rating': rating});
    } catch (e) {
      print("Error updating rating: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF980E0E),
              Color(0xFFFF5A5A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Rate',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ratings.isEmpty
          ? const Center(child: Text('لا توجداسابييع لتقييمها'))
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: _ratings.asMap().entries.map((entry) {
          int index = entry.key;
          var rating = entry.value;

          return _buildRatingCard(rating['title'], rating['rating'], index);
        }).toList(),
      ),
    );
  }

  Widget _buildRatingCard(String title, int rating, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                );
              }),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showRatingDialog(title, index);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF980E0E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  elevation: 5,
                ),
                child: const Text('Rate Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}