import 'package:flame/components.dart';
import 'package:vector_math/vector_math_64.dart';
import '../world/voxel_world.dart';

class Renderer3D {
  final CameraComponent camera;
  final VoxelWorld world;

  Renderer3D(this.camera, this.world);

  void render(Canvas canvas) {}

  Ray screenPositionToRay(Vector2 pos) {
    return Ray.originDirection(camera.viewfinder.position, Vector3(0, 0, -1));
  }

  Vector3 getSunDirection() => Vector3(1, 1, -1).normalized();
}
