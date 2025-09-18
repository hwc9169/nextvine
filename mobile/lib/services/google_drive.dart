import 'package:googleapis/drive/v3.dart' as drive;
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

Future<drive.DriveApi> getGoogleDriveApi(String accessToken) async {
  final client = GoogleAuthClient({'Authorization': 'Bearer $accessToken'});
  return drive.DriveApi(client);
}

Future<void> uploadFileToGoogleDrive(
    drive.DriveApi driveApi, String content) async {
  final fileName = '${DateTime.now().toIso8601String()}.json';
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$fileName')..writeAsStringSync(content);

  final folderName = "scolioscan";
  final folderList = await driveApi.files.list(
    q: "mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false",
    $fields: "files(id, name)",
  );

  String folderId = "";
  if (folderList.files?.isNotEmpty ?? false) {
    folderId = folderList.files!.first.id!;
  } else {
    final folder = drive.File()
      ..name = folderName
      ..mimeType = "application/vnd.google-apps.folder";

    final created = await driveApi.files.create(folder);
    folderId = created.id!;
  }

  final meta = drive.File()
    ..name = fileName
    ..mimeType = 'application/json; charset=utf-8'
    ..parents = [folderId];

  driveApi.files.create(
    meta,
    uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
  );
}

Future<String?> downloadLatestFileFromGoogleDrive(
    drive.DriveApi driveApi) async {
  //driver files from scolioscan folder
  final folderName = "scolioscan";
  final folderList = await driveApi.files.list(
    q: "mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false",
    $fields: "files(id, name)",
  );
  String folderId = "";
  if (folderList.files?.isEmpty ?? true) {
    return null;
  }

  folderId = folderList.files!.first.id!;
  final fileList = await driveApi.files.list(
    q: "mimeType='application/json' and trashed=false and parents='$folderId'",
    $fields: "files(id, name)",
  );
  final latestFile = fileList.files!.first;

  final response = await driveApi.files.get(
    latestFile.id!,
    downloadOptions: drive.DownloadOptions.fullMedia,
  );

  if (response is drive.Media) {
    final jsonString = await utf8.decodeStream(response.stream);
    return jsonString;
  }
  return null;
}
