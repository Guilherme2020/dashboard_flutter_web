import 'dart:math' as math;
import 'package:flutter/material.dart';

class HexagonalLogo extends StatelessWidget {
  final double size;
  final Color color;

  const HexagonalLogo({
    super.key,
    this.size = 40,
    this.color = const Color(0xFF424242),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final logoColor = isDark ? Colors.grey[300] : color;

    return CustomPaint(
      size: Size(size, size),
      painter: _HexagonalLogoPainter(color: logoColor!),
    );
  }
}

class _HexagonalLogoPainter extends CustomPainter {
  final Color color;

  _HexagonalLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);

    final barWidth = size.width * 0.12;
    final barSpacing = size.width * 0.15;
    final startX = center.dx - barSpacing;
    final barHeight1 = size.height * 0.4;
    final barHeight2 = size.height * 0.6;
    final barHeight3 = size.height * 0.5;
    final barY = center.dy - barHeight2 / 2;

    canvas.drawRect(
      Rect.fromLTWH(
        startX - barWidth / 2,
        barY + (barHeight2 - barHeight1) / 2,
        barWidth,
        barHeight1,
      ),
      Paint()..color = Colors.white,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - barWidth / 2,
        barY,
        barWidth,
        barHeight2,
      ),
      Paint()..color = Colors.white,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        startX + barSpacing - barWidth / 2,
        barY + (barHeight2 - barHeight3) / 2,
        barWidth,
        barHeight3,
      ),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

