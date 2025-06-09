import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nextvine/screens/camera_screen.dart';

class RecordingGuideScreen extends StatefulWidget {
  const RecordingGuideScreen({super.key});

  @override
  State<RecordingGuideScreen> createState() => _RecordingGuideScreenState();
}

class _RecordingGuideScreenState extends State<RecordingGuideScreen> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _guideSteps = [
    {
      'icon': Icons.camera_alt,
      'title': 'Position Your Camera',
      'description':
          'Place your phone on a stable surface, ensuring the camera is at chest level. The camera should be landscape and capture your entire back, from your neck to your lower back.',
    },
    {
      'icon': Icons.lightbulb,
      'title': 'Ensure Good Lighting',
      'description':
          'Record in a well-lit room. Avoid shadows and backlighting to ensure the video is clear and details are visible.',
    },
    {
      'icon': Icons.accessibility,
      'title': 'Maintain a Neutral Pose',
      'description':
          'Stand straight with your feet shoulder-width apart. Let your arms hang naturally at your sides. Do not wear loose clothing that may obscure your back.',
    },
    {
      'icon': Icons.check_circle,
      'title': 'Follow the Instructions',
      'description':
          'Once you start recording, you will be asked to bend forward slowly. Follow the on-screen prompts for the best results.',
    },
  ];

  void _nextStep() {
    if (_currentStep < _guideSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const CameraScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording Guide'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildProgressBar(),
            const SizedBox(height: 32),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _buildGuideStep(
                  key: ValueKey<int>(_currentStep),
                  icon: _guideSteps[_currentStep]['icon'],
                  title: _guideSteps[_currentStep]['title'],
                  description: _guideSteps[_currentStep]['description'],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nextStep,
        child: Icon(
          _currentStep == _guideSteps.length - 1
              ? Icons.check
              : Icons.arrow_forward,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_guideSteps.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 50,
          height: 8,
          decoration: BoxDecoration(
            color: _currentStep >= index ? Colors.teal : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildGuideStep(
      {required Key key,
      required IconData icon,
      required String title,
      required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: Colors.teal),
        const SizedBox(height: 24),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: GoogleFonts.poppins(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
