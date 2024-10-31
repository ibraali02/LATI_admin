import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:untitled9/user_settings.dart';
import 'JobDetailPage.dart';

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
  bool sortByLatest = false;

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
      if (sortByLatest) {
        jobs.sort((a, b) => b['publishedDate'].compareTo(a['publishedDate']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على إعدادات المستخدم من Provider
    final userSettings = Provider.of<UserSettings>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          userSettings.currentLanguage == 'en' ? 'Job Listings' : 'قائمة الوظائف',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: userSettings.isDarkMode
                  ? [Colors.black, Colors.grey[800]!]
                  : [Color(0xFF980E0E), Color(0xFF330000)],
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
              _buildSalaryRangeSlider(userSettings),
              const SizedBox(height: 20),
              _jobsList(context, userSettings),
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
        child: Text(
          title,
          style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSalaryRangeSlider(UserSettings userSettings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userSettings.currentLanguage == 'en'
              ? 'Salary Range: LYD. ${minSalary.toInt()} - LYD. ${maxSalary.toInt()}'
              : 'نطاق الراتب: LYD. ${minSalary.toInt()} - LYD. ${maxSalary.toInt()}',
          style: TextStyle(
            fontSize: 16,
            color: userSettings.isDarkMode ? Colors.white : Colors.black, // لون النص حسب الوضع
          ),
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

  Widget _jobsList(BuildContext context, UserSettings userSettings) {
    final filteredJobs = jobs.where((job) {
      final isCategoryMatch = selectedCategory == null || selectedCategory == 'All' || job['category'] == selectedCategory;
      final isSalaryMatch = job['salary'] >= minSalary && job['salary'] <= maxSalary;
      return isCategoryMatch && isSalaryMatch;
    }).toList();

    if (filteredJobs.isEmpty) {
      return Center(
        child: Text(
          userSettings.currentLanguage == 'en' ? 'No Jobs Available' : 'لا يوجد وظائف',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ),
      );
    }

    return Column(
      children: filteredJobs.asMap().entries.map<Widget>((entry) {
        int index = entry.key;
        Map<String, dynamic> job = entry.value;
        return _jobCard(context, job, index, userSettings);
      }).toList(),
    );
  }

  Widget _jobCard(BuildContext context, Map<String, dynamic> job, int index, UserSettings userSettings) {
    final publishedDate = job['publishedDate'].toDate();
    final now = DateTime.now();
    final duration = now.difference(publishedDate);
    String publishedText;

    if (duration.inDays >= 1) {
      publishedText = '${duration.inDays} ${userSettings.currentLanguage == 'en' ? 'days ago' : 'أيام مضت'}';
    } else if (duration.inHours >= 1) {
      publishedText = '${duration.inHours} ${userSettings.currentLanguage == 'en' ? 'hours ago' : 'ساعات مضت'}';
    } else {
      publishedText = '${duration.inMinutes} ${userSettings.currentLanguage == 'en' ? 'minutes ago' : 'دقائق مضت'}';
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
        color: userSettings.isDarkMode ? Colors.grey[850] : Colors.white,
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
                        Text(
                          job['title'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // لون النص في الداكن
                        ),
                        const SizedBox(height: 8),
                        Text(
                          publishedText,
                          style: TextStyle(color: userSettings.isDarkMode ? Colors.grey[300] : Colors.grey[600]), // لون النص في الداكن
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                job['description'],
                style: TextStyle(
                  color: userSettings.isDarkMode ? Colors.grey[300] : Colors.grey[700], // لون النص في الداكن
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Salary: LYD. ${job['salary'].toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: userSettings.isDarkMode ? Colors.white : Colors.black, // لون النص حسب الوضع
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
