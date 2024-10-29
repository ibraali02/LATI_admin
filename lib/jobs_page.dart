import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'JobDetailPage.dart';
import 'package:provider/provider.dart';
import 'user_settings.dart'; // استيراد UserSettings

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  String? selectedCategory;
  double minSalary = 0;
  double maxSalary = 7000;
  List<Map<String, dynamic>> jobs = [];
  bool sortByLatest = false; // متغير لحفظ حالة الترتيب

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('new_jobs').get();

    final List<Map<String, dynamic>> fetchedJobs = result.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();

    setState(() {
      jobs = fetchedJobs;
      // فرز الوظائف حسب تاريخ النشر إذا كانت الحالة هي الأحدث
      if (sortByLatest) {
        jobs.sort((a, b) => b['publishedDate'].compareTo(a['publishedDate']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userSettings = Provider.of<UserSettings>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Job Listings',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false, // إزالة زر الرجوع
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (value) {
              setState(() {
                sortByLatest = value == 'latest';
                jobs.sort((a, b) => sortByLatest
                    ? b['publishedDate'].compareTo(a['publishedDate'])
                    : a['publishedDate'].compareTo(b['publishedDate']));
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'latest',
                  child: Text('Sort by Latest'),
                ),
                const PopupMenuItem<String>(
                  value: 'oldest',
                  child: Text('Sort by Oldest'),
                ),
              ];
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF980E0E),
                Color(0xFF330000),
              ],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      body: Container(
        color: userSettings.isDarkMode ? Colors.grey[850] : Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategories(),
              const SizedBox(height: 20),
              _buildSalaryRangeSlider(),
              const SizedBox(height: 20),
              _jobsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _categoryButton('All'),
          const SizedBox(width: 8),
          _categoryButton('Full Time'),
          const SizedBox(width: 8),
          _categoryButton('Part Time'),
          const SizedBox(width: 8),
          _categoryButton('Remote'),
          const SizedBox(width: 8),
          _categoryButton('Productivity-Based'),
        ],
      ),
    );
  }

  Widget _categoryButton(String title) {
    bool isSelected = selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = (isSelected && title == 'All') ? null : title;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red[800]!),
          borderRadius: BorderRadius.circular(30),
          color: isSelected ? Colors.red[100] : Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(title, style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSalaryRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Salary Range: LYD. ${minSalary.toInt()} - LYD. ${maxSalary.toInt()}',
          style: const TextStyle(fontSize: 16),
        ),
        RangeSlider(
          values: RangeValues(minSalary, maxSalary),
          min: 0,
          max: 7000,
          divisions: 70,
          labels: RangeLabels('${minSalary.toInt()}', '${maxSalary.toInt()}'),
          activeColor: Colors.red[800],
          inactiveColor: Colors.red[200],
          onChanged: (RangeValues values) {
            setState(() {
              minSalary = values.start;
              maxSalary = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _jobsList(BuildContext context) {
    final filteredJobs = jobs.where((job) {
      final isCategoryMatch = selectedCategory == null || selectedCategory == 'All' || job['category'] == selectedCategory;
      final isSalaryMatch = job['salary'] >= minSalary && job['salary'] <= maxSalary;
      return isCategoryMatch && isSalaryMatch;
    }).toList();

    if (filteredJobs.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد وظائف',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ),
      );
    }

    return Column(
      children: filteredJobs.asMap().entries.map<Widget>((entry) {
        int index = entry.key;
        Map<String, dynamic> job = entry.value;
        return _jobCard(context, job, index);
      }).toList(),
    );
  }

  Widget _jobCard(BuildContext context, Map<String, dynamic> job, int index) {
    final publishedDate = job['publishedDate'].toDate();
    final now = DateTime.now();
    final duration = now.difference(publishedDate);
    String publishedText;

    if (duration.inDays >= 1) {
      publishedText = '${duration.inDays} days ago';
    } else if (duration.inHours >= 1) {
      publishedText = '${duration.inHours} hours ago';
    } else {
      publishedText = '${duration.inMinutes} minutes ago';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailPage(
              title: job['title'],
              description: job['description'],
              salary: 'LYD. ${job['salary'].toStringAsFixed(0)}',
              imageUrl: job['imageUrl'],
              category: job['category'],
              publishedDate: publishedDate,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        color: Provider.of<UserSettings>(context).isDarkMode ? Colors.grey[800] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      job['imageUrl'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(job['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Text('LYD. ${job['salary'].toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(job['category'], style: TextStyle(color: Colors.grey[600])),
                  ),
                  Text(publishedText, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}