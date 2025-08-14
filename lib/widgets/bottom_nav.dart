import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:thoughtbox/view/convert/convert_page.dart';
import 'package:thoughtbox/view/profile/profile.dart';

const primaryColor = Color(0xFFD81B60);
const darkBackground = Color(0xFF20232B);

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  // List of pages for each tab
  final List<Widget> _pages = [
    CurrencyConverterPage(),
    CurrencyConverterPage(),
    CurrencyConverterPage(),
    Profile(),
    // HomePage(),
    // LikesPage(),
    // SearchPage(),
    // ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: darkBackground,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: GNav(
          rippleColor: primaryColor.withOpacity(0.2),
          hoverColor: primaryColor.withOpacity(0.1),
          haptic: true,
          tabBorderRadius: 15,
          curve: Curves.easeOutExpo,
          duration: const Duration(milliseconds: 300),
          gap: 8,
          color: Colors.white70,
          activeColor: primaryColor,
          iconSize: 24,
          tabBackgroundColor: primaryColor.withOpacity(0.15),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundColor: darkBackground,
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(
              icon: LineIcons.home,
              text: 'Home',
            ),
            GButton(
              icon: LineIcons.heart,
              text: 'Likes',
            ),
            GButton(
              icon: LineIcons.search,
              text: 'Search',
            ),
            GButton(
              icon: LineIcons.user,
              text: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
