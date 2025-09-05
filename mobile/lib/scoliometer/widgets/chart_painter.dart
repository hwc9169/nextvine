// lib/scoliometer/widgets/chart_painter.dart
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/reading.dart';

class ChartPainter extends CustomPainter {
  ChartPainter(this.data);

  final List<Reading> data;
  static const Color kBrand = Color(0xFF359296);

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

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Layout (slightly tighter top/bottom to maximize plot)
    const padding = EdgeInsets.fromLTRB(56, 16, 16, 36);
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

    // Grid (y)
    final grid = Paint()
      ..color = _darken(kBrand, 0.12)
      ..strokeWidth = 0.7;
    for (double y = -30; y <= 30; y += 10) {
      final yy = yFor(y);
      // alternating bands
      if (((y / 10).round() & 1) == 0) {
        canvas.drawRect(
          Rect.fromLTWH(plot.left, yy, plot.width, yFor(y - 10) - yy)
              .intersect(plot),
          Paint()..color = const Color(0x0F000000),
        );
      }
      canvas.drawLine(Offset(plot.left, yy), Offset(plot.right, yy), grid);
      _drawSmallText(canvas, '${y.toInt()}°', Offset(plot.left - 10, yy),
          align: TextAlign.right);
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

    // X captions (inside the plot, so they save)
    _drawSmallText(canvas, 'Start', Offset(points.first.dx, plot.bottom - 12),
        align: TextAlign.center);
    _drawSmallText(canvas, 'End', Offset(points.last.dx, plot.bottom - 12),
        align: TextAlign.center);
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

    const pad = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

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
  bool shouldRepaint(covariant ChartPainter old) => old.data != data;
}
