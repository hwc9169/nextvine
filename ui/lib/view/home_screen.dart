import 'package:flutter/material.dart';
import 'dashboard_view.dart';
import 'package:nextvine/view/camera_guide_screen.dart';

class Pair {
  final String title;
  final Widget widget;

  Pair(this.title, this.widget);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Pair> _pages = <Pair>[
    Pair('Dashboard', DashboardView()),
    //Pair('Setting', SettingsView()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((_pages[_selectedIndex]).title),
      ),
      body: _pages[_selectedIndex].widget,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home,
                  color: _selectedIndex == 0
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.settings,
                  color: _selectedIndex == 1
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex != 0
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.videocam, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CameraGuideScreen()),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
