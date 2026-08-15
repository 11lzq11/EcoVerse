// Player controller placeholder
import 'package:flame/components.dart';
import 'package:vector_math/vector_math_64.dart';
import '../world/voxel_world.dart';
import '../ecoverse_game.dart';

class PlayerController extends PositionComponent {
  final EcoVerseGame game;
  final Vector3 _velocity = Vector3.zero();
  static const double gravity = -20.0;
  static const double jumpForce = 8.0;
  static const double moveSpeed = 10.0;
  
  PlayerController({required Vector3 position, required this.game}) 
    : super(position: position.toVector2());
  
  bool isInRange(int x, int y, int z, double range) {
    final pos = world.position;
    final dx = pos.x - x;
    final dy = pos.y - y;
    final dz = pos.z - z;
    return (dx * dx + dy * dy + dz * dz).sqrt() <= range;
  }
  
  void update(double dt) {
    // Apply gravity
    _velocity.y += gravity * dt;
    
    // Update position
    position = (position + _velocity.toVector2() * dt);
    
    // Simple ground collision
    if (position.y < 10) {
      position = Vector2(position.x, 10.0);
      _velocity.y = 0;
    }
  }
  
  void move(Vector3 direction) {
    _velocity.x = direction.x * moveSpeed;
    _velocity.z = direction.z * moveSpeed;
  }
  
  void jump() {
    if (position.y <= 10.1) {
      _velocity.y = jumpForce;
    }
  }
}

extension Vector3Extension on Vector3 {
  Vector2 toVector2() => Vector2(x, y);
}

extension Vector2Extension on Vector2 {
  Vector3 toVector3([double z = 0]) => Vector3(x, y, z);
}
