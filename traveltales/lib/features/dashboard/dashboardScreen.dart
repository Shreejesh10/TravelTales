import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:traveltales/features/eventsScreen/eventsScreen.dart';
import 'package:traveltales/features/homeScreen/homeScreen.dart';
import 'package:traveltales/features/profile/profile.dart';
import 'package:traveltales/features/settings/settingsScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    EventsScreen(),
    SettingsScreen(),
    ProfileScreen(),
  ];

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
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items:  [
          Icon(
              Icons.home,
              color: _currentIndex == 0
                ?Theme.of(context).primaryColor
                  :Colors.grey
          ),
          Icon(
              Icons.search,
              color: _currentIndex == 1
                  ?Theme.of(context).primaryColor
                  :Colors.grey
          ),
          Icon(
              Icons.event_sharp,
              color: _currentIndex == 2
                  ?Theme.of(context).primaryColor
                  :Colors.grey
          ),
          Icon(
              Icons.person_outline,
              color: _currentIndex == 3
                  ?Theme.of(context).primaryColor
                  :Colors.grey
          ),
        ],
      ),
    );
  }
}
