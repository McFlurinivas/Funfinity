import 'package:flutter/material.dart';

class JumpingDotsLoadingIndicator extends StatefulWidget {
  final int numberOfDots;
  final Color color;
  final double dotSize;
  final Duration duration;

  const JumpingDotsLoadingIndicator({
    super.key,
    this.numberOfDots = 3,
    this.color = Colors.blue,
    this.dotSize = 10.0,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<JumpingDotsLoadingIndicator> createState() =>
      _JumpingDotsLoadingIndicatorState();
}

class _JumpingDotsLoadingIndicatorState
    extends State<JumpingDotsLoadingIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(widget.numberOfDots, (index) {
      return AnimationController(
        vsync: this,
        duration: widget.duration,
      )..repeat(reverse: true);
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: -10.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(
        Duration(milliseconds: i * 100),
        () => _controllers[i].repeat(reverse: true),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.numberOfDots, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Transform.translate(
                offset: Offset(0, _animations[index].value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: Dot(
                    color: widget.color,
                    size: widget.dotSize,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class Dot extends StatelessWidget {
  final Color color;
  final double size;

  const Dot({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
