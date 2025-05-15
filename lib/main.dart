import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'bubble_game.dart';

void main() {
  runApp(
    const GameWidget<BubbleGame>.controlled(
      gameFactory: BubbleGame.new,
    ),
  );
}