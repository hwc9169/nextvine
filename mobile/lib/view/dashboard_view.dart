import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nextvine/view_model/angle_view_model.dart';
import 'package:nextvine/services/ais_api.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Set orientation to portrait up when dashboard view is active
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    // Restore original orientation when leaving dashboard view
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<AngleViewModel>(
              builder: (context, vm, child) => Skeletonizer(
                  enabled: vm.isLoading,
                  child: Column(
                    children: [
                      // Row 1: 3 items in a row
                      Row(
                        children: [
                          Expanded(
                            child: _buildCard(
                              icon: Icons.show_chart,
                              color: Colors.blue,
                              title: "Proximal thoracic",
                              value: vm.angle?.proximalThoracic ?? 0.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildCard(
                              icon: Icons.straighten,
                              color: Colors.orange,
                              title: "Main thoracic",
                              value: vm.angle?.mainThoracic ?? 0.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildCard(
                              icon: Icons.balance,
                              color: Colors.green,
                              title: "Lumbar",
                              value: vm.angle?.lumbar ?? 0.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Row 2: Back type spanning full width
                      if (vm.angle != null) _buildScoliosisTypeCard(vm.angle!),
                    ],
                  ))),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color color,
    required String title,
    required double value,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w200,
                ),
                overflow: TextOverflow.visible,
                maxLines: 1,
                textScaler: TextScaler.linear(1.0),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${value.toStringAsFixed(1)}°',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoliosisTypeCard(Angle angle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.analytics,
                        size: 28, color: Colors.purple.shade700),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Scoliosis Type",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        Text(
                          ScoliosisTypeExtension.toText(angle.scoliosisType),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Show an image for each back type
              Center(
                child: Builder(
                  builder: (context) {
                    switch (angle.scoliosisType) {
                      case ScoliosisType.doubleThoracic:
                        return Image(
                          image: AssetImage('assets/double_thoracic.png'),
                          height: 320,
                        );
                      case ScoliosisType.doubleMajor:
                        return Image(
                          image: AssetImage('assets/double_major.png'),
                          height: 320,
                        );
                      case ScoliosisType.thoracic:
                        return Image(
                          image: AssetImage('assets/thoracic.png'),
                          height: 320,
                        );
                      case ScoliosisType.lumber:
                        return Image(
                          image: AssetImage('assets/lumber.png'),
                          height: 320,
                        );
                      case ScoliosisType.normal:
                        return Image(
                          image: AssetImage('assets/normal.png'),
                          height: 320,
                        );
                      case ScoliosisType.triple:
                        return Image(
                          image: AssetImage('assets/triple.png'),
                          height: 320,
                        );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
