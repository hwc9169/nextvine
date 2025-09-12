import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';

class TFLiteService {
  static final TFLiteService _instance = TFLiteService._internal();
  factory TFLiteService() => _instance;
  TFLiteService._internal();

  Interpreter? _interpreter;
  final Logger _logger = Logger();

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      _logger.i('TensorFlow Lite model loaded successfully');
    } catch (e) {
      _logger.e('Error loading TensorFlow Lite model: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> predictFromFloatArray(List<List<List<List<double>>>> preprocessedData) async {
    if (_interpreter == null) {
      await loadModel();
    }

    try {
      // Convert List<double> to Float32List for TensorFlow Lite
      final inputData = preprocessedData;
      
      // Get input and output shapes
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      
      _logger.i('Input shape: $inputShape');
      _logger.i('Output shape: $outputShape');
      _logger.i('Input data: $inputData');
      _logger.i('Input data length: ${inputData.length}');

      // Prepare output tensor
      // List<List<double>> [1, 3]
      final output = [List.filled(outputShape.reduce((a, b) => a * b), 0.0).toList()];
      

      _logger.i('Output shape: $outputShape');
      _logger.i('Output: $output');

      // Run inference
      _interpreter!.run(inputData, output);

      _logger.i('Model output: $output');

      // Return predictions (assuming 3 outputs: proximal, main, lumbar)
      return {
        'proximal_thoracic': output[0][0].toDouble(),
        'main_thoracic': output[0][1].toDouble(),
        'lumbar': output[0][2].toDouble(),
      };
    } catch (e) {
      _logger.e('Error during inference: $e');
      rethrow;
    }

  }

  dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}


