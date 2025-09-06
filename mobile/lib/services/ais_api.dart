import 'dart:convert';
import 'package:http/http.dart' as http;

enum BackType {
  doubleThoracic,
  singleThoracic,
  doubleLumbar,
  singleLumbar,
}

extension BackTypeExtension on BackType {
  static BackType fromText(String backType) {
    switch (backType) {
      case 'double thoracic':
        return BackType.doubleThoracic;
      case 'single thoracic':
        return BackType.singleThoracic;
      case 'double lumbar':
        return BackType.doubleLumbar;
      case 'single lumbar':
        return BackType.singleLumbar;
      default:
        return BackType.doubleThoracic;
    }
  }

  static String toText(BackType backType) {
    switch (backType) {
      case BackType.doubleThoracic:
        return 'double thoracic';
      case BackType.singleThoracic:
        return 'single thoracic';
      case BackType.doubleLumbar:
        return 'double lumbar';
      case BackType.singleLumbar:
        return 'single lumbar';
    }
  }
}

class Angle {
  double proximalThoracic;
  double mainThoracic;
  double lumbar;
  BackType backType;

  Angle(this.proximalThoracic, this.mainThoracic, this.lumbar, this.backType);
}

class AisAPI {
  final http.Client _client;

  AisAPI({http.Client? client}) : _client = client ?? http.Client();

  Future<Angle> predictAngleByServer(String imagePath) async {
    //var url = Uri.http('10.0.2.2:8000', '/angle', {'image_path': imagePath});
    var url =
        Uri.http('192.168.0.37:8000', '/angle', {'image_path': imagePath});
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final backType =
          BackTypeExtension.fromText(data['back_type'] ?? 'double thoracic');
      return Angle(
        data['proximal_thoracic'] ?? 0.0,
        data['main_thoracic'] ?? 0.0,
        data['lumbar'] ?? 0.0,
        backType,
      );
    }
    throw Exception('Failed to fetch angle data');
  }

  Future<Angle> predictAngleOnDevice(String imagePath) async {
    // For demonstration, return a fixed angle
    await Future.delayed(const Duration(seconds: 3));
    return Angle(10.0, 13.0, 0, BackType.doubleThoracic);
  }
}
