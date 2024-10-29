import 'package:flutter/material.dart';
import 'jobSeekersPage.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'jobs_page.dart';
import 'book_page.dart';

class HomeScreen extends StatefulWidget {
  final int selectedIndex; // إضافة هذه السطر

  const HomeScreen({super.key, this.selectedIndex = 0}); // القيمة الافتراضية 0

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex; // استخدام late

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex; // تعيين الفهرس المستلم
  }

  bool _isButtonPressed = false;
  final List<Widget> _pages = [
    const HomePage(),
    const ExplorePage(),
    const JobsPage(),
    const JobSeekersPage(), // الانتقال إلى صفحة الباحثين عن الوظائف هنا
    const BookPage(),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onFloatingButtonPressed() {
    setState(() {
      _isButtonPressed = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isButtonPressed = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageTransition(),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isButtonPressed ? 80 : 70,
        height: _isButtonPressed ? 80 : 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red[300],
        ),
        child: ClipOval(
          child: FloatingActionButton(
            backgroundColor: _selectedIndex == 4 || _isButtonPressed ? Colors.orange : Colors.red[900],
            elevation: 0,
            child: Image.asset(
              'images/book.png',
              fit: BoxFit.cover,
              width: 50,
              height: 50,
              color: _selectedIndex == 4 || _isButtonPressed ? Colors.white : Colors.white,
            ),
            onPressed: () {
              _onFloatingButtonPressed();
              setState(() {
                _selectedIndex = 4;
              });
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, -2),
              blurRadius: 8.0,
            ),
          ],
        ),
        child: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 60,
          shape: const CircularNotchedRectangle(),
          notchMargin: 5,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildAnimatedIcon(0, Icons.article), // أيقونة آخر الأخبار
              _buildAnimatedIcon(1, Icons.manage_search_sharp), // تغيير أيقونة البحث إلى أيقونة الكورسات
              const SizedBox(width: 48),
              _buildAnimatedIcon(2, Icons.work), // أيقونة الوظائف
              _buildAnimatedIcon(3, Icons.group), // أيقونة الباحثين عن العمل
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageTransition() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _pages[_selectedIndex],
      transitionBuilder: (Widget child, Animation<double> animation) {
        const offset = 0.5;
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(offset, 0.0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedIcon(int index, IconData icon) {
    bool isSelected = _selectedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: IconButton(
        icon: Icon(
          icon,
          color: isSelected ? Colors.orange : Colors.red[900], // استخدام البرتقالي عند التحديد
          size: isSelected ? 36 : 28,
        ),
        onPressed: () {
          _onItemTapped(index);
        },
      ),
    );
  }
}
