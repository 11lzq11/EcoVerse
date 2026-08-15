import 'package:flame/components.dart';
import 'renderer_3d.dart';
import '../world/voxel_world.dart';

class WorldRenderer extends Component {
  final VoxelWorld world;
  final Renderer3D renderer;

  WorldRenderer({required this.world, required this.renderer});

  @override
  void render(Canvas canvas) {
    // TODO: Implement voxel rendering
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}