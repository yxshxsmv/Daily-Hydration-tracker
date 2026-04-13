import 'dart:math';

import 'package:flutter/material.dart';

class BottleWidget extends StatefulWidget {
  final double progress;
  final int consumed;
  final int goal;

  const BottleWidget({
    super.key,
    required this.progress,
    required this.consumed,
    required this.goal,
  });

  @override
  State<BottleWidget> createState() => _BottleWidgetState();
}

class _BottleWidgetState extends State<BottleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController waveController;
  double animatedProgress = 0;

  @override
  void initState() {
    super.initState();

    waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    animatedProgress = widget.progress;
  }

  @override
  void didUpdateWidget(covariant BottleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.progress != widget.progress) {
      setState(() {
        animatedProgress = widget.progress;
      });
    }
  }

  @override
  void dispose() {
    waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = min(360.0, constraints.maxHeight);
        final width = height * 0.56;

        return Center(
          child: Container(
            width: width + 42,
            height: height + 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.14),
                  theme.colorScheme.primary.withOpacity(0.02),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.16),
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(width, height),
                        painter: BottleOutlinePainter(theme: theme),
                      ),
                      ClipPath(
                        clipper: BottleClipper(),
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(end: animatedProgress),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                            builder: (context, progressValue, child) {
                              return AnimatedBuilder(
                                animation: waveController,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: WavePainter(
                                      progress: progressValue,
                                      wavePhase: waveController.value,
                                      theme: theme,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(widget.progress * 100).toInt()}%',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${widget.consumed} ml / ${widget.goal} ml',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final ThemeData theme;

  WavePainter({
    required this.progress,
    required this.wavePhase,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.colorScheme.secondary.withOpacity(0.75),
        theme.colorScheme.primary.withOpacity(0.92),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    final waterHeight = size.height * (1 - progress);

    final path = Path()..moveTo(0, size.height);
    final highlightPath = Path()..moveTo(0, size.height);

    for (double i = 0; i <= size.width; i++) {
      final y = waterHeight +
          sin((i / size.width * 2 * pi) + (wavePhase * 2 * pi)) * 6;
      final highlightY = waterHeight - 5 +
          sin((i / size.width * 2 * pi) + (wavePhase * 2 * pi) + 0.8) * 4;

      path.lineTo(i, y);
      highlightPath.lineTo(i, highlightY);
    }

    path
      ..lineTo(size.width, size.height)
      ..close();

    highlightPath
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

class BottleOutlinePainter extends CustomPainter {
  final ThemeData theme;

  BottleOutlinePainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final glassPaint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final glossPaint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final path = _bottlePath(size);

    canvas.drawShadow(
      path,
      theme.colorScheme.primary.withOpacity(0.20),
      20,
      false,
    );
    canvas.drawPath(path, glassPaint);
    canvas.drawPath(path, strokePaint);

    final glossPath = Path()
      ..moveTo(size.width * 0.33, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.48,
        size.width * 0.27,
        size.height * 0.80,
      );

    canvas.drawPath(glossPath, glossPaint);
  }

  Path _bottlePath(Size size) {
    final path = Path();
    final center = size.width / 2;
    final neckWidth = size.width * 0.42;
    final bodyTop = size.height * 0.22;

    path.moveTo(size.width * 0.18, size.height);
    path.quadraticBezierTo(
      size.width * 0.02,
      size.height * 0.65,
      size.width * 0.28,
      bodyTop,
    );
    path.lineTo(center - neckWidth / 2, bodyTop);
    path.lineTo(center - neckWidth / 2, size.height * 0.05);
    path.lineTo(center + neckWidth / 2, size.height * 0.05);
    path.lineTo(center + neckWidth / 2, bodyTop);
    path.lineTo(size.width * 0.72, bodyTop);
    path.quadraticBezierTo(
      size.width * 0.98,
      size.height * 0.65,
      size.width * 0.82,
      size.height,
    );
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant BottleOutlinePainter oldDelegate) => false;
}

class BottleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final center = size.width / 2;
    final neckWidth = size.width * 0.42;
    final bodyTop = size.height * 0.22;

    path.moveTo(size.width * 0.18, size.height);
    path.quadraticBezierTo(
      size.width * 0.02,
      size.height * 0.65,
      size.width * 0.28,
      bodyTop,
    );
    path.lineTo(center - neckWidth / 2, bodyTop);
    path.lineTo(center - neckWidth / 2, size.height * 0.05);
    path.lineTo(center + neckWidth / 2, size.height * 0.05);
    path.lineTo(center + neckWidth / 2, bodyTop);
    path.lineTo(size.width * 0.72, bodyTop);
    path.quadraticBezierTo(
      size.width * 0.98,
      size.height * 0.65,
      size.width * 0.82,
      size.height,
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
