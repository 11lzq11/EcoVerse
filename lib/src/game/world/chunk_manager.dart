import 'package:flame/components.dart';
import 'voxel_world.dart';

class ChunkManager extends Component {
  final VoxelWorld _world;
  final int renderDistance;
  final Set<Vector2> _loadedChunks = {};
  
  ChunkManager(this._world, {this.renderDistance = 4});
  
  void updateChunks(Vector2 playerPos) {
    final int playerChunkX = (playerPos.x / VoxelWorld.CHUNK_SIZE).floor();
    final int playerChunkZ = (playerPos.y / VoxelWorld.CHUNK_SIZE).floor();
    
    // Load chunks in range
    for (int x = playerChunkX - renderDistance; x <= playerChunkX + renderDistance; x++) {
      for (int z = playerChunkZ - renderDistance; z <= playerChunkZ + renderDistance; z++) {
        final Vector2 chunkKey = Vector2(x.toDouble(), z.toDouble());
        if (!_loadedChunks.contains(chunkKey)) {
          _loadedChunks.add(chunkKey);
          _world.getChunk(x, z);
        }
      }
    }
    
    // Unload far chunks
    _loadedChunks.removeWhere((key) {
      return (key.x - playerChunkX).abs() > renderDistance ||
             (key.y - playerChunkZ).abs() > renderDistance;
    });
  }
  
  int get loadedChunkCount => _loadedChunks.length;
}
