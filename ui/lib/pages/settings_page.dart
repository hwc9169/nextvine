import 'package:flutter/material.dart';
import 'package:nextvine/pages/interface.dart';

class SettingsPage extends StatelessWidget implements PageInterface {
  const SettingsPage({super.key});

  @override
  String get title => 'Settings';

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile'),
          onTap: () {
            // Navigate to profile page
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          onTap: () {
            // Navigate to notifications settings
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Privacy'),
          onTap: () {
            // Navigate to privacy settings
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () {
            // Show about dialog
          },
        ),
      ],
    );
  }
}
