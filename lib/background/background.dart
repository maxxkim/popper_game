import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Background extends Component with HasGameReference {
  final Paint _paint;
  
  Background({Color color = const Color(0xFF2A80B9)})
      : _paint = Paint()..color = color;
  
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