// lib/scoliometer/services/sensor_service.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import '../models/mount_mode.dart';

class SensorService {
  StreamSubscription<AccelerometerEvent>? _accSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  // Gravity LPF & normalization
  double _axLP = 0.0, _ayLP = 0.0, _azLP = 0.0;
  bool _lpfInit = false;

  // Median-3 & outlier
  final List<double> _accAngleBuf = <double>[];
  double _lastAcceptedAcc = 0.0;

  // Auto-invert detection
  bool _autoInvActive = false;
  double _autoInvEndS = 0.0;

  // Tuning
  static const double _gravAlpha = 0.84;
  static const double _accJumpMaxDeg = 20.0;

  // Callbacks
  Function(double)? onAngleUpdate;
  Function()? onSensorError;

  void startSensors() {
    _gyroSub = gyroscopeEventStream().listen((GyroscopeEvent g) {});

    _accSub = accelerometerEventStream().listen((a) {
      if (!_lpfInit) {
        _axLP = a.x;
        _ayLP = a.y;
        _azLP = a.z;
        _lpfInit = true;
      } else {
        _axLP = _gravAlpha * _axLP + (1 - _gravAlpha) * a.x;
        _ayLP = _gravAlpha * _ayLP + (1 - _gravAlpha) * a.y;
        _azLP = _gravAlpha * _azLP + (1 - _gravAlpha) * a.z;
      }

      _processFromGravity();
    }, onError: (_) {
      onSensorError?.call();
    });
  }

  void stopSensors() {
    _accSub?.cancel();
    _gyroSub?.cancel();
  }

  void _processFromGravity() {
    final norm = math.max(
        1e-6, math.sqrt(_axLP * _axLP + _ayLP * _ayLP + _azLP * _azLP));
    final nx = _axLP / norm, ny = _ayLP / norm;

    final raw =
        math.atan2(ny, nx) * 180.0 / math.pi; // Default to longEdge mount

    _maybeAutoInvert(raw);

    final med = _pushAndMedian(raw);
    if ((med - _lastAcceptedAcc).abs() > _accJumpMaxDeg) {
      _lastAcceptedAcc = med;
      return;
    }
    _lastAcceptedAcc = med;

    onAngleUpdate?.call(med);
  }

  void _maybeAutoInvert(double raw) {
    if (!_autoInvActive) return;

    final nowS = DateTime.now().microsecondsSinceEpoch / 1e6;

    if (nowS >= _autoInvEndS) {
      _autoInvActive = false;
    }
  }

  double _pushAndMedian(double v) {
    _accAngleBuf.add(v);
    if (_accAngleBuf.length > 3) _accAngleBuf.removeAt(0);
    final s = List<double>.from(_accAngleBuf)..sort();
    return s[s.length ~/ 2];
  }

  void dispose() {
    stopSensors();
  }
}
