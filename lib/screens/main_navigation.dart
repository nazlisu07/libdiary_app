import 'package:flutter/material.dart';
import '../services/theme_manager.dart'; // Tema motoru eklendi
import 'home_screen.dart';
import 'library_screen.dart';
import 'add_book_screen.dart';
import 'quotes_screen.dart';
import 'profile_screen.dart'; // Profil ekranı bağlanıyor

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const LibraryScreen(),
    const SizedBox(),
    const QuotesScreen(),
    const ProfileScreen(), // 4. İndex: Yenilenen Profil Sayfası
  ];

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder sayesinde şalter değiştikçe tüm navigasyon baştan aşağı renk değiştirir
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeManager.isDarkMode,
      builder: (context, isDark, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: AnimatedContainer(
            duration: const Duration(
              milliseconds: 400,
            ), // Renk geçişi yumuşak olsun diye
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: ThemeManager.bgGradient,
              ),
            ),
            child: SafeArea(bottom: false, child: _pages[_selectedIndex]),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddBookScreen(),
                    ),
                  ).then((_) => setState(() {}));
                } else {
                  setState(() => _selectedIndex = index);
                }
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF6750A4),
              unselectedItemColor: isDark
                  ? Colors.white30
                  : Colors.grey.withOpacity(0.6),
              showSelectedLabels: false,
              showUnselectedLabels: false,
              backgroundColor: isDark ? const Color(0xFF1D1B20) : Colors.white,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book_outlined),
                  activeIcon: Icon(Icons.book_rounded),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF6750A4),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_border_rounded),
                  activeIcon: Icon(Icons.bookmark_rounded),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: '',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
