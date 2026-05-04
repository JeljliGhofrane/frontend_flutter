import 'package:flutter/material.dart';

/// Découpe une vague organique en bas d'un container
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width * 0.25, size.height - 60,
      size.width * 0.5,  size.height - 30,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height,
      size.width,        size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) => false;
}

/// Peint la vague + le fond navy + les décorations
class WaveHeader extends StatelessWidget {
  final double height;
  final Widget? child;

  const WaveHeader({
    super.key,
    this.height = 280,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipPath(
        clipper: WaveClipper(),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0D2557),
          ),
          child: Stack(
            children: [
              // Arcs décoratifs (comme dans le design)
              Positioned(
                top: -30,
                right: -30,
                child: _DecorCircle(size: 160, opacity: 0.06),
              ),
              Positioned(
                top: 20,
                right: 40,
                child: _DecorCircle(size: 110, opacity: 0.04),
              ),
              Positioned(
                bottom: 60,
                left: -20,
                child: _DecorCircle(size: 100, opacity: 0.05),
              ),
              // Étoiles déco
              const Positioned(
                top: 55,
                left: 55,
                child: _Star(size: 18, opacity: 0.35),
              ),
              const Positioned(
                top: 110,
                right: 60,
                child: _Star(size: 12, opacity: 0.22),
              ),
              const Positioned(
                bottom: 90,
                right: 90,
                child: _Star(size: 10, opacity: 0.18),
              ),
              // Contenu
              if (child != null) child!,
            ],
          ),
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(opacity),
          width: 14,
        ),
      ),
    );
  }
}

class _Star extends StatelessWidget {
  final double size;
  final double opacity;
  const _Star({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StarPainter(opacity: opacity),
    );
  }
}

class _StarPainter extends CustomPainter {
  final double opacity;
  const _StarPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), p);
    canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), p);
    canvas.drawLine(
        Offset(cx - r * 0.7, cy - r * 0.7), Offset(cx + r * 0.7, cy + r * 0.7), p);
    canvas.drawLine(
        Offset(cx + r * 0.7, cy - r * 0.7), Offset(cx - r * 0.7, cy + r * 0.7), p);
  }

  @override
  bool shouldRepaint(_StarPainter old) => false;
}