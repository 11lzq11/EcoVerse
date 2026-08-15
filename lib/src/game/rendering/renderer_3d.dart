import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:vector_math/vector_math_64.dart';
import '../world/voxel_world.dart';

class Renderer3D {
  final VoxelWorld world;
  final CameraComponent camera;

  Renderer3D(this.world, this.camera);

  Ray screenPositionToRay(Vector2 screenPos, Vector2 screenSize) {
    final aspectRatio = screenSize.x / screenSize.y;
    final fov = 0.7853981633974483; // ~45 degrees in radians
    final ndcX = (2.0 * screenPos.x / screenSize.x) - 1.0;
    final ndcY = 1.0 - (2.0 * screenPos.y / screenSize.y);

    final floatX = ndcX * math.tan(fov * 0.5) * aspectRatio;
    final floatY = ndcY * math.tan(fov * 0.5);

    final forward = camera.transform.matrix.getDirection();
    final right = Vector3(-forward.z, 0, forward.x).normalized();
    final up = Vector3(0, 1, 0);

    final direction = (forward + right * floatX + up * floatY).normalized();
    return Ray.origin(Vector3.zero(), direction);
  }

  Vector3 getSunDirection() {
    return Vector3(1, 1, -1).normalized();
  }
}
