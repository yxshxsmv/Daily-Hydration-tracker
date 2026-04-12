import 'package:flutter/material.dart';

class BottleWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomCenter,
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

          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 120,
            height: 300 * progress,
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text("$consumed ml / $goal ml"),
            ],
          )
        ],
      ),
    );
  }
}