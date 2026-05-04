import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Header avec vague en bas — utilise un CustomPaint + ClipPath
/// La hauteur est fixe et ne dépend PAS de MediaQuery
class WaveHeader extends StatelessWidget {
  final double height;
  final Widget? child;
  const WaveHeader({super.key, this.height = 260, this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipPath(
        clipper: _WaveClipper(),
        child: Container(
          color: AppColors.navyDark,
          child: Stack(
            children: [
              // Cercles décoratifs
              Positioned(top: -30, right: -30, child: _Circle(180, 0.06)),
              Positioned(top: 20,  right: 40,  child: _Circle(110, 0.04)),
              Positioned(bottom: 70, left: -20, child: _Circle(100, 0.05)),
              // Étoiles
              const Positioned(top: 50, left: 50, child: _Star(18, 0.28)),
              const Positioned(top: 100, right: 55, child: _Star(12, 0.18)),
              // Contenu
              if (child != null) child!,
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = Path();
    p.lineTo(0, s.height - 36);
    p.quadraticBezierTo(s.width * .25, s.height - 68,
        s.width * .5, s.height - 36);
    p.quadraticBezierTo(s.width * .75, s.height - 4,
        s.width, s.height - 36);
    p.lineTo(s.width, 0);
    p.close();
    return p;
  }
  @override bool shouldReclip(_WaveClipper o) => false;
}

class _Circle extends StatelessWidget {
  final double size; final double opacity;
  const _Circle(this.size, this.opacity);
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withOpacity(opacity), width: 14),
    ),
  );
}

class _Star extends StatelessWidget {
  final double size; final double opacity;
  const _Star(this.size, this.opacity);
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _StarPainter(opacity));
}

class _StarPainter extends CustomPainter {
  final double opacity;
  const _StarPainter(this.opacity);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final cx = s.width / 2; final cy = s.height / 2; final r = s.width / 2;
    canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), p);
    canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), p);
    canvas.drawLine(Offset(cx - r*.7, cy - r*.7), Offset(cx + r*.7, cy + r*.7), p);
    canvas.drawLine(Offset(cx + r*.7, cy - r*.7), Offset(cx - r*.7, cy + r*.7), p);
  }
  @override bool shouldRepaint(_StarPainter o) => false;
}