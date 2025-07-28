import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serious_python/serious_python.dart';

class Angle {
  double proximalThoracic;
  double mainThoracic;
  double lumbar;

  Angle(this.proximalThoracic, this.mainThoracic, this.lumbar);
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
      return Angle(
        data['proximal_thoracic'] ?? 0.0,
        data['main_thoracic'] ?? 0.0,
        data['lumbar'] ?? 0.0,
      );
    }
    throw Exception('Failed to fetch angle data');
  }

  Future<Angle> predictAngleOnDevice(String imagePath) async {
    SeriousPython.run('app/app.zip');

    // For demonstration, return a fixed angle
    return Angle(10.0, 20.0, 30.0);
  }

  Future<void> testSeriousPython() async {
    final result =
        await SeriousPython.run('app/app.zip', appFileName: 'main.py');
  }
}
