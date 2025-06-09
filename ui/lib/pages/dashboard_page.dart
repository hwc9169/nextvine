import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nextvine/pages/interface.dart';

class DashboardPage extends StatelessWidget implements PageInterface {
  const DashboardPage({super.key});

  @override
  String get title => 'Dashboard';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Status',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: const [
              StatusCard(
                icon: Icons.show_chart,
                title: 'Cobb Angle',
                value: '25°',
                color: Colors.orange,
              ),
              StatusCard(
                icon: Icons.straighten,
                title: 'Rotation',
                value: '8°',
                color: Colors.blue,
              ),
              StatusCard(
                icon: Icons.balance,
                title: 'Imbalance',
                value: '1.5 cm',
                color: Colors.green,
              ),
              StatusCard(
                icon: Icons.event,
                title: 'Last Check',
                value: '3m ago',
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const StatusCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
