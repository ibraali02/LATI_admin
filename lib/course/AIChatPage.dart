import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIChatPage extends StatefulWidget {
  final String apiKey;

  const AIChatPage({super.key, required this.apiKey});

  @override
  _AIChatPageState createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  String _response = '';
  final List<String> _skills = [
    'Mobile App Development',
    'Web Development',
    'Python',
    'Java',
    'Artificial Intelligence',
    'Game Development',
    'C++',
    'JavaScript',
    'Data Analysis',
    'UI/UX Design',
    'Database Management',
    'R Programming',
    'PHP',
    'HTML & CSS',
    'Object-Oriented Programming',
    'Go',
    'Web Development with React',
    'Web Development with Angular',
    'Cloud Applications',
    'DevOps',
    'Cybersecurity',
    'Swift',
    'Kotlin',
    'Ruby',
    'Dart',
    'Agile Software Development',
    'Big Data',
  ];

  final List<String> _futureGoals = [
    'App Developer',
    'Web Developer',
    'Data Scientist',
    'AI Engineer',
    'Cybersecurity Expert',
    'Game Developer',
    'Software Engineer',
    'Technical Consultant',
    'Project Manager',
    'UI Developer',
    'Systems Analyst',
    'Database Developer',
    'Cloud Engineer',
    'Open Source Software Developer',
    'IT Manager',
    'Desktop Application Developer',
    'Machine Learning Developer',
    'Business Solutions Developer',
    'API Developer',
    'Network Engineer',
    'Data Analytics Consultant',
    'Technology Product Manager',
    'Data Analyst',
    'AI Research Scientist',
    'IT Operations Manager',
    'Technical Business Development Manager',
    'IT Consultant',
    'Digital Marketing Solutions Developer',
    'Augmented Reality App Developer',
    'Virtual Reality App Developer',
    'Secure Software Developer',
  ];

  List<bool> _selectedSkills = List.filled(30, false);
  String? _selectedGoal;
  String _selectedLanguage = 'English';

  Future<void> _generateRoadmap() async {
    if (widget.apiKey.isEmpty) {
      setState(() {
        _response = 'API Key is not set.';
      });
      return;
    }

    List<String> selectedSkills = [];
    for (int i = 0; i < _skills.length; i++) {
      if (_selectedSkills[i]) {
        selectedSkills.add(_skills[i]);
      }
    }

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: widget.apiKey);
    final content = [
      Content.text('I want to learn ${selectedSkills.isNotEmpty ? selectedSkills.join(", ") : "a skill"} to become ${_selectedGoal ?? "a professional in my field"}.')
    ];

    try {
      final response = await model.generateContent(content);
      setState(() {
        _response = response.text!;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          color: Colors.white, // خلفية بيضاء
          child: AppBar(
            title: Text(
              'AI Roadmap Generator',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Color(0xFFB00020), // لون الخط أحمر غامق
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white, // خلفية بيضاء
            elevation: 0, // إزالة ظل
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Your Skills:',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _skills.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSkills[index] = !_selectedSkills[index];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedSkills[index] ? Color(0xFFB00020) : Colors.white, // أحمر غامق عند التحديد
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFB00020)), // حدود أحمر غامق
                    ),
                    child: Center(
                      child: Text(
                        _skills[index],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _selectedSkills[index] ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'What Do You Want to Become?',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedGoal,
              hint: const Text('Select Your Goal'),
              isExpanded: true,
              items: _futureGoals.map((goal) {
                return DropdownMenuItem<String>(
                  value: goal,
                  child: Text(goal),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGoal = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Select Response Language:',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RadioListTile<String>(
              title: Text('English', style: GoogleFonts.poppins()),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Arabic', style: GoogleFonts.poppins()),
              value: 'Arabic',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateRoadmap,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFB00020)), // زر أحمر غامق
              child: Text(
                'Generate Roadmap',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Response:',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _response,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}