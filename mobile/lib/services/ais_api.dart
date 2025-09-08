import 'dart:convert';
import 'package:http/http.dart' as http;

enum ScoliosisType {
  doubleThoracic,
  doubleMajor,
  thoracic,
  lumber,
  normal,
  triple,
}

extension ScoliosisTypeExtension on ScoliosisType {
  static ScoliosisType fromText(String scoliosisType) {
    switch (scoliosisType) {
      case 'double thoracic':
        return ScoliosisType.doubleThoracic;
      case 'double major':
        return ScoliosisType.doubleMajor;
      case 'thoracic':
        return ScoliosisType.thoracic;
      case 'lumber':
        return ScoliosisType.lumber;
      case 'normal':
        return ScoliosisType.normal;
      case 'triple':
        return ScoliosisType.triple;
      default:
        return ScoliosisType.doubleThoracic;
    }
  }

  static String toText(ScoliosisType scoliosisType) {
    switch (scoliosisType) {
      case ScoliosisType.doubleThoracic:
        return 'double thoracic';
      case ScoliosisType.doubleMajor:
        return 'double major';
      case ScoliosisType.thoracic:
        return 'thoracic';
      case ScoliosisType.lumber:
        return 'lumber';
      case ScoliosisType.normal:
        return 'normal';
      case ScoliosisType.triple:
        return 'triple';
      default:
        return 'double thoracic';
    }
  }
}

class Angle {
  double proximalThoracic;
  double mainThoracic;
  double lumbar;
  ScoliosisType scoliosisType;

  Angle(this.proximalThoracic, this.mainThoracic, this.lumbar,
      this.scoliosisType);
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
      final scoliosisType = ScoliosisTypeExtension.fromText(
          data['scoliosis_type'] ?? 'double thoracic');
      return Angle(
        data['proximal_thoracic'] ?? 0.0,
        data['main_thoracic'] ?? 0.0,
        data['lumbar'] ?? 0.0,
        scoliosisType,
      );
    }
    throw Exception('Failed to fetch angle data');
  }

  Future<Angle> predictAngleOnDevice(String imagePath) async {
    // For demonstration, return a fixed angle
    await Future.delayed(const Duration(seconds: 3));
    return Angle(10.0, 13.0, 0, ScoliosisType.doubleThoracic);
  }
}
