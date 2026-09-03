import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF8FCFF),
                      Color(0xFFEAF8FF),
                      Color(0xFFF8FFFC),
                    ],
                  ),
                ),
              ),
              CustomPaint(
                painter: _WaterPainter(
                  progress: _controller.value,
                  primary: scheme.primary,
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: 0.94 +
                              (math.sin(_controller.value * math.pi * 2) + 1) *
                                  0.03,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: SvgPicture.asset(
                              'assets/hrms_logo.svg',
                              width: 330,
                              height: 145,
                              fit: BoxFit.contain,
                              semanticsLabel: 'Kopersay HRMS logo',
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Kopersay HRMS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Human Resource Management System',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: 42,
                          height: 42,
                          child: CircularProgressIndicator(
                            value: null,
                            strokeWidth: 2.5,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Preparing your workspace…',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WaterPainter extends CustomPainter {
  final double progress;
  final Color primary;

  const _WaterPainter({required this.progress, required this.primary});

  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = primary.withValues(alpha: 0.07);

    for (var layer = 0; layer < 3; layer++) {
      final baseY = size.height * (0.78 + layer * 0.08);
      final path = Path()..moveTo(0, size.height);
      path.lineTo(0, baseY);

      for (double x = 0; x <= size.width + 24; x += 24) {
        final y = baseY +
            math.sin((x / size.width) * math.pi * 3 +
                    progress * math.pi * 2 +
                    layer) *
                (10 + layer * 5);
        path.lineTo(x, y);
      }

      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, wavePaint);
    }

    final ripplePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = primary.withValues(alpha: 0.10);

    final center = Offset(size.width / 2, size.height * 0.48);
    for (var i = 0; i < 3; i++) {
      final value = (progress + i / 3) % 1.0;
      final radius = 35 + value * size.width * 0.34;
      final opacity = (1 - value) * 0.7;
      ripplePaint.color = primary.withValues(alpha: 0.10 * opacity);
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2.1,
          height: radius * 0.65,
        ),
        ripplePaint,
      );
    }

    final bubblePaint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 8; i++) {
      final x = size.width * (0.08 + i * 0.12);
      final travel = (progress + i * 0.13) % 1.0;
      final y = size.height * (0.92 - travel * 0.55);
      bubblePaint.color = primary.withValues(alpha: 0.05 + (i % 3) * 0.02);
      canvas.drawCircle(Offset(x, y), 3 + (i % 3) * 1.5, bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaterPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.primary != primary;
}
