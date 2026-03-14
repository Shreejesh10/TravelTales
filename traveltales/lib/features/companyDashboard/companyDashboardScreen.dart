import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:traveltales/features/eventCreatingScreen/eventCreatingScreen.dart';
import 'package:traveltales/features/eventsScreen/eventsScreen.dart';
import 'package:traveltales/features/homeScreen/homeScreen.dart';
import 'package:traveltales/features/profile/profile.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    EventCreatingScreen(),
    EventsScreen(),
    ProfileScreen(),
  ];

  void _changeTab(int index) {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        color: Colors.transparent,
        animationDuration: const Duration(milliseconds: 300),
        height: 52,

        onTap: _changeTab,

        items: [
          Icon(
            Icons.home,
            color: _currentIndex == 0
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          Icon(
            Icons.event,
            color: _currentIndex == 1
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          Icon(
            Icons.list_alt,
            color: _currentIndex == 2
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          Icon(
            Icons.person_outline,
            color: _currentIndex == 3
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
        ],
      ),
    );
  }
}