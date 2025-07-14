import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.08, end: 0.15).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: BlackKing());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
