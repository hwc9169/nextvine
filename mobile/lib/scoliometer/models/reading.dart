// lib/scoliometer/models/reading.dart
class Reading {
  final DateTime timestamp;
  final double angleDeg;
  final int session;

  const Reading(this.timestamp, this.angleDeg, this.session);

  Map<String, dynamic> toJson() => {
    't': timestamp.toIso8601String(), 
    'a': angleDeg, 
    's': session
  };

  factory Reading.fromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    return Reading(
      DateTime.parse(m['t'] as String),
      (m['a'] as num).toDouble(),
      (m['s'] as num).toInt(),
    );
  }
}

class Stats {
  final double? min, max, avg;
  const Stats({this.min, this.max, this.avg});
}
