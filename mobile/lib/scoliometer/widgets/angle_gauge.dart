// lib/scoliometer/widgets/angle_gauge.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AngleGauge extends StatelessWidget {
  const AngleGauge({
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

  /// Logical px per cm ≈ (160 * devicePixelRatio) / 2.54
  static double logicalPixelsPerCm(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final dpi = 160.0 * dpr;
    return dpi / 2.54;
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final capByScreen = screenH * 0.7;

    final pxPerCm = logicalPixelsPerCm(context);
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
            painter: ShallowGaugePainter(
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

class ShallowGaugePainter extends CustomPainter {
  ShallowGaugePainter({
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

  static const Color kBrand = Color(0xFF359296);

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    final l = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }

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
  bool shouldRepaint(covariant ShallowGaugePainter old) =>
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
