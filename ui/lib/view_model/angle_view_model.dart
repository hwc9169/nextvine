import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:nextvine/services/ais_api.dart';
import 'package:nextvine/repository/firebase_storage_repository.dart';

import 'dart:io';

class AngleViewModel extends ChangeNotifier {
  final aisAPI = AisAPI();
  final firebaseStorageRepository = FirebaseStorageRepository();

  Angle _angle = Angle(0.0, 0.0, 0.0);
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Angle get angle => _angle;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> uploadImageAndPredictAngle(File file) async {
    _setLoading(true);

    final res = await firebaseStorageRepository.uploadFile(file);
    _angle = await aisAPI.predictAngleByServer(res.downloadURL);
    final data = {
      'proximalThoracic': _angle.proximalThoracic,
      'mainThoracic': _angle.mainThoracic,
      'lumbar': _angle.lumbar,
    };
    final downloadURL = res.downloadURL;

    Logger().i('Download URL: $downloadURL\n Angle predudction result: $data');
    _setLoading(false);
  }
}
