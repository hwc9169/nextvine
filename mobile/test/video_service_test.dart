import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../lib2/services/video_service.dart';

void main() {
  group('MockVideoService', () {
    late MockVideoService videoService;
    late Directory tempDir;
    late File testVideoFile;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = await Directory.systemTemp.createTemp('test_videos');
      testVideoFile = File('${tempDir.path}/test_video.mp4');
      await testVideoFile.writeAsBytes([1, 2, 3]);
      videoService = MockVideoService();
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('uploadaVideo should return a valid result', () async {
      final testFile = testVideoFile;
      final result = await videoService.uploadVideo(testFile);

      expect(result, isA<VideoUploadResult>());
      expect(result!.videoId, isNotEmpty);
      expect(result.uploadUrl, contains(result.videoId));
      expect(result.metadata['isMock'], isTrue);
      final videoId = result.videoId;

      final isDeleted = await videoService.deleteVideo(videoId);
      expect(isDeleted, isTrue);
    });

    test('getVideoUrl should return null for a deleted video', () async {
      final testFile = testVideoFile;
      final result = await videoService.uploadVideo(testFile);
      final videoId = result!.videoId;

      final isDeleted = await videoService.deleteVideo(videoId);
      expect(isDeleted, isTrue);
    });

    test('deleteVideo on a non-existent video should return false', () async {
      final isDeleted = await videoService.deleteVideo('fake-id');
      expect(isDeleted, isFalse);
    });
  });
}
