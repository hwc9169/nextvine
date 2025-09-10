import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:nextvine/services/ais_api.dart';
import 'package:nextvine/repository/firebase_storage_repository.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'dart:io';

class AngleViewModel extends ChangeNotifier {
  final aisAPI = AisAPI();
  final firebaseStorageRepository = FirebaseStorageRepository();

  Angle? _angle;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Angle? get angle => _angle;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fakePredictAngle(File file) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 3));
    _angle = Angle(10.0, 13.0, 0, ScoliosisType.doubleThoracic);
    _setLoading(false);
  }

  Future<void> uploadImageAndPredictAngle(File file) async {
    _setLoading(true);

    final interpreter = await Interpreter.fromAsset('assets/model.tflite');

    final input = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0];
    final output = interpreter.run(input);
    Logger().i('Output: $output');
    final res = await firebaseStorageRepository.uploadFile(file);
    _angle = await aisAPI.predictAngleByServer(res.downloadURL);
    final data = {
      'proximalThoracic': _angle?.proximalThoracic,
      'mainThoracic': _angle?.mainThoracic,
      'lumbar': _angle?.lumbar,
      'scoliosisType': _angle?.scoliosisType,
    };
    final downloadURL = res.downloadURL;
    Logger().i('Download URL: $downloadURL\n Angle predudction result: $data');
    _setLoading(false);
  }
}
