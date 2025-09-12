import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:nextvine/services/ais_api.dart';
import 'package:nextvine/repository/firebase_storage_repository.dart';
import 'package:nextvine/services/tflite_service.dart';
import 'package:flutter/services.dart';

import 'dart:io';

class AngleViewModel extends ChangeNotifier {
  final aisAPI = AisAPI();
  final firebaseStorageRepository = FirebaseStorageRepository();
  final tfliteService = TFLiteService();

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
  Future<void> predictAngleOnDevice(String imagePath) async {
    _setLoading(true);
    const platform = MethodChannel('ai.nextvine.scoliosis/angle');
    
    try {
      // Step 1: Preprocess image using Android native preprocessing
      Logger().i('Preprocessing image: $imagePath');
      final preprocessedData = await platform.invokeMethod('preprocess', {'imagePath': imagePath});
      Logger().i('Preprocessed data received, length: ${preprocessedData.length}');

      // Step 2: Convert preprocessed data to the format expected by TensorFlow Lite
      final List<List<List<List<double>>>> imageData = convertTo4D(preprocessedData);
      Logger().i('Preprocessed data received, length: ${imageData.length}');
      
      // Step 3: Run inference using TensorFlow Lite
      Logger().i('Running TensorFlow Lite inference');
      final predictions = await tfliteService.predictFromFloatArray(imageData);
      Logger().i('Predictions: $predictions');

      // Step 4: Extract the angle predictions
      final proximalThoracic = predictions['proximal_thoracic'] ?? 0.0;
      final mainThoracic = predictions['main_thoracic'] ?? 0.0;
      final lumbar = predictions['lumbar'] ?? 0.0;

      // Step 5: Determine scoliosis type based on the angles
      final scoliosisType = _determineScoliosisType(proximalThoracic, mainThoracic, lumbar);

      _angle = Angle(
        proximalThoracic,
        mainThoracic,
        lumbar,
        scoliosisType,
      );
    } catch (e) {
      Logger().e('Error predicting angle: $e');
      // Handle error - you might want to show an error message to the user
    }

    _setLoading(false);
  }

  List<List<List<List<double>>>> convertTo4D(List<Object?> preprocessedData) {
      // Convert the Android FloatArray data to List<double> for TensorFlow Lite
    Logger().i('Preprocessed data: $preprocessedData');
    try {
      final out = _to4D(preprocessedData);
      // Optional: log shape
      final b = out.length;
      final h = b > 0 ? out[0].length : 0;
      final w = h > 0 ? out[0][0].length : 0;
      final c = w > 0 ? out[0][0][0].length : 0;
      return out;
    } catch (e) {
      rethrow;
    }
  }

  List<List<List<List<double>>>> _to4D(Object? data) {
    final l0 = _asList(data);
    return List<List<List<List<double>>>>.unmodifiable(
      l0.map((l1) {
        final l1c = _asList(l1);
        return List<List<List<double>>>.unmodifiable(
          l1c.map((l2) {
            final l2c = _asList(l2);
            return List<List<double>>.unmodifiable(
              l2c.map((l3) {
                final l3c = _asList(l3);
                if (l3c.length != 3) {
                  throw FormatException('Innermost list must have length 3 (RGB), got ${l3c.length}.');
                }
                return List<double>.unmodifiable(l3c.map(_asDouble));
              }),
            );
          }),
        );
      }),
    );
  }

  List _asList(Object? v) {
    if (v is List) return v;
    throw FormatException('Expected List, got ${v.runtimeType}');
  }

  double _asDouble(Object? v) {
    if (v is num) return v.toDouble();
    throw FormatException('Expected num at innermost level, got ${v.runtimeType}');
  }


  ScoliosisType _determineScoliosisType(double proximal, double main, double lumbar) {
    const threshold = 8.0;
    
    // Convert angles to straight/bent pattern
    final proximalType = proximal <= threshold ? 'Straight' : 'Bent';
    final mainType = main <= threshold ? 'Straight' : 'Bent';
    final lumbarType = lumbar <= threshold ? 'Straight' : 'Bent';
    
    final pattern = '$proximalType-$mainType-$lumbarType';
    
    switch (pattern) {
      case 'Straight-Straight-Straight':
        return ScoliosisType.normal;
      case 'Straight-Bent-Straight':
        return ScoliosisType.thoracic;
      case 'Bent-Bent-Straight':
        return ScoliosisType.doubleThoracic;
      case 'Straight-Bent-Bent':
        return ScoliosisType.doubleMajor;
      case 'Bent-Bent-Bent':
        return ScoliosisType.triple;
      case 'Straight-Straight-Bent':
        return ScoliosisType.lumbar;
      default:
        return ScoliosisType.normal; // Default fallback
    }
  }

  @override
  void dispose() {
    tfliteService.dispose();
    super.dispose();
  }
}
