import 'package:flutter/material.dart';

class CustomCircle extends StatelessWidget {
  final double radius;
  final Color color;

  const CustomCircle({super.key, required this.radius, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: _CirclePainter(radius: radius, color: color),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double radius;
  final Color color;

  _CirclePainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(radius, radius), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
