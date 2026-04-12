import 'package:flutter/material.dart';
import 'dart:math';

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

  late AnimationController waveController;

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

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [

          Container(
            width: 120,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.blue,
                width: 3,
              ),
            ),
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              width: 120,
              height: 300,
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
                        ),
                      );

                    },
                  );

                },
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                "${(widget.progress * 100).toInt()}%",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text("${widget.consumed} ml / ${widget.goal} ml"),

            ],
          )

        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {

  final double progress;
  final double wavePhase;

  WavePainter({
    required this.progress,
    required this.wavePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.fill;

    double waterHeight = size.height * (1 - progress);

    final path = Path();

    path.moveTo(0, size.height);

    for (double i = 0; i <= size.width; i++) {

      double y = waterHeight +
          sin((i / size.width * 2 * pi) +
              (wavePhase * 2 * pi)) *
              6;

      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}