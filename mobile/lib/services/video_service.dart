import 'dart:io';
import 'logger_service.dart';

/// Defines the result of a successful video upload.
class VideoUploadResult {
  final String videoId;
  final String uploadUrl;
  final DateTime uploadTime;
  final Map<String, dynamic> metadata;

  VideoUploadResult({
    required this.videoId,
    required this.uploadUrl,
    required this.uploadTime,
    this.metadata = const {},
  });
}

/// Abstract class defining the contract for video operations.
abstract class VideoService {
  Future<VideoUploadResult?> uploadVideo(File videoFile);
  Future<bool> deleteVideo(String videoId);
}

/// A mock implementation of [VideoService] for testing.
///
/// This class simulates the behavior of a real video service, including
/// upload delays, without making any network requests.
class MockVideoService implements VideoService {
  final _logger = LoggerService();
  final Map<String, String> _mockVideoUrls = {};

  @override
  Future<VideoUploadResult?> uploadVideo(File videoFile) async {
    try {
      final file = videoFile;
      _logger.debug('Mock: Simulating video upload.', {'path': file.path});

      await Future.delayed(const Duration(milliseconds: 500));

      final videoId = DateTime.now().millisecondsSinceEpoch.toString();
      _mockVideoUrls[videoId] = 'https://mock.storage.com/mock-bucket/$videoId';

      return VideoUploadResult(
        videoId: videoId,
        uploadUrl: _mockVideoUrls[videoId]!,
        uploadTime: DateTime.now(),
        metadata: {'isMock': true},
      );
    } catch (e, stackTrace) {
      _logger.error('Error handling recorded video in mock', e, stackTrace);
      return null;
    }
  }

  @override
  Future<bool> deleteVideo(String videoId) async {
    return _mockVideoUrls.remove(videoId) != null;
  }
}
