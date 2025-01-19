import 'package:flutter/material.dart';

class PulsatingMarker extends StatefulWidget {
  final double size;
  final Color color;

  const PulsatingMarker({
    Key? key,
    this.size = 20,
    this.color = Colors.red,
  }) : super(key: key);

  @override
  State<PulsatingMarker> createState() => _PulsatingMarkerState();
}

class _PulsatingMarkerState extends State<PulsatingMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.size * 2 * _animation.value,
              height: widget.size * 2 * _animation.value,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red,
                  width: 2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
