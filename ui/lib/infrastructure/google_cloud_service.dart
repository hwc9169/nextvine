import 'dart:io';
import 'package:googleapis/storage/v1.dart' as storage;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:path/path.dart' as p;

import 'package:nextvine/services/logger_service.dart';
import 'package:nextvine/services/video_service.dart';

class GoogleCloudService implements VideoService {
  final _logger = LoggerService();
  final String _bucketName;
  storage.StorageApi? _storageApi;

  GoogleCloudService(
      {String bucketName = const String.fromEnvironment('GCP_BUCKET_NAME')})
      : _bucketName = bucketName {
    _authenticate().catchError((error, stackTrace) {
      _logger.error('Failed to authenticate in constructor', error, stackTrace);
    });
  }

  Future<void> _authenticate() async {
    if (_storageApi != null) return;

    try {
      // TODO: Replace with your actual service account credentials management
      // This is a placeholder for loading credentials securely.
      // For production, use a secure method like environment variables
      // or a secret management service.
      const credentialsJson = String.fromEnvironment('GCP_CREDENTIALS_JSON');
      if (credentialsJson.isEmpty) {
        throw Exception(
            'GCP_CREDENTIALS_JSON environment variable is not set.');
      }

      final credentials =
          auth.ServiceAccountCredentials.fromJson(credentialsJson);
      final scopes = [storage.StorageApi.devstorageReadWriteScope];
      final client = await auth.clientViaServiceAccount(credentials, scopes);

      _storageApi = storage.StorageApi(client);
      _logger.info('Google Cloud Storage client authenticated successfully.');
    } catch (e, stackTrace) {
      _logger.error('Failed to authenticate with Google Cloud', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<VideoUploadResult?> uploadVideo(File videoFile) async {
    if (_storageApi == null) {
      throw Exception('Storage API not initialized.');
    }

    final videoId =
        '${DateTime.now().millisecondsSinceEpoch}-${p.basename(videoFile.path)}';
    final object = storage.Object(name: videoId);

    try {
      _logger
          .info('Starting upload to GCS bucket: $_bucketName', {'id': videoId});
      final media =
          storage.Media(videoFile.openRead(), await videoFile.length());
      final response = await _storageApi!.objects
          .insert(object, _bucketName, uploadMedia: media);

      final uploadTime = DateTime.now();
      final url = await getVideoUrl(response.name!);

      _logger.info('Successfully uploaded video to GCS.', {
        'videoId': response.name,
        'bucket': _bucketName,
        'url': url,
      });

      return VideoUploadResult(
        videoId: response.name!,
        uploadUrl: url,
        uploadTime: uploadTime,
        metadata: {
          'fileSize': await videoFile.length(),
          'fileName': p.basename(videoFile.path),
          'gcsBucket': _bucketName,
        },
      );
    } catch (e, stackTrace) {
      _logger.error('Failed to upload video to GCS', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<String> getVideoUrl(String videoId) async {
    // Standard URL format for GCS objects
    return 'https://storage.googleapis.com/$_bucketName/$videoId';
  }

  @override
  Future<bool> deleteVideo(String videoId) async {
    if (_storageApi == null) {
      throw Exception('Storage API not initialized.');
    }

    try {
      await _storageApi!.objects.delete(_bucketName, videoId);
      _logger.info('Successfully deleted video from GCS.', {
        'videoId': videoId,
        'bucket': _bucketName,
      });
      return true;
    } catch (e, stackTrace) {
      // Handle cases where the object might not exist (e.g., already deleted)
      if (e is storage.DetailedApiRequestError && e.status == 404) {
        _logger.warning(
            'Video not found in GCS for deletion (404).', {'videoId': videoId});
        return false;
      }
      _logger.error('Failed to delete video from GCS', e, stackTrace);
      rethrow;
    }
  }
}
