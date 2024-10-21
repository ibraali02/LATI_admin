import 'package:flutter/material.dart';

class RatePage extends StatefulWidget {
  const RatePage({super.key});

  @override
  _RatePageState createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  final List<Map<String, dynamic>> _ratings = [
    {'title': 'Week 1: Kotlin', 'rating': 0},
    {'title': 'Week 2: Kotlin', 'rating': 0},
    {'title': 'Week 3: Kotlin', 'rating': 0},
    {'title': 'Week 4: UI/UX', 'rating': 0},
    {'title': 'Week 5: Backend', 'rating': 0},
    {'title': 'Week 6: Flutter', 'rating': 0},
    {'title': 'Week 7: Flutter', 'rating': 0},
    {'title': 'Week 8: Flutter', 'rating': 0},
  ];

  void _showRatingDialog(String title, int index) {
    double rating = _ratings[index]['rating'].toDouble(); // الحصول على التقييم الحالي
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // زوايا دائرية
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF980E0E), // اللون الأحمر الداكن
                  const Color(0xFFFF5A5A), // اللون الأحمر الفاتح
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
                        color: Colors.white, // لون النص
                      ),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      value: rating,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: rating.round().toString(),
                      activeColor: Colors.yellow, // لون شريط التقييم النشط
                      inactiveColor: Colors.grey,
                      onChanged: (double value) {
                        setState(() {
                          rating = value; // تحديث القيمة
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
                              _ratings[index]['rating'] = rating.round(); // حفظ التقييم
                            });
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Colors.yellow, // لون النص
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0), // زوايا دائرية للزر
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0), // حجم الزر
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF980E0E), // اللون الأحمر الداكن
              Color(0xFFFF5A5A), // اللون الأحمر الفاتح
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
        backgroundColor: Colors.transparent, // يجعل شريط العنوان شفافًا
        elevation: 0,
      ),
      body: ListView(
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
      elevation: 8, // زيادة الظل
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // زوايا دائرية
      ),
      color: Colors.white, // لون خلفية الكارد
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
                color: Colors.red, // لون العنوان
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
            Center( // إضافة Center هنا لجعل الزر في المنتصف
              child: ElevatedButton(
                onPressed: () {
                  _showRatingDialog(title, index); // فتح دايلوج التقييم عند الضغط على الزر
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: const Color(0xFF980E0E), // لون النص
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // زوايا دائرية للزر
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0), // زيادة حجم الزر
                  elevation: 5, // ظل للزر
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
