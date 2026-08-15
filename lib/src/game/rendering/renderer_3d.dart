import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:vector_math/vector_math_64.dart';
import '../world/voxel_world.dart';

class Renderer3D {
  final VoxelWorld world;
  final CameraComponent camera;

  Renderer3D(this.world, this.camera);

  Ray screenPositionToRay(Vector2 screenPos) {
    final aspectRatio = camera.viewfinder.viewportSize.x / camera.viewfinder.viewportSize.y;
    final fov = camera.viewfinder.fov;
    final ndcX = (2.0 * screenPos.x / camera.viewfinder.viewportSize.x) - 1.0;
    final ndcY = 1.0 - (2.0 * screenPos.y / camera.viewfinder.viewportSize.y);

    final floatX = ndcX * math.tan(fov * 0.5) * aspectRatio;
    final floatY = ndcY * math.tan(fov * 0.5);

    final forward = camera.transform.matrix.getDirection();
    final right = Vector3(-forward.z, 0, forward.x).normalized();
    final up = Vector3(0, 1, 0);

    final direction = (forward + right * floatX + up * floatY).normalized();
    return Ray.origin(camera.worldToScreen(camera.position), direction);
  }

  Vector3 getSunDirection() {
    return Vector3(1, 1, -1).normalized();
  }
}