import 'package:flame/components.dart';

class ImageBackground extends SpriteComponent with HasGameReference {
  final String imagePath;
  
  ImageBackground({required this.imagePath}) : super(priority: -1);
  
  @override
  Future<void> onLoad() async {
    // Load the sprite
    sprite = await game.loadSprite(imagePath);
    
    // Scale the sprite to cover the game area
    size = game.size;
    
    // Set the anchor to the top-left
    anchor = Anchor.topLeft;
  }
}