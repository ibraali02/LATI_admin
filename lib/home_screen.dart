import 'package:flutter/material.dart';
import 'jobSeekersPage.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'jobs_page.dart';
import 'book_page.dart';
import 'package:provider/provider.dart';
import 'user_settings.dart';

class HomeScreen extends StatefulWidget {
  final int selectedIndex;

  const HomeScreen({super.key, this.selectedIndex = 0});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  bool _isButtonPressed = false;
  final List<Widget> _pages = [
    const HomePage(),
    const ExplorePage(),
    const JobsPage(),
    const JobSeekersPage(),
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
    // الحصول على إعدادات المستخدم من Provider
    final userSettings = Provider.of<UserSettings>(context);

    // تحديد الألوان وفقًا لوضع الداكن
    final backgroundColor = userSettings.isDarkMode ? Colors.black : Colors.white;
    final bottomNavBarColor = userSettings.isDarkMode ? Colors.grey[850] : Colors.white;
    final iconColor = userSettings.isDarkMode ? Colors.white : Colors.red;
    final textColor = userSettings.isDarkMode ? Colors.white : Colors.black; // لون النص

    return Scaffold(
      backgroundColor: backgroundColor,
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
      bottomNavigationBar: BottomAppBar(
        color: bottomNavBarColor,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 60,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildAnimatedIcon(0, Icons.article, iconColor),
            _buildAnimatedIcon(1, Icons.manage_search_sharp, iconColor),
            const SizedBox(width: 48),
            _buildAnimatedIcon(2, Icons.work, iconColor),
            _buildAnimatedIcon(3, Icons.group, iconColor),
          ],
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

  Widget _buildAnimatedIcon(int index, IconData icon, Color iconColor) {
    bool isSelected = _selectedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: IconButton(
        icon: Icon(
          icon,
          color: isSelected ? Colors.orange : iconColor,
          size: isSelected ? 36 : 28,
        ),
        onPressed: () {
          _onItemTapped(index);
        },
      ),
    );
  }
}
