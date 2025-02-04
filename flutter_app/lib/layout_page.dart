import 'package:flutter/material.dart';
import 'home_page.dart';
import 'alarms_page.dart';
import 'tasks_page.dart';
import 'calendar_page.dart';

class LayoutPage extends StatefulWidget {
  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [ HomePage(),
    AlarmsPage(),
    TasksPage(),
    CalendarPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.lightBlue[50],
          selectedItemColor: Colors.black,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.alarm),
              label: 'Alarms',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: ' Google\nCalendar',
            ),
          ],
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
      ),
    );
  }
}