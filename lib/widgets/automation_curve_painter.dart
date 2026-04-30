import 'package:flutter/material.dart';
import 'package:studio_wiz/models/automation_system.dart';

class AutomationCurvePainter extends CustomPainter {
  final AutomationLane lane;
  final Duration totalDuration;

  AutomationCurvePainter({required this.lane, required this.totalDuration});

  @override
  void paint(Canvas canvas, Size size) {
    if (lane.points.isEmpty || totalDuration.inMilliseconds == 0) return;

    final paint = Paint()
      ..color = lane.color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool first = true;

    for (final point in lane.points) {
      final x = (point.time.inMilliseconds / totalDuration.inMilliseconds) * size.width;
      // Normalize value to 0-1 range based on min/max
      final normalizedValue = (point.value - lane.minValue) / (lane.maxValue - lane.minValue);
      // Invert Y so higher value = higher on screen
      final y = size.height - (normalizedValue * size.height);

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }

      // Draw point circle
      canvas.drawCircle(Offset(x, y), 4, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke; // reset
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
