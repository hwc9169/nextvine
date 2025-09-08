// lib/main.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Saving to phone gallery
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

enum MountMode { flatBack, longEdge, shortEdge }

const Color kBrand = Color(0xFF359296);
Color _lighten(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  final l = (hsl.lightness + amount).clamp(0.0, 1.0);
  return hsl.withLightness(l).toColor();
}

Color _darken(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  final l = (hsl.lightness - amount).clamp(0.0, 1.0);
  return hsl.withLightness(l).toColor();
}

double _logicalPixelsPerCm(BuildContext context) {
  final dpr = MediaQuery.of(context).devicePixelRatio;
  final dpi = 160.0 * dpr;
  return dpi / 2.54;
}

class ScoliometerHome extends StatefulWidget {
  const ScoliometerHome({super.key});
  @override
  State<ScoliometerHome> createState() => _ScoliometerHomeState();
}

class _ScoliometerHomeState extends State<ScoliometerHome> {
  // ----- Streams -----
  StreamSubscription<AccelerometerEvent>? _accSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

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
  double _lastUpdateS = 0.0;

  // Gravity LPF & normalization
  double _axLP = 0.0, _ayLP = 0.0, _azLP = 0.0;
  bool _lpfInit = false;

  // Median-3 & outlier
  final List<double> _accAngleBuf = <double>[];
  double _lastAcceptedAcc = 0.0;

  // Timing
  double _freezeUntilS = 0.0;

  // Auto-invert detection
  bool _autoInvActive = false;
  double _autoInvEndS = 0.0;
  double _corrSum = 0.0;
  double _lastRawForCorr = 0.0;
  double _lastRawTimeS = 0.0;
  double _lastGyroAxis = 0.0;

  // Tuning
  static const double _gravAlpha = 0.84;
  static const double _accJumpMaxDeg = 20.0;
  static const double _snapZero = 0.25;

  // 60 FPS spring
  Timer? _frameTimer;
  double _targetDeg = 0.0;
  double _dispVel = 0.0;
  double _lastFrameS = 0.0;

  static const double _wn = 6.0;
  static const double _c = 2 * _wn;
  static const double _maxVelDegPerSec = 240.0;

  // UI
  int _tab = 0; // 0=Measure,1=History,2=Chart
  final FocusNode _focusNode = FocusNode();
  final List<_Reading> _log = [];
  double _desiredDeviceWidthCm = 18.0;
  double _uiScale = 1.0;

  final ScrollController _historyHCtrl = ScrollController();

  MountMode _mount = MountMode.longEdge;

  bool _simMode = false;
  bool _sensorSeen = false;
  bool _showSimHint = false;
  double _simAngle = 0.0;

  final GlobalKey _chartRepaintKey = GlobalKey();

