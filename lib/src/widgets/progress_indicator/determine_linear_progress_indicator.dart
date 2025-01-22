import 'package:flutter/material.dart';

class DetermineLinearProgressIndicator extends StatelessWidget {
  final double progress;

  const DetermineLinearProgressIndicator({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        width: 200,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.brown.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.brown),
                minHeight: 52,
              ),
            ),
            Positioned(
              child: Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
