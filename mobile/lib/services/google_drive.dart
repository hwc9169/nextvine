import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

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
