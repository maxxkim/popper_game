import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GradientBackground extends Component with HasGameReference {
  final Paint _paint;
  
  GradientBackground({
    List<Color> colors = const [Color(0xFF87CEEB), Color(0xFF1E90FF)],
    List<double>? stops,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) : _paint = Paint() {
    _paint.shader = LinearGradient(
      colors: colors,
      stops: stops,
      begin: begin,
      end: end,
    ).createShader(Rect.largest);
  }
  
  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, game.size.x, game.size.y),
      _paint,
    );
  }
  
  @override
  int get priority => -1; // Draw behind everything else
}