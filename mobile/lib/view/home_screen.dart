import 'package:flutter/material.dart';
import 'package:nextvine/scoliometer/views/scoliometer_view_old.dart';
import 'dashboard_view.dart';
import 'package:nextvine/view/camera_guide_screen.dart';
import 'package:nextvine/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';

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
    Pair('Dashboard', const DashboardView()),
    Pair('Scoliometer', const ScoliometerHome()),
    //Pair('Setting', SettingsView()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      body: _pages[_selectedIndex].widget,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.home,
                color: _selectedIndex == 0
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey,
                size: 20,
              ),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(
                Icons.straighten,
                color: _selectedIndex == 1
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey,
                size: 20,
              ),
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
                  MaterialPageRoute(
                    builder: (context) => const CameraGuideScreen(),
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
