// lib/scoliometer/view_model/scoliometer_view_model.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/reading.dart';
import '../models/mount_mode.dart';
import '../services/sensor_service.dart';
import '../services/storage_service.dart';

class ScoliometerViewModel extends ChangeNotifier {
  final SensorService _sensorService = SensorService();
  final StorageService _storageService = StorageService();

  // Sessions
  int _sessionId = 1;
  bool _sessionDirty = false;
  int _selectedSessionForChart = 1;
  int _selectedSessionForHistory = 1;

  // Session names (persisted)
  final Map<int, String> _sessionNames = {};

  // Zero (per-mount), peak
  double _zeroOffset = 0.0;
  final Map<MountMode, double> _zeroByMount = {
    MountMode.flatBack: 0.0,
    MountMode.longEdge: 0.0,
    MountMode.shortEdge: 0.0,
  };
  double _peakAbs = 0.0;

  // Angles (deg)
  double _angleAccDeg = 0.0;
  double _displayDeg = 0.0;

  // Timing
  double _freezeUntilS = 0.0;

  // 60 FPS spring
  Timer? _frameTimer;
  double _targetDeg = 0.0;
  double _dispVel = 0.0;
  double _lastFrameS = 0.0;

  static const double _wn = 6.0;
  static const double _c = 2 * _wn;
  static const double _maxVelDegPerSec = 240.0;
  static const double _snapZero = 0.25;

  // UI
  final List<Reading> _log = [];
  double _desiredDeviceWidthCm = 18.0;
  double _uiScale = 1.0;
  MountMode _mount = MountMode.longEdge;

  bool _simMode = false;
  bool _sensorSeen = false;
  bool _showSimHint = false;
  double _simAngle = 0.0;

  // Getters
  int get sessionId => _sessionId;
  bool get sessionDirty => _sessionDirty;
  int get selectedSessionForChart => _selectedSessionForChart;
  int get selectedSessionForHistory => _selectedSessionForHistory;
  Map<int, String> get sessionNames => _sessionNames;
  double get zeroOffset => _zeroOffset;
  double get peakAbs => _peakAbs;
  double get angleAccDeg => _angleAccDeg;
  double get displayDeg => _displayDeg;
  List<Reading> get log => _log;
  double get desiredDeviceWidthCm => _desiredDeviceWidthCm;
  double get uiScale => _uiScale;
  MountMode get mount => _mount;
  bool get simMode => _simMode;
  bool get sensorSeen => _sensorSeen;
  bool get showSimHint => _showSimHint;
  double get simAngle => _simAngle;

  ScoliometerViewModel() {
    _setupSensorCallbacks();
    _initApp();
    _startFrameLoop();
  }

  void _setupSensorCallbacks() {
    _sensorService.onAngleUpdate = (angle) {
      _angleAccDeg = angle - _zeroOffset;
      _updateDisplay(_angleAccDeg);
    };
    _sensorService.onSensorError = () {
      _showSimHint = true;
      notifyListeners();
    };
  }

  Future<void> _initApp() async {
    await _loadPrefs();
    _startSensors();
  }

