import 'dart:async';
import 'package:flame/components.dart';
import 'package:vector_math/vector_math_64.dart';
import 'voxel_world.dart';

class ChunkManager extends Component {
  final VoxelWorld _world;
  final int renderDistance;
  final Set<Vector2i> _loadedChunks = {};
  
  ChunkManager(this._world, {this.renderDistance = 4});
  
  void updateChunks(Vector3 playerPos) {
    final int playerChunkX = (playerPos.x / VoxelWorld.CHUNK_SIZE).floor();
    final int playerChunkZ = (playerPos.z / VoxelWorld.CHUNK_SIZE).floor();
    
    final Vector2i playerChunk = Vector2i(playerChunkX, playerChunkZ);
    
    // Load chunks in range
    for (int x = playerChunkX - renderDistance; x <= playerChunkX + renderDistance; x++) {
      for (int z = playerChunkZ - renderDistance; z <= playerChunkZ + renderDistance; z++) {
        final Vector2i chunkKey = Vector2i(x, z);
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
