import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/google_video_service.dart';
import '../services/logger_service.dart';
import '../services/video_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  final _logger = LoggerService();
  final VideoService _videoService = GoogleVideoService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _logger.error('No cameras found');
        return;
      }

      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _logger.error('Camera permission denied');
        return;
      }

      final controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: true,
      );

      await controller.initialize();
      if (mounted) {
        setState(() => _controller = controller);
      }
    } catch (e, stackTrace) {
      _logger.error('Error initializing camera', e, stackTrace);
    }
  }

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      _logger.error('Camera not initialized');
      return;
    }

    if (_isRecording) {
      try {
        final file = await _controller!.stopVideoRecording();
        setState(() => _isRecording = false);
        _logger.info('Recording stopped, file saved at ${file.path}');

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Uploading video for analysis...',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.orangeAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        final result = await _videoService.uploadVideo(File(file.path));
        if (result != null) {
          _logger.info('Video uploaded successfully', {
            'videoId': result.videoId,
            'url': result.uploadUrl,
          });
        }
      } catch (e, stackTrace) {
        _logger.error('Error stopping recording', e, stackTrace);
      }
    } else {
      try {
        await _controller!.startVideoRecording();
        setState(() => _isRecording = true);
        _logger.info('Recording started');
      } catch (e, stackTrace) {
        _logger.error('Error starting recording', e, stackTrace);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          // Top bar for back button
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          // Bottom bar for recording button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.white : Colors.red,
                      border: Border.all(
                        color: _isRecording ? Colors.red : Colors.white,
                        width: 4,
                      ),
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.videocam,
                      color: _isRecording ? Colors.red : Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
