import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_bubble_pop/bubble_game.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';

class Bubble extends PositionComponent 
    with TapCallbacks, HasGameReference<BubbleGame> implements OpacityProvider {
  final VoidCallback onPopped;
  final double lifespan;
  bool _isPopped = false;
  double _timeAlive = 0;
  final Random _random = Random();
  Component? _bubbleContent;
  Component? _popAnimation;
  
  // Implementing OpacityProvider correctly
  double _opacity = 1.0;
  
  @override
  double get opacity => _opacity;
  
  @override
  set opacity(double value) {
    _opacity = value.clamp(0.0, 1.0);
  }
  
  Bubble({
    required Vector2 position,
    required Vector2 size,
    required this.lifespan,
    required this.onPopped,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.center,
  );
  
  @override
  Future<void> onLoad() async {
    try {
      // Correct the SVG paths by removing the "assets/" prefix
      // Flame automatically looks in the assets folder
      final String svgPath = _random.nextBool() 
        ? 'images/musician.svg' 
        : 'images/forecaster.svg';
      
      final svg = await Svg.load(svgPath);
      _bubbleContent = SvgComponent(
        svg: svg,
        position: Vector2.zero(),
        size: size,
      );
      add(_bubbleContent!);
    } catch (e) {
      // Try loading the bubble.png image as a fallback
      try {
        _bubbleContent = SpriteComponent(
          sprite: await game.loadSprite('bubble.png'),
          position: Vector2.zero(),
          size: size,
        );
        add(_bubbleContent!);
      } catch (e) {
        // Final fallback to a colored circle with a gradient
        _bubbleContent = CircleComponent(
          radius: size.x / 2,
          paint: Paint()
            ..shader = RadialGradient(
              colors: [
                Colors.lightBlue.shade300,
                Colors.blue.shade600,
              ],
              stops: const [0.0, 1.0],
            ).createShader(Rect.fromCircle(
              center: Offset(size.x / 2, size.y / 2),
              radius: size.x / 2,
            ))
        );
        add(_bubbleContent!);
      }
    }
    
    // Add pulsating animation
    add(
      ScaleEffect.by(
        Vector2.all(1.1),
        EffectController(
          duration: 0.5,
          reverseDuration: 0.5,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
    
    // Preload the explosion SVG
    try {
      await Svg.load('images/pop.svg');
    } catch (e) {
      // SVG not available, we'll use the fallback
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (_isPopped) return;
    
    _timeAlive += dt;
    if (_timeAlive >= lifespan) {
      removeFromParent();
    }
  }
  
  // Create combined explosion effect with both SVG and particles
  void _createCombinedExplosionEffect() {
    // Always create the particle explosion for a more dramatic effect
    _createParticleExplosion();
    
    // Try to add the SVG explosion on top
    _addSvgExplosion();
  }
  
  // Add the SVG explosion
  void _addSvgExplosion() {
    try {
      // Try to use the pop.svg if it's been downloaded and added to assets
      Svg.load('images/pop.svg').then((svg) {
        _popAnimation = SvgComponent(
          svg: svg,
          position: size / 2,
          size: size * 1.8, // Make it larger
          anchor: Anchor.center,
        );
        add(_popAnimation!);
        
        // Add a scale and rotate effect
        _popAnimation!.add(
          SequenceEffect([
            ScaleEffect.by(
              Vector2.all(1.3),
              EffectController(
                duration: 0.2,
                curve: Curves.easeOut,
              ),
            ),
            OpacityEffect.fadeOut(
              EffectController(duration: 0.2),
            ),
          ]),
        );
      }).catchError((_) {
        // If SVG loading fails, we'll still have the particle explosion
      });
    } catch (e) {
      // If any error occurs, the particle explosion will still show
    }
  }
  
  // Create particle explosion
  void _createParticleExplosion() {
    // Create a particle-like explosion effect
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
    ];
    
    // Create 8 particles in a circle
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4; // 8 directions
      final color = colors[i % colors.length];
      
      final particle = CircleComponent(
        radius: size.x / 6,
        position: size / 2,
        anchor: Anchor.center,
        paint: Paint()..color = color,
      );
      
      add(particle);
      
      // Add movement and fade effect
      particle.add(
        MoveEffect.by(
          Vector2(cos(angle), sin(angle)) * size.x,
          EffectController(
            duration: 0.3,
            curve: Curves.easeOut,
          ),
        ),
      );
      
      if (particle is OpacityProvider) {
        particle.add(
          OpacityEffect.fadeOut(
            EffectController(
              duration: 0.3,
            ),
          ),
        );
      }
    }
    
    // Add a central flash
    final flash = CircleComponent(
      radius: size.x / 2,
      position: size / 2,
      anchor: Anchor.center,
      paint: Paint()..color = Colors.white.withOpacity(0.8),
    );
    
    add(flash);
    
    flash.add(
      SequenceEffect([
        ScaleEffect.by(
          Vector2.all(1.5),
          EffectController(
            duration: 0.1,
            curve: Curves.easeOut,
          ),
        ),
        OpacityEffect.fadeOut(
          EffectController(duration: 0.2),
        ),
      ]),
    );
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    if (_isPopped) return;
    
    _isPopped = true;
    onPopped();
    
    // Remove the content
    if (_bubbleContent != null) {
      if (_bubbleContent is OpacityProvider) {
        _bubbleContent!.add(
          OpacityEffect.fadeOut(
            EffectController(duration: 0.2),
          ),
        );
      } else {
        // Just remove it immediately if it doesn't support opacity
        _bubbleContent!.removeFromParent();
      }
    }
    
    // Add the combined explosion effect (both SVG and particles)
    _createCombinedExplosionEffect();
    
    // Fade out the entire bubble
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.5), // Longer duration to see the full animation
        onComplete: () => removeFromParent(),
      ),
    );
  }
}