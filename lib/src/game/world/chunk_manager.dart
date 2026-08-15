import 'dart:async';
import 'package:vector_math/vector_math_64.dart';
import 'voxel_world.dart';

/// Manages chunk loading/unloading around the player
class ChunkManager {
  final VoxelWorld world;
  final int renderDistance;
  
  final Map<IntVector3, ChunkData> _chunks = {};
  final Set<IntVector3> _loadedChunks = {};
  
  ChunkManager({
    required this.world,
    required this.renderDistance,
  });
  
  /// Get all loaded chunks
  Map<IntVector3, ChunkData> get chunks => Map.unmodifiable(_chunks);
  
  /// Update chunks based on player position
  void update(Vector3 playerPos) {
    final currentChunkX = (playerPos.x / world.chunkSize).floor();
    final currentChunkZ = (playerPos.z / world.chunkSize).floor();
    
    // Determine which chunks should be loaded
    final desiredChunks = <IntVector3>{};
    for (var dx = -renderDistance; dx <= renderDistance; dx++) {
      for (var dz = -renderDistance; dz <= renderDistance; dz++) {
        desiredChunks.add(IntVector3(currentChunkX + dx, 0, currentChunkZ + dz));
      }
    }
    
    // Unload chunks outside render distance
    final chunksToRemove = _loadedChunks.where((chunk) => !desiredChunks.contains(chunk)).toList();
    for (final chunk in chunksToRemove) {
      _unloadChunk(chunk);
    }
    
    // Load new chunks
    for (final chunk in desiredChunks) {
      if (!_loadedChunks.contains(chunk)) {
        _loadChunk(chunk);
      }
    }
  }
  
  void _loadChunk(IntVector3 chunkPos) {
    final data = world.getOrCreateChunk(chunkPos);
    _chunks[chunkPos] = data;
    _loadedChunks.add(chunkPos);
  }
  
  void _unloadChunk(IntVector3 chunkPos) {
    _chunks.remove(chunkPos);
    _loadedChunks.remove(chunkPos);
  }
  
  /// Check if chunk is loaded
  bool isLoading(IntVector3 pos) => _loadedChunks.contains(pos);
  
  /// Get chunk at position
  ChunkData? getChunk(IntVector3 pos) => _chunks[pos];
}
