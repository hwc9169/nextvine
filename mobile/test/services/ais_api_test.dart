import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:nextvine/services/ais_api.dart';
import 'package:logger/logger.dart';

void main() {
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  group('AisAPI', () {
    test('predictAngleFromJPG success', () async {
      final api = AisAPI();

      final response = await api.predictAngleFromJPG();
      logger.i('Response: $response');
      expect(response, isA<Angle>());
    });
  });
}
