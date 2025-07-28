import 'dart:js_interop';

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

    final aisAPI = AisAPI();
    aisAPI.testSeriousPython();
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
                  child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: _buildGridView(vm.angle)))),
        ],
      ),
    );
  }

  List<Widget> _buildGridView(Angle angle) {
    return [
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.show_chart, size: 32, color: Colors.blue),
              const SizedBox(height: 4),
              Text(
                "Proximal thoracic",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                angle.proximalThoracic.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.straighten, size: 32, color: Colors.orange),
              const SizedBox(height: 4),
              Text(
                "Main thoracic",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                angle.mainThoracic.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.balance, size: 32, color: Colors.green),
              const SizedBox(height: 4),
              Text(
                "Lumbar",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                angle.lumbar.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      )
    ];
  }
}
