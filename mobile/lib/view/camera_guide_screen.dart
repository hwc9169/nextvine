import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'camera_screen.dart';

class CameraGuideScreen extends StatefulWidget {
  const CameraGuideScreen({super.key});

  @override
  State<CameraGuideScreen> createState() => _CameraGuideScreenState();
}

class GuideStep {
  final Image image;
  final String title;
  final String description;

  GuideStep(this.image, this.title, this.description);
}

class _CameraGuideScreenState extends State<CameraGuideScreen> {
  int _currentStep = 0;

  final List<GuideStep> _guideSteps = [
    GuideStep(
      Image(image: AssetImage('assets/body.png'), width: 360, height: 360),
      'Align your shoulder with the horizontal line',
      'Ensuring the camera is at chest level.',
    )
  ];

  void _nextStep() {
    if (_currentStep < _guideSteps.length - 1) {
      setState(() => _currentStep++);
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CameraScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording Guide'),
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
                  guide: _guideSteps[_currentStep],
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
          color: Colors.white,
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

  Widget _buildGuideStep({
    required Key key,
    required GuideStep guide,
  }) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          guide.image,
          const SizedBox(height: 24),
          Text(
            guide.title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            guide.description,
            style: GoogleFonts.poppins(fontSize: 12),
            textAlign: TextAlign.center,
          )
        ]);
  }
}
