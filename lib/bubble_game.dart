import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_bubble_pop/background/background.dart';
import 'package:flame_bubble_pop/background/gradient_background.dart';
import 'package:flame_bubble_pop/background/image_background.dart';
import 'package:flame_bubble_pop/bubble.dart';
import 'package:flutter/material.dart';

enum BackgroundType {
  solid,
  gradient,
  image,
}

class BubbleGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  int score = 0;
  final Random _random = Random();
  double spawnCooldown = 0.5;
  double timeSinceLastSpawn = 0;
  late final TextComponent scoreComponent;
  
  final BackgroundType backgroundType;
  final Color bgColor;
  final List<Color> gradientColors;
  final String? backgroundImagePath;
  
  BubbleGame({
    this.backgroundType = BackgroundType.image,
    this.bgColor = const Color(0xFF87CEEB),
    this.gradientColors = const [Color(0xFF87CEEB), Color(0xFF1E90FF)],
    this.backgroundImagePath = 'background.png',
  });
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load image assets - only the necessary ones
    await images.loadAll([
      'pop.png',
      if (backgroundType == BackgroundType.image && backgroundImagePath != null) 
        backgroundImagePath!,
    ]);
    
    // Set up background
    switch (backgroundType) {
      case BackgroundType.solid:
        add(Background(color: bgColor));
        break;
      case BackgroundType.gradient:
        add(GradientBackground(colors: gradientColors));
        break;
      case BackgroundType.image:
        if (backgroundImagePath != null) {
          try {
            add(ImageBackground(imagePath: backgroundImagePath!));
          } catch (e) {
            // Fallback to gradient if image loading fails
            add(GradientBackground(colors: gradientColors));
          }
        } else {
          add(GradientBackground(colors: gradientColors));
        }
        break;
    }
    
    // Add score display
scoreComponent = TextComponent(
  text: 'Score: 0',
  position: Vector2(30, 120), // Moved from y=20 to y=60 to avoid clock overlay
  textRenderer: TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          blurRadius: 3,
          color: Colors.black,
          offset: Offset(1, 1),
        ),
      ],
    ),
  ),
  priority: 10,
);
    add(scoreComponent);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    timeSinceLastSpawn += dt;
    if (timeSinceLastSpawn >= spawnCooldown) {
      spawnBubble();
      timeSinceLastSpawn = 0;
      
      if (spawnCooldown > 0.1) {
        spawnCooldown -= 0.01;
      }
    }
    
    scoreComponent.text = 'Score: $score';
  }
  
  void spawnBubble() {
    final x = _random.nextDouble() * (size.x - 100);

    // Only spawn in the lower half of the screen
    final lowerHalfStart = size.y * 0.5; // Start from the middle of the screen
    final availableHeight = size.y * 0.4; // Use 40% of the screen height for spawning (avoiding the very bottom)

    final y = lowerHalfStart + (_random.nextDouble() * availableHeight);

    final bubbleSize = 50 + _random.nextDouble() * 50;

    add(
    Bubble(
      position: Vector2(x, y),
      size: Vector2.all(bubbleSize),
      lifespan: 2 + _random.nextDouble() * 2, // 2-4 seconds lifespan
      onPopped: () {
        score += (100 ~/ bubbleSize).round(); // Smaller bubbles = more points
      },
    ),
    );
  }
}