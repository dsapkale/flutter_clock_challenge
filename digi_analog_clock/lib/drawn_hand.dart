import 'dart:math' as math;

import 'package:analog_clock/styles.dart';
import 'package:flutter/material.dart';

import 'hand.dart';

/// A clock hand that is drawn with [CustomPainter]
///
/// The hand's length scales based on the clock's size.
/// This hand is used to build the second, minute and hour hands, and demonstrates
/// building a custom hand.
class DrawnHand extends Hand {
  /// Create a const clock [Hand].
  ///
  /// All of the parameters are required and must not be null.
  const DrawnHand({
    @required Color color,
    @required double size,
    @required double angleRadians,
    @required this.time,
  })  : assert(color != null),
        assert(size != null),
        assert(angleRadians != null),
        assert(time != null),
        super(
          color: color,
          size: size,
          angleRadians: angleRadians,
        );
  final String time;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _HandPainter(
              handSize: size,
              angleRadians: angleRadians,
              color: color,
              time: time),
        ),
      ),
    );
  }
}

/// [CustomPainter] that draws a clock hand.
class _HandPainter extends CustomPainter {
  _HandPainter({
    @required this.handSize,
    @required this.angleRadians,
    @required this.color,
    @required this.time,
  })  : assert(handSize != null),
        assert(angleRadians != null),
        assert(color != null),
        assert(handSize >= 0.0),
        assert(handSize <= 1.0);

  double handSize;
  double angleRadians;
  Color color;
  final String time;

  @override
  void paint(Canvas canvas, Size size) {
    final center = (Offset.zero & size).center;
    // angle for first point for the path from the center
    final angle = angleRadians - math.pi / 2.1;
    // angle for second point for the path from the center
    final angle2 = angleRadians - math.pi / 1.9;
    // angle for the center point of the circle
    final angle3 = angleRadians - math.pi / 2.0;

    final length = size.shortestSide * 0.5 * handSize;
    final positionToLength =
        center + Offset(math.cos(angle), math.sin(angle)) * length;
    final positionToLenWithAngle =
        center + Offset(math.cos(angle2), math.sin(angle2)) * length;
    final postiionCircle =
        center + Offset(math.cos(angle3), math.sin(angle3)) * length * .81;
    final handPaint = Paint()..color = color;

    var handPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(positionToLength.dx, positionToLength.dy)
      ..lineTo(positionToLenWithAngle.dx, positionToLenWithAngle.dy)
      ..close();
    canvas.drawPath(handPath, handPaint);

    /// text to be drawn on the hands
    final textSpan = TextSpan(
      text: time,
      style: infoTextStyle(
          fontSize: handSize * 32,
          color: Colors.white,
          fontWeight: FontWeight.bold),
    );
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    var textPosition =
        postiionCircle - Offset(textPainter.width / 2, textPainter.height / 2);
    canvas.drawCircle(postiionCircle, handSize * 25, handPaint);
    textPainter.paint(canvas, textPosition);
  }

  @override
  bool shouldRepaint(_HandPainter oldDelegate) {
    return oldDelegate.handSize != handSize ||
        oldDelegate.angleRadians != angleRadians ||
        oldDelegate.color != color;
  }
}
