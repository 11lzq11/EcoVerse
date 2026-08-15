import 'dart:math' as math;
import 'package:flame/components.dart';
import '../../ecoverse_game.dart';

class PlayerController extends PositionComponent {
  final EcoVerseGame game;
  final Vector2 _velocity = Vector2.zero();
  static const double gravity = -20.0;
  static const double jumpForce = 8.0;
  static const double moveSpeed = 10.0;

  PlayerController({required Vector2 position, required this.game})
      : super(position: position);

  bool isInRange(int x, int z, double range) {
    final dx = position.x - x.toDouble();
    final dz = position.y - z.toDouble();
    return math.sqrt(dx * dx + dz * dz) <= range;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _velocity.y += gravity * dt;
    position += _velocity * dt;

    if (position.y < 10) {
      position = Vector2(position.x, 10.0);
      _velocity.y = 0;
    }
  }

  void move(Vector2 direction) {
    _velocity.x = direction.x * moveSpeed;
    _velocity.y = direction.y * moveSpeed;
  }

  void jump() {
    if (position.y <= 10.1) {
      _velocity.y = jumpForce;
    }
  }
}
