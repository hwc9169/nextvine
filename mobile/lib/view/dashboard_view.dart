import 'package:flutter/material.dart';
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
                              value: vm.angle.proximalThoracic,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildCard(
                              icon: Icons.straighten,
                              color: Colors.orange,
                              title: "Main thoracic",
                              value: vm.angle.mainThoracic,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildCard(
                              icon: Icons.balance,
                              color: Colors.green,
                              title: "Lumbar",
                              value: vm.angle.lumbar,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Row 2: Back type spanning full width
                      _buildBackTypeCard(vm.angle),
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
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value.toStringAsFixed(1),
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

  Widget _buildBackTypeCard(Angle angle) {
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
                          "Back Type Analysis",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        Text(
                          angle.backType.toString(),
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
                    String assetName;
                    switch (angle.backType) {
                      case BackType.doubleThoracic:
                        assetName = 'assets/images/double_thoracic.png';
                        break;
                      case BackType.singleThoracic:
                        assetName = 'assets/images/single_thoracic.png';
                        break;
                      case BackType.doubleLumbar:
                        assetName = 'assets/images/double_lumbar.png';
                        break;
                      case BackType.singleLumbar:
                        assetName = 'assets/images/single_lumbar.png';
                        break;
                      default:
                        assetName = 'assets/images/double_thoracic.png';
                    }
                    return Image.asset(
                      assetName,
                      height: 120,
                      fit: BoxFit.contain,
                    );
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