  Future<void> _loadPrefs() async {
    try {
      final prev = await _storageService.loadSessionCounter();
      _sessionId = prev + 1;
      await _storageService.saveSessionCounter(_sessionId);
      _selectedSessionForChart = _sessionId;
      _selectedSessionForHistory = _sessionId;

      _mount = await _storageService.loadMountMode();
      _desiredDeviceWidthCm = await _storageService.loadDeviceWidth();
      _zeroByMount.addAll(await _storageService.loadZeroOffsets());
      _zeroOffset = _zeroByMount[_mount] ?? 0.0;
      _setScaleForRuler(_desiredDeviceWidthCm);

      _log.clear();
      _log.addAll(await _storageService.loadHistory());

      _sessionNames.clear();
      _sessionNames.addAll(await _storageService.loadSessionNames());
    } catch (_) {}

    notifyListeners();
    if (kIsWeb) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!_sensorSeen) {
          _showSimHint = true;
          notifyListeners();
        }
      });
    }
  }

  void _startSensors() {
    _sensorService.startSensors();
  }

  void _startFrameLoop() {
    _lastFrameS = DateTime.now().microsecondsSinceEpoch / 1e6;
    _frameTimer?.cancel();
    _frameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final nowS = DateTime.now().microsecondsSinceEpoch / 1e6;
      var dt = nowS - _lastFrameS;
      _lastFrameS = nowS;

      if (dt <= 0 || dt > 0.1) dt = 0.016;

      if (nowS < _freezeUntilS) {
        _displayDeg = 0.0;
        _dispVel = 0.0;
        notifyListeners();
        return;
      }

      final snapTarget = (_targetDeg.abs() < _snapZero) ? 0.0 : _targetDeg;

      final err = snapTarget - _displayDeg;
      final a = (_wn * _wn) * err - _c * _dispVel;
      _dispVel += a * dt;

      if (_dispVel > _maxVelDegPerSec) _dispVel = _maxVelDegPerSec;
      if (_dispVel < -_maxVelDegPerSec) _dispVel = -_maxVelDegPerSec;

      // Integrate
      _displayDeg += _dispVel * dt;

      // Hard clamp the visual value
      if (_displayDeg > 30.0) _displayDeg = 30.0;
      if (_displayDeg < -30.0) _displayDeg = -30.0;

      // Peak uses clamped value
      final absVal = _displayDeg.abs();
      if (absVal > _peakAbs) _peakAbs = absVal;
      if (_peakAbs > 30.0) _peakAbs = 30.0;

      notifyListeners();
    });
  }

  void _updateDisplay(double targetDeg) {
    // Clamp anything fed into the UI to ±30°
    _targetDeg = targetDeg.clamp(-30.0, 30.0);
  }

  void _setScaleForRuler(double cm) {
    _uiScale = (cm / 18.0).clamp(0.85, 1.15);
  }

  // Actions
  Future<void> calibrateZero() async {
    HapticFeedback.mediumImpact();

    // This would need access to current sensor values
    // For now, just reset to 0
    _zeroOffset = 0.0;
    _zeroByMount[_mount] = _zeroOffset;
    await _storageService.saveZeroOffset(_mount, _zeroOffset);

    _angleAccDeg = 0.0;
    _displayDeg = 0.0;
    _dispVel = 0.0;
    _peakAbs = 0.0;

    final nowS = DateTime.now().microsecondsSinceEpoch / 1e6;
    _freezeUntilS = nowS + 0.10;

    notifyListeners();
  }

  void record() {
    HapticFeedback.lightImpact();

    // Always store a clamped reading
    final clamped = _displayDeg.clamp(-30.0, 30.0);
    final r = Reading(DateTime.now(), clamped.toDouble(), _sessionId);
    _log.insert(0, r);
    _sessionDirty = true;
    _storageService.saveHistory(_log);

    notifyListeners();
  }

  void setMountMode(MountMode mount) {
    _mount = mount;
    _zeroOffset = _zeroByMount[_mount] ?? 0.0;
    _storageService.saveMountMode(_mount);
    notifyListeners();
  }

  void setDeviceWidth(double width) {
    _desiredDeviceWidthCm = width;
    _setScaleForRuler(width);
    _storageService.saveDeviceWidth(width);
    notifyListeners();
  }

  void setSelectedSessionForChart(int session) {
    _selectedSessionForChart = session;
    notifyListeners();
  }

  void setSelectedSessionForHistory(int session) {
    _selectedSessionForHistory = session;
    notifyListeners();
  }

  void setSimMode(bool enabled) {
    _simMode = enabled;
    if (enabled) {
      _simAngle = 0.0;
    }
    notifyListeners();
  }

  void updateSimAngle(double angle) {
    _simAngle = angle;
    // Process simulation angle similar to real sensor
    _angleAccDeg = _simAngle - _zeroOffset;
    _updateDisplay(_angleAccDeg);
  }

  // Session helpers
  List<int> availableSessionsDesc() {
    final set = <int>{};
    for (final r in _log) set.add(r.session);
    if (set.isEmpty) set.add(_sessionId);
    final list = set.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  String sessionDisplay(int s) {
    final n = _sessionNames[s];
    return (n != null && n.trim().isNotEmpty) ? n.trim() : 'Session $s';
  }

  int sessionReadingCount(int s) {
    int c = 0;
    for (final r in _log) {
      if (r.session == s) c++;
    }
    return c;
  }

  // Stats computation
  Stats computeStats(List<Reading> rs) {
    if (rs.isEmpty) return const Stats();
    // Work on absolute values, and clamp into [0, 30]
    double minAbs = double.infinity, maxAbs = 0.0, sumAbs = 0.0;
    for (final r in rs) {
      final v = r.angleDeg.abs().clamp(0.0, 30.0);
      if (v < minAbs) minAbs = v;
      if (v > maxAbs) maxAbs = v;
      sumAbs += v;
    }
    final avgAbs = sumAbs / rs.length;
    return Stats(
      min: minAbs.isFinite ? minAbs : 0.0,
      max: maxAbs,
      avg: avgAbs,
    );
  }

  @override
  void dispose() {
    _sensorService.dispose();
    _frameTimer?.cancel();
    super.dispose();
  }
}
