import 'package:flame/components.dart';
import 'voxel_world.dart';

class ChunkManager extends Component {
  final VoxelWorld world;
  final int renderDistance;

  ChunkManager(this.world, {this.renderDistance = 4});

  void updateChunks(Vector2 pos) {
    // chunk loading logic placeholder
  }
}
