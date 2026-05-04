import 'package:flutter/material.dart';

class OmmpLogo extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const OmmpLogo({super.key, this.width = 80, this.height = 64,
      this.color = Colors.white});

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(width, height),
    painter: _OmmpPainter(color: color),
  );
}

class _OmmpPainter extends CustomPainter {
  final Color color;
  const _OmmpPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.044;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // ── 3 lignes horizontales (côté gauche) ─────────────────────
    void drawLine(double y, double width) {
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, y, width, h * 0.055),
        Radius.circular(h * 0.028),
      );
      canvas.drawRRect(rr, fill);
    }
    drawLine(h * 0.55, w * 0.38);
    drawLine(h * 0.65, w * 0.30);
    drawLine(h * 0.75, w * 0.22);

    // ── Mât vertical ─────────────────────────────────────────────
    final mx = w * 0.72;
    canvas.drawLine(Offset(mx, h * 0.02), Offset(mx, h * 0.88), stroke);

    // ── Arc voile gauche ─────────────────────────────────────────
    final pL = Path()
      ..moveTo(mx, h * 0.02)
      ..quadraticBezierTo(w * 0.50, h * 0.36, w * 0.53, h * 0.88);
    canvas.drawPath(pL, stroke);

    // ── Arc voile droite ─────────────────────────────────────────
    final pR = Path()
      ..moveTo(mx, h * 0.02)
      ..quadraticBezierTo(w * 0.95, h * 0.36, mx, h * 0.88);
    canvas.drawPath(pR, stroke);

    // ── Point ancre ──────────────────────────────────────────────
    canvas.drawCircle(Offset(w * 0.50, h * 0.83), w * 0.038, fill);

    // ── Petite ligne sous ancre ───────────────────────────────────
    final lp = Paint()
      ..color = color.withOpacity(0.55)
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.50, h * 0.87),
      Offset(w * 0.50, h * 0.95),
      lp,
    );
  }

  @override
  bool shouldRepaint(_OmmpPainter o) => o.color != color;
}