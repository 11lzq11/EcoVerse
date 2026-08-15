import 'dart:typed_data';
import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import '../ecoverse_game.dart';
import '../world/voxel_types.dart';
import '../world/voxel_world.dart';

/// Renderer that draws the voxel world using custom painters
class WorldRenderer extends PositionComponent {
  final EcoVerseGame game;
  
  WorldRenderer(this.game);
  
  @override
  void render(Canvas canvas) {
    // Render world blocks using custom drawing
    _renderWorld(canvas);
  }
  
  void _renderWorld(Canvas canvas) {
    // This would be implemented with custom Flame rendering
    // For now, we use a simple approach with the engine's painter
    
    // Draw sky
    final skyColor = game.renderer.getSkyColor();
    canvas.drawColor(skyColor.toFlutterColor(), Paint.blendMode);
  }
}
