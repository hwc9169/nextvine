import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:nextvine/view_model/angle_view_model.dart';
import 'package:logger/logger.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No cameras found');
    }

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      throw Exception('No cameras permission');
    }

    final controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await controller.initialize();
    setState(() => _controller = controller);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
        body: Stack(children: [
      Positioned(
          top: 40,
          left: 20,
          child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ))),
      Positioned.fill(
        child: CameraPreview(_controller!),
      ),
      Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.black.withValues(alpha: 0.5),
              child: GestureDetector(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                onTap: () async {
                  final image = await _controller!.takePicture();
                  if (context.mounted) {
                    //Provider.of<AngleViewModel>(context, listen: false)
                    //    .fakePredictAngle(File(image.path));
                    Provider.of<AngleViewModel>(context, listen: false)
                        .predictAngleOnDevice(image.path);
                    Navigator.pop(context);
                  }
                },
              )))
    ]));
  }
}
