// lib/scoliometer/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading.dart';
import '../models/mount_mode.dart';

class StorageService {
  static const String _historyKey = 'pref_history_v1';
  static const String _sessionNamesKey = 'pref_session_names_v1';
  static const String _sessionCounterKey = 'pref_session_counter';
  static const String _mountKey = 'pref_mount';
  static const String _widthKey = 'pref_width_cm';
  static const String _zeroFlatBackKey = 'pref_zero_flatBack';
  static const String _zeroLongEdgeKey = 'pref_zero_longEdge';
  static const String _zeroShortEdgeKey = 'pref_zero_shortEdge';

  Future<List<Reading>> loadHistory() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_historyKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        return decoded.map((e) => Reading.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> saveHistory(List<Reading> readings) async {
    try {
      final p = await SharedPreferences.getInstance();
      final list = readings.length > 2000 ? readings.sublist(readings.length - 2000) : readings;
      final raw = jsonEncode(list.map((e) => e.toJson()).toList());
      await p.setString(_historyKey, raw);
    } catch (_) {}
  }

  Future<Map<int, String>> loadSessionNames() async {
    try {
      final p = await SharedPreferences.getInstance();
      final namesRaw = p.getString(_sessionNamesKey);
      if (namesRaw != null && namesRaw.isNotEmpty) {
        final Map<String, dynamic> m = jsonDecode(namesRaw) as Map<String, dynamic>;
        final result = <int, String>{};
        for (final e in m.entries) {
          result[int.parse(e.key)] = e.value as String;
        }
        return result;
      }
    } catch (_) {}
    return {};
  }

  Future<void> saveSessionNames(Map<int, String> sessionNames) async {
    try {
      final p = await SharedPreferences.getInstance();
      final m = <String, String>{
        for (final e in sessionNames.entries) e.key.toString(): e.value
      };
      await p.setString(_sessionNamesKey, jsonEncode(m));
    } catch (_) {}
  }

  Future<int> loadSessionCounter() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getInt(_sessionCounterKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> saveSessionCounter(int counter) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_sessionCounterKey, counter);
    } catch (_) {}
  }

  Future<MountMode> loadMountMode() async {
    try {
      final p = await SharedPreferences.getInstance();
      final mountIndex = p.getInt(_mountKey);
      if (mountIndex != null &&
          mountIndex >= 0 &&
          mountIndex < MountMode.values.length) {
        return MountMode.values[mountIndex];
      }
    } catch (_) {}
    return MountMode.longEdge;
  }

  Future<void> saveMountMode(MountMode mount) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_mountKey, mount.index);
    } catch (_) {}
  }

  Future<double> loadDeviceWidth() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getDouble(_widthKey) ?? 18.0;
    } catch (_) {
      return 18.0;
    }
  }

  Future<void> saveDeviceWidth(double width) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setDouble(_widthKey, width);
    } catch (_) {}
  }

  Future<Map<MountMode, double>> loadZeroOffsets() async {
    try {
      final p = await SharedPreferences.getInstance();
      return {
        MountMode.flatBack: p.getDouble(_zeroFlatBackKey) ?? 0.0,
        MountMode.longEdge: p.getDouble(_zeroLongEdgeKey) ?? 0.0,
        MountMode.shortEdge: p.getDouble(_zeroShortEdgeKey) ?? 0.0,
      };
    } catch (_) {
      return {
        MountMode.flatBack: 0.0,
        MountMode.longEdge: 0.0,
        MountMode.shortEdge: 0.0,
      };
    }
  }

  Future<void> saveZeroOffset(MountMode mount, double offset) async {
    try {
      final p = await SharedPreferences.getInstance();
      final key = switch (mount) {
        MountMode.flatBack  => _zeroFlatBackKey,
        MountMode.longEdge  => _zeroLongEdgeKey,
        MountMode.shortEdge => _zeroShortEdgeKey,
      };
      await p.setDouble(key, offset);
    } catch (_) {}
  }
}