  int? _chipDeleteForSession;
  Timer? _chipDeleteHideTimer;

  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    _initApp();
    _startFrameLoop();
  }

  Future<void> _initApp() async {
    await _loadPrefs();
    _startSensors();
  }

  Future<void> _loadPrefs() async {
    try {
      final p = await SharedPreferences.getInstance();

      final prev = p.getInt('pref_session_counter') ?? 0;
      _sessionId = prev + 1;
      await p.setInt('pref_session_counter', _sessionId);
      _selectedSessionForChart = _sessionId;
      _selectedSessionForHistory = _sessionId;

      final mountIndex = p.getInt('pref_mount');
      if (mountIndex != null &&
          mountIndex >= 0 &&
          mountIndex < MountMode.values.length) {
        _mount = MountMode.values[mountIndex];
      } else {
        _mount = MountMode.longEdge;
      }
      _desiredDeviceWidthCm = p.getDouble('pref_width_cm') ?? 18.0;
      _zeroByMount[MountMode.flatBack] =
          p.getDouble('pref_zero_flatBack') ?? 0.0;
      _zeroByMount[MountMode.longEdge] =
          p.getDouble('pref_zero_longEdge') ?? 0.0;
      _zeroByMount[MountMode.shortEdge] =
          p.getDouble('pref_zero_shortEdge') ?? 0.0;
      _zeroOffset = _zeroByMount[_mount] ?? 0.0;
      _setScaleForRuler(_desiredDeviceWidthCm);

      // Set initial orientation based on loaded mount mode
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      final raw = p.getString('pref_history_v1');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _log
          ..clear()
          ..addAll(decoded.map((e) => _Reading.fromJson(e)));
      }

      // Load session names
      final namesRaw = p.getString('pref_session_names_v1');
      if (namesRaw != null && namesRaw.isNotEmpty) {
        try {
          final Map<String, dynamic> m =
              jsonDecode(namesRaw) as Map<String, dynamic>;
          _sessionNames.clear();
          for (final e in m.entries) {
            _sessionNames[int.parse(e.key)] = (e.value as String);
          }
        } catch (_) {}
      }
    } catch (_) {}

    if (mounted) setState(() {});
    if (kIsWeb) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_sensorSeen) setState(() => _showSimHint = true);
      });
    }
  }

  Future<void> _saveMount() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('pref_mount', _mount.index);
  }

  Future<void> _saveWidth() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('pref_width_cm', _desiredDeviceWidthCm);
  }

  Future<void> _saveZeroForMount(MountMode m, double v) async {
    final p = await SharedPreferences.getInstance();
    final key = switch (m) {
      MountMode.flatBack => 'pref_zero_flatBack',
      MountMode.longEdge => 'pref_zero_longEdge',
      MountMode.shortEdge => 'pref_zero_shortEdge',
    };
    await p.setDouble(key, v);
  }

  Future<void> _persistHistory() async {
    final p = await SharedPreferences.getInstance();
    final list = _log.length > 2000 ? _log.sublist(_log.length - 2000) : _log;
    final raw = jsonEncode(list.map((e) => e.toJson()).toList());
    await p.setString('pref_history_v1', raw);
  }

  Future<void> _persistSessionNames() async {
    final p = await SharedPreferences.getInstance();
    final m = <String, String>{
      for (final e in _sessionNames.entries) e.key.toString(): e.value
    };
    await p.setString('pref_session_names_v1', jsonEncode(m));
  }

  Future<void> _bumpSessionCounter() async {
    final p = await SharedPreferences.getInstance();
    _sessionId += 1;
    await p.setInt('pref_session_counter', _sessionId);
  }

  Future<void> _resetSessionCounterTo1() async {
    final p = await SharedPreferences.getInstance();
    _sessionId = 1;
    await p.setInt('pref_session_counter', 1);
  }

  void _startSensors() {
    _gyroSub = gyroscopeEventStream().listen((g) {
      _sensorSeen = true;
      if (_simMode) return;
      _lastGyroAxis = _pickGyroAxis(g, _mount);
    });

    _accSub = accelerometerEventStream().listen((a) {
      _sensorSeen = true;
      if (_simMode) return;

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
      if (mounted) setState(() => _showSimHint = true);
    });
  }

  @override
  void dispose() {
    _accSub?.cancel();
    _gyroSub?.cancel();
    _frameTimer?.cancel();
    _chipDeleteHideTimer?.cancel();
    _focusNode.dispose();
    _historyHCtrl.dispose();
    super.dispose();
  }

  // ---------- Core math ----------
  void _processFromGravity() {
    final norm = math.max(
        1e-6, math.sqrt(_axLP * _axLP + _ayLP * _ayLP + _azLP * _azLP));
    final nx = _axLP / norm, ny = _ayLP / norm, nz = _azLP / norm;

    final raw = switch (_mount) {
      MountMode.flatBack => math.atan2(ny, nz) * 180.0 / math.pi,
      MountMode.longEdge => math.atan2(ny, nx) * 180.0 / math.pi,
      MountMode.shortEdge => math.atan2(nx, ny) * 180.0 / math.pi,
    };

    _maybeAutoInvert(raw);

    final med = _pushAndMedian(raw);
    if ((med - _lastAcceptedAcc).abs() > _accJumpMaxDeg) {
      _lastAcceptedAcc = med;
      return;
    }
    _lastAcceptedAcc = med;

    _angleAccDeg = med - _zeroOffset;
    _updateDisplay(_angleAccDeg);
  }

  void _maybeAutoInvert(double raw) {
    if (!_autoInvActive) return;

    final nowS = DateTime.now().microsecondsSinceEpoch / 1e6;
    if (_lastRawTimeS != 0.0) {
      final dt = (nowS - _lastRawTimeS);
      if (dt > 0) {
        final dRawRate = (raw - _lastRawForCorr) / dt;
        _corrSum += dRawRate * _lastGyroAxis;
      }
    }
    _lastRawForCorr = raw;
    _lastRawTimeS = nowS;

    if (nowS >= _autoInvEndS) {
      if (_corrSum < 0) {
        _zeroOffset = -_zeroOffset;
        _zeroByMount[_mount] = _zeroOffset;
        unawaited(_saveZeroForMount(_mount, _zeroOffset));
      }
      _autoInvActive = false;
      _corrSum = 0.0;
    }
  }

  double _pickGyroAxis(GyroscopeEvent g, MountMode m) {
    switch (m) {
      case MountMode.flatBack:
        return g.x;
      case MountMode.longEdge:
        return g.z;
      case MountMode.shortEdge:
        return g.z;
    }
  }

  double _pushAndMedian(double v) {
    _accAngleBuf.add(v);
    if (_accAngleBuf.length > 3) _accAngleBuf.removeAt(0);
    final s = List<double>.from(_accAngleBuf)..sort();
    return s[s.length ~/ 2];
  }

  // ---------- 60 FPS spring loop ----------
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
        if (mounted) setState(() {});
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

      if (mounted) setState(() {});
    });
  }

  void _updateDisplay(double targetDeg) {
    // Clamp anything fed into the UI to ±30°
    _targetDeg = targetDeg.clamp(-30.0, 30.0);
  }

  // ---------- Actions ----------
  void _calibrateZero() async {
    unawaited(HapticFeedback.mediumImpact());

    final norm = math.max(
        1e-6, math.sqrt(_axLP * _axLP + _ayLP * _ayLP + _azLP * _azLP));
    final nx = _axLP / norm, ny = _ayLP / norm, nz = _azLP / norm;
    final raw = switch (_mount) {
      MountMode.flatBack => math.atan2(ny, nz) * 180.0 / math.pi,
      MountMode.longEdge => math.atan2(ny, nx) * 180.0 / math.pi,
      MountMode.shortEdge => math.atan2(nx, ny) * 180.0 / math.pi,
    };

    _zeroOffset = raw;
    _zeroByMount[_mount] = _zeroOffset;
    unawaited(_saveZeroForMount(_mount, _zeroOffset));

    _angleAccDeg = 0.0;
    _displayDeg = 0.0;
    _dispVel = 0.0;
    _peakAbs = 0.0;
    _accAngleBuf
      ..clear()
      ..addAll([raw, raw, raw]);

    final nowS = DateTime.now().microsecondsSinceEpoch / 1e6;
    _lastUpdateS = nowS;
    _freezeUntilS = nowS + 0.10;

    _autoInvActive = true;
    _autoInvEndS = nowS + 0.8;
    _corrSum = 0.0;
    _lastRawForCorr = raw;
    _lastRawTimeS = nowS;

    _toast('0° set — hold steady for a moment');
  }

  void _record() {
    unawaited(HapticFeedback.lightImpact());

    // Always store a clamped reading
    final clamped = _displayDeg.clamp(-30.0, 30.0);
    final r = _Reading(DateTime.now(), clamped.toDouble(), _sessionId);
    _log.insert(0, r);
    _sessionDirty = true;
    unawaited(_persistHistory());

    setState(() {});
  }

  void _exportCsvSession(int sessionId) {
    final sessionData = _log.where((r) => r.session == sessionId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (sessionData.isEmpty) {
      _toast('No readings in ${_sessionDisplay(sessionId)}');
      return;
    }

    final sb = StringBuffer('timestamp,atr_deg,session\n');
    for (final r in sessionData) {
      sb.writeln('${r.timestamp.toIso8601String()},'
          '${r.angleDeg.toStringAsFixed(2)},${r.session}');
    }
    Clipboard.setData(ClipboardData(text: sb.toString()));
    _toast('${_sessionDisplay(sessionId)} CSV copied');
  }

  Future<void> _confirmClearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Clear all history?'),
          ],
        ),
        content: const Text(
          'This will delete ALL sessions and readings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear history'),
          ),
        ],
      ),
    );
    if (ok == true) {
      unawaited(HapticFeedback.heavyImpact());
      _clearAll();
      _toast('All history cleared');
    }
  }

  void _clearAll() async {
    _log.clear();
    _sessionDirty = false;
    await _persistHistory();
    await _resetSessionCounterTo1();
    _selectedSessionForChart = 1;
    _selectedSessionForHistory = 1;
    _sessionNames.clear();
    await _persistSessionNames();

    _resetReadings(); // keep UI clean after clearing

    if (mounted) setState(() {});
  }

  Future<void> _confirmDeleteSession(int sessionId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete this session?'),
          ],
        ),
        content: Text(
            'This will remove all readings in ${_sessionDisplay(sessionId)}.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete session'),
          ),
        ],
      ),
    );

    if (ok == true) {
      unawaited(HapticFeedback.heavyImpact());
      _deleteSession(sessionId);
    }
  }

  Future<void> _deleteSession(int sessionId) async {
    _log.removeWhere((r) => r.session == sessionId);
    await _persistHistory();

    _sessionNames.remove(sessionId);
    await _persistSessionNames();

    final sessions = _availableSessionsDesc();
    if (sessions.isNotEmpty) {
      _selectedSessionForChart = sessions.first;
      _selectedSessionForHistory = sessions.first;
    } else {
      await _resetSessionCounterTo1();
      _selectedSessionForChart = 1;
      _selectedSessionForHistory = 1;
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveCurrentChartPng() async {
    final ctx = _chartRepaintKey.currentContext;
    if (ctx == null) {
      _toast('Chart not ready yet');
      return;
    }
    try {
      final boundary = ctx.findRenderObject() as RenderRepaintBoundary;
      final dpr = MediaQuery.of(ctx).devicePixelRatio;
      // Save sharp image (2x DPR)
      final ui.Image image = await boundary.toImage(pixelRatio: dpr * 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _toast('Failed to encode image');
        return;
      }
      final bytes = byteData.buffer.asUint8List();

      // Runtime permissions where needed
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          await Permission.storage.request();
        } else if (Platform.isIOS) {
          await Permission.photosAddOnly.request();
        }
      }

      // File name & album
      final t = DateTime.now();
      String two(int v) => v.toString().padLeft(2, '0');
      final label = _sessionDisplay(_selectedSessionForChart)
          .replaceAll(RegExp(r'[^a-zA-Z0-9\-_]+'), '_');
      final base = (label.isEmpty || RegExp(r'^Session_\d+$').hasMatch(label))
          ? ''
          : '_$label';
      final filename = 'scoliometer_session_${_selectedSessionForChart}$base'
          '_${t.year}${two(t.month)}${two(t.day)}_${two(t.hour)}${two(t.minute)}${two(t.second)}.png';

      // Save to Gallery → glarry
      await Gal.putImageBytes(bytes, album: 'Gallery', name: filename);

      _toast('Saved to Gallery');
    } catch (e) {
      _toast('Save failed: $e');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg), duration: const Duration(milliseconds: 1200)),
    );
  }

  // ---- Reset & resume helpers
  void _resetReadings() {
    _peakAbs = 0.0;
    _dispVel = 0.0;
    _targetDeg = 0.0;
    _displayDeg = 0.0;
    _angleAccDeg = 0.0;
    _accAngleBuf.clear();

    final nowS = DateTime.now().microsecondsSinceEpoch / 1e6;
    _freezeUntilS = nowS + 0.08;

    if (mounted) setState(() {});
  }

  void _resumeMeasureView() {
    _freezeUntilS = 0.0;
    _accAngleBuf.clear();
    if (mounted) setState(() {});
  }

  // ----- Session helpers -----
  Future<void> _maybeEndSessionAndSelect(int destinationTab) async {
    if (_tab == 0 && destinationTab != 0) {
      final endedId = _sessionId;

      if (_sessionDirty) {
        _sessionDirty = false;
        await _bumpSessionCounter(); // roll to a new session if we recorded
      }

      _selectedSessionForChart = endedId;
      _selectedSessionForHistory = endedId;

      _resetReadings();
      if (mounted) setState(() {});
    }
  }

  // ----- UI helpers -----
  void _setScaleForRuler(double cm) {
    _uiScale = (cm / 18.0).clamp(0.85, 1.15);
  }

  List<int> _availableSessionsDesc() {
    final set = <int>{};
    for (final r in _log) set.add(r.session);
    if (set.isEmpty) set.add(_sessionId);
    final list = set.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  String _sessionDisplay(int s) {
    final n = _sessionNames[s];
    return (n != null && n.trim().isNotEmpty) ? n.trim() : 'Session $s';
  }

  int _sessionReadingCount(int s) {
    int c = 0;
    for (final r in _log) {
      if (r.session == s) c++;
    }
    return c;
  }

  // ---- Session chip with 3-vertical-dots menu (History & Chart use this)
  Widget _sessionChipWithMenu({
    required int sessionId,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InputChip(
          label: Text(
            _sessionDisplay(sessionId),
            style: const TextStyle(fontSize: 10),
          ),
          selected: selected,
          onPressed: onTap,
          onDeleted: null, // delete handled via menu
          selectedColor: _lighten(kBrand, 0.35),
          side: const BorderSide(color: Color(0x22000000)),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 2),
        PopupMenuButton<String>(
          tooltip: 'Session options',
          icon: const Icon(Icons.more_vert, size: 16),
          onSelected: (val) async {
            switch (val) {
              case 'rename':
                await _promptRenameSession(sessionId);
                break;
              case 'export':
                _exportCsvSession(sessionId);
                break;
              case 'delete':
                _confirmDeleteSession(sessionId);
                break;
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'rename',
              child: Row(
                children: const [
                  Icon(Icons.drive_file_rename_outline, size: 16),
                  SizedBox(width: 8),
                  Text('Rename', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: const [
                  Icon(Icons.copy_all, size: 16),
                  SizedBox(width: 8),
                  Text('Copy CSV', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: const [
                  Icon(Icons.delete_forever, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Text('Delete',
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---- Actions sheet (not used by ⋮ but kept if you want to reuse)
  Future<void> _showSessionActions(int sessionId) async {
    unawaited(HapticFeedback.mediumImpact());
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline),
            title: const Text('Rename session'),
            subtitle: Text(_sessionDisplay(sessionId)),
            onTap: () async {
              Navigator.pop(ctx);
              await _promptRenameSession(sessionId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete session'),
            onTap: () {
              Navigator.pop(ctx);
              _confirmDeleteSession(sessionId);
            },
          ),
        ]),
      ),
    );
  }

  // ---- Rename dialog
  Future<void> _promptRenameSession(int sessionId) async {
    final controller =
        TextEditingController(text: _sessionNames[sessionId] ?? '');
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename session'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Session name',
            hintText: 'e.g., “Pre-PT left bend”',
          ),
          onSubmitted: (_) => Navigator.pop(ctx, controller.text.trim()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (res == null) return;

    final name = res.trim();
    setState(() {
      if (name.isEmpty) {
        _sessionNames.remove(sessionId); // back to "Session X"
      } else {
        _sessionNames[sessionId] = name;
      }
    });
    await _persistSessionNames();
    _toast(name.isEmpty ? 'Session name cleared' : 'Session renamed');
  }

  void _onRawKey(RawKeyEvent event) {
    if (!_simMode || event is! RawKeyDownEvent) return;
    const step = 0.6;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft) {
      _simAngle -= step;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _simAngle += step;
    } else if (key == LogicalKeyboardKey.digit0 || key.keyLabel == '0') {
      _simAngle = 0;
    }
    final raw = _simAngle;
    _accAngleBuf.add(raw);
    if (_accAngleBuf.length > 3) _accAngleBuf.removeAt(0);
    final med = _pushAndMedian(raw);
    _angleAccDeg = med - _zeroOffset;
    _updateDisplay(_angleAccDeg);
  }

  @override
  Widget build(BuildContext context) {
    final body = _tab == 0
        ? _buildMeasure()
        : _tab == 1
            ? _buildHistory()
            : _buildChart();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _lighten(kBrand, 0.55),
        elevation: 2,
        centerTitle: true,
        //actions button
        //actions: [
        //  if (_tab == 0)
        //    Padding(
        //      padding: const EdgeInsets.all(2),
        //      child: Row(
        //        crossAxisAlignment: CrossAxisAlignment.center,
        //        children: [
        //          OutlinedButton.icon(
        //            onPressed: _calibrateZero,
        //            icon: const Icon(Icons.center_focus_strong, size: 8),
        //            label: const Text('Calibrate 0°',
        //                style: TextStyle(fontSize: 8)),
        //            style: OutlinedButton.styleFrom(
        //              padding: const EdgeInsets.all(8),
        //              shape: RoundedRectangleBorder(
        //                borderRadius: BorderRadius.circular(28),
        //              ),
        //              side: BorderSide(color: kBrand),
        //            ),
        //          ),
        //          const SizedBox(width: 8),
        //          FilledButton.icon(
        //            onPressed: _record,
        //            icon: const Icon(Icons.bookmark_add_rounded, size: 8),
        //            label: const Text('Record', style: TextStyle(fontSize: 8)),
        //            style: FilledButton.styleFrom(
        //              padding: const EdgeInsets.all(8),
        //              backgroundColor: kBrand,
        //              foregroundColor: Colors.white,
        //              shape: RoundedRectangleBorder(
        //                borderRadius: BorderRadius.circular(28),
        //              ),
        //            ),
        //          ),
        //        ],
        //      ),
        //    ),
        //],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(-12),
          child: Container(
            color: Colors.transparent,
            child: TabBar(
              labelStyle: const TextStyle(fontSize: 8),
              controller: TabController(length: 3, vsync: Scaffold.of(context)),
              onTap: (idx) {
                setState(() {
                  _tab = idx;
                });
              },
              tabs: [
                Container(
                  width: 80,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: _tab == 0
                        ? Border(bottom: BorderSide(color: kBrand, width: 3))
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.straighten,
                        size: 12,
                        color: _tab == 0 ? kBrand : Colors.black54,
                      ),
                      Text(
                        'Measure',
                        style: TextStyle(
                          fontSize: 12,
                          color: _tab == 0 ? kBrand : Colors.black54,
                          fontWeight:
                              _tab == 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: _tab == 1
                        ? Border(bottom: BorderSide(color: kBrand, width: 3))
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 12,
                        color: _tab == 1 ? kBrand : Colors.black54,
                      ),
                      Text(
                        'History',
                        style: TextStyle(
                          fontSize: 12,
                          color: _tab == 1 ? kBrand : Colors.black54,
                          fontWeight:
                              _tab == 1 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: _tab == 2
                        ? Border(bottom: BorderSide(color: kBrand, width: 3))
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart,
                        size: 12,
                        color: _tab == 2 ? kBrand : Colors.black54,
                      ),
                      Text(
                        'Chart',
                        style: TextStyle(
                          fontSize: 12,
                          color: _tab == 2 ? kBrand : Colors.black54,
                          fontWeight:
                              _tab == 2 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              indicatorColor: Colors.transparent, // Hide default indicator
              labelColor: kBrand,
              unselectedLabelColor: Colors.black54,
            ),
          ),
        ),
      ),
      body: RawKeyboardListener(
        autofocus: true,
        focusNode: _focusNode,
        onKey: _onRawKey,
        child: Stack(
          children: [
            body,
            // Action buttons positioned under app bar
            if (_tab == 0)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _calibrateZero,
                      icon: const Icon(Icons.center_focus_strong, size: 12),
                      label: const Text('Calibrate 0°',
                          style: TextStyle(fontSize: 10)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: kBrand),
                        minimumSize: const Size(0, 28),
                      ),
                    ),
                    const SizedBox(width: 6),
                    FilledButton.icon(
                      onPressed: _record,
                      icon: const Icon(Icons.bookmark_add_rounded, size: 12),
                      label:
                          const Text('Record', style: TextStyle(fontSize: 10)),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        backgroundColor: kBrand,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(0, 28),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------- Measure (no scroll) ----------------------
  Widget _buildMeasure() {
    final angle = _displayDeg;
    return SafeArea(
      child: Column(
        children: [
          if (kIsWeb && _showSimHint && !_sensorSeen)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 8, left: 12, right: 12),
              decoration: BoxDecoration(
                color: _lighten(kBrand, 0.45),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _darken(kBrand, 0.10)),
              ),
              child: Text(
                'No motion sensors detected in this browser. Enable Simulation or use a mobile device.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _darken(kBrand, 0.45)),
              ),
            ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: _AngleGauge(
                        angleDeg: angle,
                        peakAbs: _peakAbs,
                        maxHeight: 320,
                        deviceCmWidth: _desiredDeviceWidthCm,
                        arcLiftFactor: 0.14,
                        convexUp: false,
                        uiScale: _uiScale,
                      ),
                    ),
                    // Controls (mount/width)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<MountMode>(
                            tooltip: 'Mount',
                            onSelected: (m) {
                              setState(() {
                                _mount = m;
                                _zeroOffset = _zeroByMount[_mount] ?? 0.0;
                                _accAngleBuf.clear();
                                _angleAccDeg = 0.0;
                                _displayDeg = 0.0;
                                _dispVel = 0.0;
                                _targetDeg = 0.0;
                              });
                              unawaited(_saveMount());
                              _toast(
                                m == MountMode.longEdge
                                    ? 'Mount: Long Edge'
                                    : m == MountMode.flatBack
                                        ? 'Mount: Flat'
                                        : 'Mount: Short Edge',
                              );
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                  value: MountMode.longEdge,
                                  child: Text('Long Edge (Left/Right)')),
                              PopupMenuItem(
                                  value: MountMode.flatBack,
                                  child: Text('Flat (Back/Front)')),
                              PopupMenuItem(
                                  value: MountMode.shortEdge,
                                  child: Text('Short Edge (Top/Bottom)')),
                            ],
                            icon: const Icon(Icons.screen_rotation_alt),
                          ),
                          const SizedBox(width: 6),
                          PopupMenuButton<double>(
                            tooltip: 'Width',
                            onSelected: (v) => setState(() {
                              _desiredDeviceWidthCm = v;
                              _setScaleForRuler(v);
                              unawaited(_saveWidth());
                            }),
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 15.0, child: Text('15 cm')),
                              PopupMenuItem(value: 18.0, child: Text('18 cm')),
                              PopupMenuItem(value: 20.0, child: Text('20 cm')),
                            ],
                            icon: const Icon(Icons.straighten),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Readings: ${_sessionReadingCount(_sessionId)}'),
                Text('Peak: ${_peakAbs.toStringAsFixed(1)}°'),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // ---------------------- History ----------------------
  Widget _buildHistory() {
    final sessions = _availableSessionsDesc();
    if (!sessions.contains(_selectedSessionForHistory)) {
      _selectedSessionForHistory = sessions.first;
    }

    final data = _log
        .where((r) => r.session == _selectedSessionForHistory)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final stats = _computeStats(data);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        const double minTime = 220, minAtr = 120, minAct = 110;
        double wTime = w * 0.58;
        double wAtr = w * 0.22;
        double wAct = w * 0.20;

        if (wTime < minTime) wTime = minTime;
        if (wAtr < minAtr) wAtr = minAtr;
        if (wAct < minAct) wAct = minAct;

        final total = wTime + wAtr + wAct;
        if (total > w) {
          final excess = total - w;
          wTime = math.max(minTime, wTime - excess);
        }

        return Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final s in sessions)
                              Padding(
                                padding: const EdgeInsets.only(right: 2.0),
                                child: _sessionChipWithMenu(
                                  sessionId: s,
                                  selected: _selectedSessionForHistory == s,
                                  onTap: () => setState(() {
                                    _selectedSessionForHistory = s;
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      children: [
                        OutlinedButton.icon(
                          onPressed: data.isEmpty
                              ? null
                              : () =>
                                  _exportCsvSession(_selectedSessionForHistory),
                          icon: const Icon(Icons.copy_all, size: 12),
                          label: const Text('Copy CSV',
                              style: TextStyle(fontSize: 8)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: const Size(0, 24),
                          ),
                        ),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: const Size(0, 24)),
                          onPressed: _log.isEmpty ? null : _confirmClearAll,
                          icon: const Icon(Icons.delete_forever_rounded,
                              size: 12),
                          label: const Text('Clear',
                              style: TextStyle(fontSize: 8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                  color: _lighten(kBrand, 0.48),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _darken(kBrand, 0.18)),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Text('Count: ${data.length}',
                            style: TextStyle(fontSize: 8))),
                    Expanded(
                        child: Text(
                            'Min: ${stats.min?.toStringAsFixed(1) ?? '-'}°',
                            style: TextStyle(fontSize: 8))),
                    Expanded(
                        child: Text(
                            'Max: ${stats.max?.toStringAsFixed(1) ?? '-'}°',
                            style: TextStyle(fontSize: 8))),
                    Expanded(
                        child: Text(
                            'Avg: ${stats.avg?.toStringAsFixed(1) ?? '-'}°',
                            style: TextStyle(fontSize: 8))),
                  ],
                ),
              ),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dataTableTheme: DataTableThemeData(
                      headingRowHeight: 16,
                      headingTextStyle: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      headingRowColor: WidgetStateProperty.all(
                          Color.fromARGB(255, 204, 238, 239)),
                      dataRowMinHeight: 16,
                      horizontalMargin: 2,
                      columnSpacing: 0,
                      dividerThickness: 0.4,
                      dataTextStyle:
                          TextStyle(fontSize: 9, color: Colors.black87),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: [
                            DataColumn(
                                label: SizedBox(
                                    width: wTime, child: const Text('Time'))),
                            DataColumn(
                                label: SizedBox(
                                    width: wAtr, child: const Text('ATR (°)'))),
                            DataColumn(
                                label: SizedBox(
                                    width: wAct, child: const Text('Actions'))),
                          ],
                          rows: [
                            for (int i = 0; i < data.length; i++)
                              _historyRowStyled(
                                data[i],
                                _log.indexOf(data[i]),
                                i,
                                wTime,
                                wAtr,
                                wAct,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  DataRow _historyRowStyled(_Reading r, int globalIndex, int viewRowIndex,
      double wTime, double wAtr, double wAct) {
    final ts =
        '${r.timestamp.year}-${r.timestamp.month.toString().padLeft(2, '0')}-${r.timestamp.day.toString().padLeft(2, '0')} '
        '${r.timestamp.hour.toString().padLeft(2, '0')}:${r.timestamp.minute.toString().padLeft(2, '0')}:${r.timestamp.second.toString().padLeft(2, '0')}';

    final zebra = viewRowIndex.isOdd ? const Color(0xFFF6F8FA) : Colors.white;

    return DataRow(
      color: WidgetStateProperty.all(zebra),
      cells: [
        DataCell(SizedBox(width: wTime, child: Text(ts))),
        DataCell(SizedBox(
          width: wAtr,
          child: Align(
              alignment: Alignment.centerRight,
              child: Text(r.angleDeg.toStringAsFixed(1))),
        )),
        DataCell(SizedBox(
          width: wAct,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete row',
                onPressed: () async {
                  setState(() => _log.removeAt(globalIndex));
                  await _persistHistory();
                },
              ),
            ],
          ),
        )),
      ],
    );
  }

  // ---------------------- Chart ----------------------
  Widget _buildChart() {
    final sessions = _availableSessionsDesc();
    if (!sessions.contains(_selectedSessionForChart)) {
      _selectedSessionForChart =
          sessions.isNotEmpty ? sessions.first : _sessionId;
    }
    final data = _log
        .where((r) => r.session == _selectedSessionForChart)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top controls row (minimal padding)
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final s in sessions)
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: _sessionChipWithMenu(
                            sessionId: s,
                            selected: _selectedSessionForChart == s,
                            onTap: () => setState(() {
                              _selectedSessionForChart = s;
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  OutlinedButton.icon(
                    onPressed: data.isEmpty ? null : _saveCurrentChartPng,
                    icon: const Icon(Icons.download_rounded, size: 12),
                    label:
                        const Text('Save PNG', style: TextStyle(fontSize: 8)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 24),
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: const Size(0, 24)),
                    onPressed: _log.isEmpty ? null : _confirmClearAll,
                    icon: const Icon(Icons.delete_forever_rounded, size: 12),
                    label: const Text('Clear', style: TextStyle(fontSize: 8)),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Full-bleed chart area
        Expanded(
          child: RepaintBoundary(
            key: _chartRepaintKey,
            child: Container(
              color: _lighten(kBrand, 0.55),
              width: double.infinity,
              height: double.infinity,
              child: data.isEmpty
                  ? const Center(child: Text('No data in this session yet.'))
                  : CustomPaint(
                      painter: _ChartPainter(data),
                      child: const SizedBox.expand(),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  _Stats _computeStats(List<_Reading> rs) {
    if (rs.isEmpty) return const _Stats();
    // Work on absolute values, and clamp into [0, 30]
    double minAbs = double.infinity, maxAbs = 0.0, sumAbs = 0.0;
    for (final r in rs) {
      final v = r.angleDeg.abs().clamp(0.0, 30.0);
      if (v < minAbs) minAbs = v;
      if (v > maxAbs) maxAbs = v;
      sumAbs += v;
    }
    final avgAbs = sumAbs / rs.length;
    return _Stats(
      min: minAbs.isFinite ? minAbs : 0.0,
      max: maxAbs,
      avg: avgAbs,
    );
  }
}

// ======= Data =======
class _Reading {
  final DateTime timestamp;
  final double angleDeg;
  final int session;
  const _Reading(this.timestamp, this.angleDeg, this.session);

  Map<String, dynamic> toJson() =>
      {'t': timestamp.toIso8601String(), 'a': angleDeg, 's': session};

  factory _Reading.fromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    return _Reading(
      DateTime.parse(m['t'] as String),
      (m['a'] as num).toDouble(),
      (m['s'] as num).toInt(),
    );
  }
}

class _Stats {
  final double? min, max, avg;
  const _Stats({this.min, this.max, this.avg});
}

// ======================
//  Gauge (absolute labels), convex-down, with visual scaling
// ======================
class _AngleGauge extends StatelessWidget {
  const _AngleGauge({
    super.key,
    required this.angleDeg,
    required this.peakAbs,
    this.maxHeight = 320.0,
    this.deviceCmWidth = 18.0,
    this.arcLiftFactor = 0.14,
    this.convexUp = false,
    this.uiScale = 1.0,
  });
  final double angleDeg;
  final double peakAbs;
  final double maxHeight;
  final double deviceCmWidth;
  final double arcLiftFactor;
  final bool convexUp;
  final double uiScale;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final capByScreen = screenH * 0.7;

    final pxPerCm = _logicalPixelsPerCm(context);
    final desiredLogicalWidth = deviceCmWidth * pxPerCm;

    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth;
        final width = math.min(desiredLogicalWidth, maxW);
        final hByRatio = width * 0.24;
        final targetH = math.min(math.min(maxHeight, capByScreen), hByRatio);

        return SizedBox(
          width: width,
          height: targetH,
          child: CustomPaint(
            painter: _ShallowGaugePainter(
              angleDeg: angleDeg,
              peakAbs: peakAbs,
              convexUp: convexUp,
              arcLiftFactor: arcLiftFactor,
              uiScale: uiScale,
            ),
          ),
        );
      },
    );
  }
}

class _ShallowGaugePainter extends CustomPainter {
  _ShallowGaugePainter({
    required this.angleDeg,
    required this.peakAbs,
    this.convexUp = false,
    this.arcLiftFactor = 0.0,
    this.uiScale = 1.0,
  });

  final double angleDeg;
  final double peakAbs;
  final bool convexUp;
  final double arcLiftFactor;
  final double uiScale;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final s = uiScale.clamp(0.85, 1.15);

    // Big value
    _drawText(
      canvas,
      '${angleDeg.round()}°',
      Offset(w * 0.5, h * 0.25),
      fontSize: h * 0.28 * s.clamp(0.9, 1.2),
      color: Colors.black87,
      weight: FontWeight.w800,
      align: TextAlign.center,
    );

    // Arc geometry (chord/sagitta)
    final chordBase = w * 0.78;
    final chord = math.min(chordBase * s, w * 0.92);
    final arcSagittaPx = h * 0.20 * s.clamp(0.9, 1.2);
    final halfChord = chord / 2.0;
    final R = (arcSagittaPx / 2.0) + (chord * chord) / (8.0 * arcSagittaPx);

    final liftClamped = arcLiftFactor.clamp(0.0, 0.40);
    final midY = h * (0.88 - liftClamped); // convex-down arc baseline
    final centerY =
        convexUp ? (midY + (R - arcSagittaPx)) : (midY - (R - arcSagittaPx));
    final center = Offset(w * 0.5, centerY);

    final phi = math.atan((R - arcSagittaPx) / halfChord);
    final startA = convexUp ? (math.pi + phi) : (math.pi - phi);
    final endA = convexUp ? (2 * math.pi - phi) : (phi);
    final sweep = endA - startA;

    // Tracks
    final trackW = h * 0.22 * s;
    final innerW = trackW * 0.55;

    final shadowPaint = Paint()..color = const Color(0x14000000);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: R),
      startA,
      sweep,
      false,
      shadowPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackW * 0.56,
    );

    final back = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackW
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE8EEF2);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: R), startA, sweep, false, back);

    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerW
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFDCE6EA);
    canvas.drawArc(Rect.fromCircle(center: center, radius: R), startA, sweep,
        false, inner);

    // Ticks & labels
    final tickColor = Colors.black87;
    final tickBaseR = R - (trackW * 0.56);
    for (int i = -30; i <= 30; i += 5) {
      final t = (i + 30) / 60.0;
      final a = startA + sweep * t;
      final dir = Offset(math.cos(a), math.sin(a));
      final baseP = center + dir * tickBaseR;
      final len = (i % 10 == 0) ? h * 0.052 * s : h * 0.030 * s;
      final p2 = baseP + dir * len;

      canvas.drawLine(
        baseP,
        p2,
        Paint()
          ..color = tickColor
          ..strokeWidth = (i % 10 == 0) ? 2.2 : 1.4
          ..strokeCap = StrokeCap.round,
      );

      if (i % 10 == 0) {
        const double kLabelArcGap = 0.060;
        final labelPos = p2 + dir * (h * kLabelArcGap * s);
        final label = (i == 0) ? '0' : i.abs().toString();
        _drawText(
          canvas,
          label,
          labelPos,
          fontSize: h * 0.080 * s,
          color: tickColor,
          weight: FontWeight.w700,
          align: TextAlign.center,
          anchorCenter: true,
        );
      }
    }

    // Bottom notch
    {
      final aMid = startA + sweep * 0.5;
      final dirMid = Offset(math.cos(aMid), math.sin(aMid));
      final dirOut = convexUp ? -dirMid : dirMid;
      final outerR = R + trackW * 0.50;
      final gap = trackW * 0.10;
      final base = center + dirOut * (outerR + gap);
      final halfW = trackW * 0.35;
      final depth = trackW * 0.45;
      final tangent = Offset(-dirOut.dy, dirOut.dx);

      final pL = base - tangent * halfW;
      final pR = base + tangent * halfW;
      final pTip = base + dirOut * depth;

      final notchPath = Path()
        ..moveTo(pL.dx, pL.dy)
        ..lineTo(pTip.dx, pTip.dy)
        ..lineTo(pR.dx, pR.dy)
        ..close();

      canvas.drawPath(notchPath, Paint()..color = Colors.white);
      canvas.drawPath(
        notchPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeJoin = StrokeJoin.round
          ..color = _darken(kBrand, 0.25),
      );
    }

    // Bubble (UI clamps to ±30°)
    final clamped = angleDeg.clamp(-30.0, 30.0);
    final tVal = (clamped + 30.0) / 60.0;
    final aVal = startA + sweep * tVal;
    final dir = Offset(math.cos(aVal), math.sin(aVal));
    final bubbleCenter = center + dir * (R - trackW * 0.10);

    canvas.drawCircle(
      bubbleCenter.translate(0, convexUp ? 2 : -2),
      trackW * 0.26,
      Paint()..color = const Color(0x33000000),
    );
    canvas.drawCircle(bubbleCenter, trackW * 0.26, Paint()..color = kBrand);
    canvas.drawCircle(
      bubbleCenter,
      trackW * 0.26,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _darken(kBrand, 0.20),
    );
  }

  @override
  bool shouldRepaint(covariant _ShallowGaugePainter old) =>
      old.angleDeg != angleDeg ||
      old.peakAbs != peakAbs ||
      old.convexUp != convexUp ||
      old.arcLiftFactor != arcLiftFactor ||
      old.uiScale != uiScale;

  void _drawText(
    Canvas canvas,
    String text,
    Offset center, {
    double fontSize = 16,
    Color color = Colors.black,
    FontWeight weight = FontWeight.w600,
    TextAlign align = TextAlign.center,
    bool anchorCenter = true,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
            fontSize: fontSize, color: color, fontWeight: weight, height: 1.0),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = anchorCenter
        ? Offset(center.dx - tp.width / 2, center.dy - tp.height / 2)
        : center;
    tp.paint(canvas, offset);
  }
}

// ======================
//  Nicer Line Chart (smooth + gradient + markers)
// ======================
class _ChartPainter extends CustomPainter {
  _ChartPainter(this.data);
  final List<_Reading> data;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Layout (padding to accommodate Y-axis labels)
    final padding = const EdgeInsets.fromLTRB(40, 8, 8, 8);
    final plot = Rect.fromLTWH(
      padding.left,
      padding.top,
      w - padding.left - padding.right,
      h - padding.top - padding.bottom,
    );

    // Backdrop
    final bg = Paint()..color = Colors.white.withOpacity(0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(plot.inflate(6), const Radius.circular(12)),
      bg,
    );

    if (data.isEmpty) {
      _drawSmallText(canvas, 'No data', Offset(plot.center.dx, plot.center.dy),
          align: TextAlign.center);
      return;
    }

    // Time & value ranges
    final t0 = data.first.timestamp.millisecondsSinceEpoch.toDouble();
    final tN = data.last.timestamp.millisecondsSinceEpoch.toDouble();
    final dt = (tN - t0).clamp(1, double.infinity);
    double xFor(DateTime t) =>
        plot.left +
        (t.millisecondsSinceEpoch.toDouble() - t0) / dt * plot.width;

    const yMin = -30.0, yMax = 30.0;
    double yFor(double v) =>
        plot.bottom - ((v - yMin) / (yMax - yMin)) * plot.height;

    // Grid (y) - Major grid lines every 10 degrees
    final majorGrid = Paint()
      ..color = _darken(kBrand, 0.12)
      ..strokeWidth = 0.7;
    final minorGrid = Paint()
      ..color = _darken(kBrand, 0.08)
      ..strokeWidth = 0.4;

    for (double y = -30; y <= 30; y += 5) {
      final yy = yFor(y);
      final isMajor = (y % 10 == 0);

      // alternating bands for major lines
      if (isMajor && ((y / 10).round() & 1) == 0) {
        canvas.drawRect(
          Rect.fromLTWH(plot.left, yy, plot.width, yFor(y - 10) - yy)
              .intersect(plot),
          Paint()..color = const Color(0x0F000000),
        );
      }

      // Draw grid line
      canvas.drawLine(Offset(plot.left, yy), Offset(plot.right, yy),
          isMajor ? majorGrid : minorGrid);

      // Draw labels for major lines
      if (isMajor) {
        _drawSmallText(canvas, '${y.toInt()}°', Offset(plot.left - 15, yy),
            align: TextAlign.right);
      }
    }

    // Axes
    final axis = Paint()
      ..color = _darken(kBrand, 0.4)
      ..strokeWidth = 1.2;
    canvas.drawLine(
        Offset(plot.left, plot.bottom), Offset(plot.right, plot.bottom), axis);
    canvas.drawLine(
        Offset(plot.left, plot.top), Offset(plot.left, plot.bottom), axis);

    // Zero line (highlight)
    final yZero = yFor(0);
    canvas.drawLine(
      Offset(plot.left, yZero),
      Offset(plot.right, yZero),
      Paint()
        ..color = _darken(kBrand, 0.55)
        ..strokeWidth = 1.6,
    );

    // Points (signed y — keep the original sign on the plot)
    final points = <Offset>[
      for (final r in data) Offset(xFor(r.timestamp), yFor(r.angleDeg))
    ];

    // Smooth path (Catmull–Rom)
    final smooth = _catmullRom(points, 12, tightness: 0.5);
    final path = Path()..moveTo(smooth.first.dx, smooth.first.dy);
    for (int i = 1; i < smooth.length; i++) {
      path.lineTo(smooth[i].dx, smooth[i].dy);
    }

    // Soft shadow
    final shadowPath = path.shift(const Offset(0, 2));
    canvas.drawPath(
      shadowPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.6
        ..color = const Color(0x1F000000),
    );

    // Area gradient
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, plot.bottom)
      ..lineTo(points.first.dx, plot.bottom)
      ..close();
    final fill = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, plot.top),
        Offset(0, plot.bottom),
        [
          _lighten(kBrand, 0.25).withOpacity(0.22),
          kBrand.withOpacity(0.06),
          Colors.transparent,
        ],
        [0.0, 0.55, 1.0],
      );
    canvas.drawPath(fillPath, fill);

    // Line (signed)
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = _darken(kBrand, 0.45),
    );

    // Point markers
    final dot = Paint()..color = kBrand;
    for (final p in points) {
      canvas.drawCircle(p, 3.0, dot);
    }

    // ---------- Stats using ABSOLUTE values ----------
    final values = data.map((e) => e.angleDeg).toList();
    final valuesAbs = values.map((v) => v.abs().clamp(0.0, 30.0)).toList();
    final avgAbs = valuesAbs.reduce((a, b) => a + b) / valuesAbs.length;

    // Find indices of min/max by absolute value (first occurrence)
    int minIdx = 0, maxIdx = 0;
    double minAbs = valuesAbs[0], maxAbs = valuesAbs[0];
    for (int i = 1; i < valuesAbs.length; i++) {
      final v = valuesAbs[i];
      if (v < minAbs) {
        minAbs = v;
        minIdx = i;
      }
      if (v > maxAbs) {
        maxAbs = v;
        maxIdx = i;
      }
    }

    // Draw ABS average as a positive dashed line at +avgAbs
    _drawDashedLine(
      canvas,
      Offset(plot.left, yFor(avgAbs)),
      Offset(plot.right, yFor(avgAbs)),
      dash: 6,
      gap: 6,
      paint: Paint()
        ..color = _darken(kBrand, 0.35)
        ..strokeWidth = 1.2,
    );
    _bubbleLabel(
      canvas,
      'avg ${avgAbs.toStringAsFixed(1)}°',
      Offset(plot.right - 6, yFor(avgAbs) - 14),
      plot,
      alignRight: true,
    );

    // Markers for min/max based on ABS — place marker on the actual signed point
    final pMin = points[minIdx];
    final pMax = points[maxIdx];
    canvas.drawCircle(pMin, 4.2, Paint()..color = Colors.redAccent);
    canvas.drawCircle(pMax, 4.2, Paint()..color = Colors.green.shade700);

    // Labels show absolute numbers (kept inside the plot)
    _bubbleLabel(
      canvas,
      'min ${minAbs.toStringAsFixed(1)}°',
      pMin + const Offset(8, -18),
      plot,
    );
    _bubbleLabel(
      canvas,
      'max ${maxAbs.toStringAsFixed(1)}°',
      pMax + const Offset(8, -18),
      plot,
      color: Colors.green.shade700,
    );
  }

  // ---- Helpers ----
  List<Offset> _catmullRom(List<Offset> pts, int samplesPerSeg,
      {double tightness = 0.5}) {
    if (pts.length <= 2) return pts;
    final res = <Offset>[];
    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = i == 0 ? pts[i] : pts[i - 1];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : pts[i + 1];
      for (int j = 0; j < samplesPerSeg; j++) {
        final t = j / samplesPerSeg;
        res.add(_catmullPoint(p0, p1, p2, p3, t, tightness));
      }
    }
    res.add(pts.last);
    return res;
  }

  Offset _catmullPoint(
      Offset p0, Offset p1, Offset p2, Offset p3, double t, double c) {
    final t2 = t * t;
    final t3 = t2 * t;
    final a0 = -c * t + 2 * c * t2 - c * t3;
    final a1 = 1 + (c - 3) * t2 + (2 - c) * t3;
    final a2 = c * t + (3 - 2 * c) * t2 + (c - 2) * t3;
    final a3 = -c * t2 + c * t3;
    final x = a0 * p0.dx + a1 * p1.dx + a2 * p2.dx + a3 * p3.dx;
    final y = a0 * p0.dy + a1 * p1.dy + a2 * p2.dy + a3 * p3.dy;
    return Offset(x, y);
  }

  void _drawDashedLine(Canvas c, Offset a, Offset b,
      {required double dash, required double gap, required Paint paint}) {
    final total = (b - a).distance;
    final dir = (b - a) / total;
    double covered = 0.0;
    while (covered < total) {
      final start = a + dir * covered;
      final end = a + dir * math.min(covered + dash, total);
      c.drawLine(start, end, paint);
      covered += dash + gap;
    }
  }

  void _bubbleLabel(
    Canvas canvas,
    String text,
    Offset anchor,
    Rect keepInside, {
    bool alignRight = false,
    Color? color,
    bool preferAbove = true,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 11.5,
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final pad = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    // Start with a bubble just above (or below) the anchor
    final initialTop =
        preferAbove ? anchor.dy - tp.height - pad.vertical - 6 : anchor.dy + 6;
    double left =
        alignRight ? anchor.dx - tp.width - pad.horizontal : anchor.dx;

    double top = initialTop;

    // Bubble rect
    RRect bubble(Rect r) =>
        RRect.fromRectAndRadius(r, const Radius.circular(8));
    Rect rect = Rect.fromLTWH(
        left, top, tp.width + pad.horizontal, tp.height + pad.vertical);

    // Clamp inside the plotting area (with a tiny margin)
    final bounds = keepInside.deflate(4);
    // If it overflows vertically above, try placing below
    if (rect.top < bounds.top) {
      top = anchor.dy + 6;
      rect = Rect.fromLTWH(left, top, rect.width, rect.height);
    }
    // If below overflow, move above
    if (rect.bottom > bounds.bottom) {
      top = anchor.dy - rect.height - 6;
      rect = Rect.fromLTWH(left, top, rect.width, rect.height);
    }
    // Clamp horizontally
    if (rect.left < bounds.left) {
      left = bounds.left;
      rect = Rect.fromLTWH(left, top, rect.width, rect.height);
    }
    if (rect.right > bounds.right) {
      left = bounds.right - rect.width;
      rect = Rect.fromLTWH(left, top, rect.width, rect.height);
    }

    final r = bubble(rect);
    canvas.drawRRect(r, Paint()..color = Colors.white.withOpacity(0.9));
    canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0x22000000));
    tp.paint(canvas, Offset(r.left + pad.left, r.top + pad.top - 1));
  }

  void _drawSmallText(Canvas canvas, String text, Offset anchor,
      {TextAlign align = TextAlign.left}) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 11, color: Colors.black87)),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();
    Offset pos;
    switch (align) {
      case TextAlign.center:
        pos = Offset(anchor.dx - tp.width / 2, anchor.dy - tp.height / 2);
        break;
      case TextAlign.right:
        pos = Offset(anchor.dx - tp.width, anchor.dy - tp.height / 2);
        break;
      default:
        pos = Offset(anchor.dx, anchor.dy - tp.height / 2);
    }
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => old.data != data;
}
