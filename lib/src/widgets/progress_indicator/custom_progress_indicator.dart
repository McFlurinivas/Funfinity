import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              )
            ]),
        width: 60,
        height: 60,
        child: const CircularProgressIndicator(
          strokeWidth: 6,
          strokeCap: StrokeCap.round,
          color: Colors.brown,
        ),
      ),
    );
  }
}
