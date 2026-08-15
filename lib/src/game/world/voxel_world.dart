import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';
import 'voxel_types.dart';

/// Voxel world that stores block data
class VoxelWorld {
  final int worldSize;
  final int chunkSize;
  final int seed;
  final Map<IntVector3, VoxelType> _blocks = {};
  final PerlinNoise _noise = PerlinNoise();
  
  // Chunk metadata
  final Map<IntVector3, ChunkData> _chunks = {};
  
  // Change listeners
  final List<void Function(IntVector3 pos, VoxelType oldType, VoxelType newType)> _listeners = [];
  
  VoxelWorld({
    required this.worldSize,
    required this.chunkSize,
    required this.seed,
  });
  
  /// Get all chunks
  Map<IntVector3, ChunkData> get chunks => _chunks;
  
  /// Get block at position
  VoxelType getBlock(IntVector3 pos) {
    if (!_isValidPosition(pos)) return VoxelType.air;
    return _blocks[pos] ?? VoxelType.air;
  }
  
  /// Set block at position
  void setBlock(IntVector3 pos, VoxelType type) {
    if (!_isValidPosition(pos)) return;
    
    final oldType = _blocks[pos] ?? VoxelType.air;
    if (oldType == type) return;
    
    _blocks[pos] = type;
    
    // Notify listeners
    for (final listener in _listeners) {
      listener(pos, oldType, type);
    }
    
    // Update chunk mesh
    final chunkPos = _posToChunk(pos);
    markChunkDirty(chunkPos);
    
    // Update adjacent chunks
    _updateAdjacentChunks(chunkPos);
  }
  
  /// Break a block
  void breakBlock(IntVector3 pos) {
    setBlock(pos, VoxelType.air);
  }
  
  /// Place a block
  void placeBlock(IntVector3 pos, VoxelType type) {
    if (_blocks[pos] != VoxelType.air) return;
    setBlock(pos, type);
  }
  
  /// Check if position is valid (within world bounds)
  bool _isValidPosition(IntVector3 pos) {
    return pos.x >= 0 && pos.x < worldSize &&
           pos.y >= 0 && pos.y < 256 &&
           pos.z >= 0 && pos.z < worldSize;
  }
  
  /// Convert world position to chunk position
  IntVector3 _posToChunk(IntVector3 pos) {
    return IntVector3(
      (pos.x / chunkSize).floor(),
      (pos.y / chunkSize).floor(),
      (pos.z / chunkSize).floor(),
    );
  }
  
  /// Mark chunk as dirty (needs mesh rebuild)
  void markChunkDirty(IntVector3 chunkPos) {
    _chunks[chunkPos]?.dirty = true;
  }
  
  /// Update adjacent chunks
  void _updateAdjacentChunks(IntVector3 chunkPos) {
    final dx = [0, 1, -1, 0, 0, 0];
    final dz = [0, 0, 0, 1, -1, 0];
    final dy = [0, 0, 0, 0, 0, 1];
    
    // Only need to update neighbors on X and Z axes
    for (var i = 0; i < 4; i++) {
      final neighbor = IntVector3(
        chunkPos.x + dx[i],
        chunkPos.y,
        chunkPos.z + dz[i],
      );
      markChunkDirty(neighbor);
    }
  }
  
  /// Register a change listener
  void addListener(void Function(IntVector3 pos, VoxelType oldType, VoxelType newType) listener) {
    _listeners.add(listener);
  }
  
  /// Unregister a change listener
  void removeListener(void Function(IntVector3 pos, VoxelType oldType, VoxelType newType) listener) {
    _listeners.remove(listener);
  }
  
  /// Get chunk data or create it
  ChunkData getOrCreateChunk(IntVector3 pos) {
    return _chunks.putIfAbsent(pos, () => ChunkData(chunkPos: pos, chunkSize: chunkSize));
  }
  
  /// Get chunk data
  ChunkData? getChunk(IntVector3 pos) => _chunks[pos];
  
  /// Generate terrain heightmap value
  double getHeight(int x, int z) {
    final scale = 0.01;
    final baseHeight = 64.0;
    final mountainFactor = 30.0;
    
    // Layer multiple noise functions for realistic terrain
    double height = baseHeight;
    height += _noise.noise2D(x * scale, z * scale) * mountainFactor;
    height += _noise.noise2D(x * scale * 2, z * scale * 2) * (mountainFactor * 0.5);
    height += _noise.noise2D(x * scale * 4, z * scale * 4) * (mountainFactor * 0.25);
    
    return height;
  }
  
  /// Generate biome at position
  Biome getBiome(int x, int z) {
    final temperature = _noise.noise2D(x * 0.002, z * 0.002);
    final moisture = _noise.noise2D(x * 0.003 + 100, z * 0.003 + 100);
    
    if (temperature > 0.5 && moisture < 0.3) return Biome.desert;
    if (temperature > 0.5 && moisture > 0.5) return Biome.jungle;
    if (temperature < -0.3) return Biome.snowy;
    if (moisture > 0.3) return Biome.forest;
    return Biome.plains;
  }
  
  /// Determine block type at position based on height and biome
  VoxelType getBlockAtHeight(int x, int y, int z) {
    final height = getHeight(x, z).round();
    final biome = getBiome(x, z);
    
    // Bedrock at bottom
    if (y == 0) return VoxelType.bedrock;
    
    // Lava at very low levels
    if (y < 10 && y > 0) {
      return _noise.noise1D(x * 0.1, z * 0.1) > 0.3 ? VoxelType.lava : VoxelType.air;
    }
    
    // Determine block by height
    if (y > height + 5) {
      if (biome == Biome.snowy) return VoxelType.snow;
      return VoxelType.air;
    }
    
    if (y > height) {
      if (biome == Biome.desert) return VoxelType.sand;
      return VoxelType.air;
    }
    
    if (y == height) {
      switch (biome) {
        case Biome.desert: return VoxelType.sand;
        case Biome.jungle: return VoxelType.grass;
        case Biome.snowy: return VoxelType.snow;
        case Biome.forest: return VoxelType.grass;
        default: return VoxelType.grass;
      }
    }
    
    if (y > height - 4) {
      if (biome == Biome.desert) return VoxelType.sand;
      return VoxelType.dirt;
    }
    
    // Stone layer with ores
    return _generateOre(y, biome);
  }
  
  /// Generate ore distribution
  VoxelType _generateOre(int y, Biome biome) {
    final rand = _noise.noise2D(y * 0.1, 0.0);
    
    if (y < 16 && rand > 0.7) return VoxelType.diamondOre;
    if (y < 32 && rand > 0.6) return VoxelType.goldOre;
    if (y < 50 && rand > 0.5) return VoxelType.ironOre;
    if (rand > 0.4) return VoxelType.coalOre;
    
    return VoxelType.stone;
  }
  
  /// Generate trees at surface positions
  void _generateTree(int x, int z) {
    final height = getHeight(x, z).round();
    if (height <= 60 || height >= 90) return;
    
    final biome = getBiome(x, z);
    if (biome != Biome.plains && biome != Biome.forest) return;
    
    // Random chance to generate tree
    if (_noise.noise2D(x * 0.5, z * 0.5) < 0.3) return;
    
    final treeHeight = 4 + (_noise.noise1D(x, z) * 3).round().abs();
    
    // Trunk
    for (var i = 0; i < treeHeight; i++) {
      setBlock(IntVector3(x, height + i + 1, z), VoxelType.wood);
    }
    
    // Leaves
    final leafStart = height + treeHeight - 2;
    for (var dy = 0; dy < 3; dy++) {
      final radius = dy == 2 ? 1 : 2;
      for (var dx = -radius; dx <= radius; dx++) {
        for (var dz = -radius; dz <= radius; dz++) {
          if (dx == 0 && dz == 0 && dy < 2) continue;
          setBlock(
            IntVector3(x + dx, leafStart + dy, z + dz),
            VoxelType.leaves,
          );
        }
      }
    }
  }
  
  /// Generate structures (houses, caves, etc.)
  Future<void> generateStructures() async {
    // Generate random houses
    for (var i = 0; i < 20; i++) {
      final x = (math.Random().nextDouble() * worldSize * 0.8 + worldSize * 0.1).toInt();
      final z = (math.Random().nextDouble() * worldSize * 0.8 + worldSize * 0.1).toInt();
      final height = getHeight(x, z).round();
      
      if (height > 60 && height < 90) {
        await _generateHouse(x, height, z);
      }
    }
  }
  
  /// Generate a simple house structure
  Future<void> _generateHouse(int x, int y, int z) async {
    const width = 7;
    const depth = 7;
    const height = 5;
    
    // Floor
    for (var dx = 0; dx < width; dx++) {
      for (var dz = 0; dz < depth; dz++) {
        setBlock(IntVector3(x + dx, y, z + dz), VoxelType.plank);
      }
    }
    
    // Walls
    for (var dy = 1; dy <= height; dy++) {
      for (var dx = 0; dx < width; dx++) {
        for (var dz = 0; dz < depth; dz++) {
          // Leave openings for doors and windows
          final isWall = dx == 0 || dx == width - 1 || dz == 0 || dz == depth - 1;
          final isDoor = dx == 3 && dz == 0 && dy < 3;
          final isWindow = (dy == 3 || dy == 4) && ((dx == 0 || dx == width - 1) || (dz == 0 || dz == depth - 1));
          
          if (isWall && !isDoor && !isWindow) {
            setBlock(IntVector3(x + dx, y + dy, z + dz), VoxelType.stone);
          }
        }
      }
    }
    
    // Roof
    for (var dx = -1; dx <= width; dx++) {
      for (var dz = -1; dz <= depth; dz++) {
        setBlock(IntVector3(x + dx, y + height + 1, z + dz), VoxelType.cobblestone);
      }
    }
    
    // Door
    setBlock(IntVector3(x + 3, y + 1, z), VoxelType.door);
    setBlock(IntVector3(x + 3, y + 2, z), VoxelType.door);
  }
  
  /// Generate the complete world terrain
  Future<void> generateTerrain() async {
    // Generate in chunks for better performance
    final totalChunks = (worldSize / chunkSize).ceil();
    var completed = 0;
    
    for (var cx = 0; cx < totalChunks; cx++) {
      for (var cz = 0; cz < totalChunks; cz++) {
        // Process chunk
        for (var lx = 0; lx < chunkSize; lx++) {
          for (var lz = 0; lz < chunkSize; lz++) {
            final wx = cx * chunkSize + lx;
            final wz = cz * chunkSize + lz;
            
            for (var wy = 0; wy < 256; wy++) {
              final blockType = getBlockAtHeight(wx, wy, wz);
              if (blockType != VoxelType.air) {
                setBlock(IntVector3(wx, wy, wz), blockType);
              }
            }
            
            // Generate trees
            if (wy == 0) {
              _generateTree(wx, wz);
            }
          }
        }
        
        completed++;
        if (completed % 10 == 0) {
          // Yield control to allow UI updates
          await Future.delayed(Duration.zero);
        }
      }
    }
    
    // Generate surface structures
    await generateStructures();
  }
  
  /// Raycast through the world
  RaycastResult? raycast(Vector3 origin, Vector3 direction, {double maxDistance = 10.0}) {
    final step = 0.05;
    var pos = origin.clone();
    var lastPos = pos.clone();
    
    for (var t = 0.0; t < maxDistance; t += step) {
      pos = origin + direction * t;
      final blockPos = pos.floorToInt32();
      
      if (getBlock(blockPos) != VoxelType.air) {
        // Calculate face normal
        final prevBlockPos = lastPos.floorToInt32();
        final normal = (blockPos - prevBlockPos).normalized().castToDouble();
        
        return RaycastResult(
          position: blockPos,
          faceNormal: normal,
          distance: t,
        );
      }
      
      lastPos = pos.clone();
    }
    
    return null;
  }
  
  /// Serialize world data for saving
  List<Map<String, dynamic>> serialize() {
    final blocks = <Map<String, dynamic>>[];
    
    for (final entry in _blocks.entries) {
      if (entry.value != VoxelType.air) {
        blocks.add({
          'x': entry.key.x,
          'y': entry.key.y,
          'z': entry.key.z,
          'type': entry.value.id,
        });
      }
    }
    
    return blocks;
  }
  
  /// Deserialize world data from save
  Future<void> deserialize(List<Map<String, dynamic>> data) async {
    _blocks.clear();
    
    for (final entry in data) {
      final pos = IntVector3(entry['x'] as int, entry['y'] as int, entry['z'] as int);
      final type = VoxelType.values[entry['type'] as int];
      _blocks[pos] = type;
    }
  }
  
  /// Clear all blocks
  void clear() {
    _blocks.clear();
    _chunks.clear();
  }
  
  /// Get number of loaded blocks
  int get blockCount => _blocks.length;
}

/// Biome types
enum Biome { plains, forest, desert, jungle, snowy }

/// Chunk data structure
class ChunkData {
  final IntVector3 chunkPos;
  final int chunkSize;
  bool dirty;
  
  /// Mesh data (populated by renderer)
  MeshData? mesh;
  
  ChunkData({
    required this.chunkPos,
    required this.chunkSize,
    this.dirty = true,
    this.mesh,
  });
}

/// Mesh data for GPU rendering
class MeshData {
  final List<Vector3> vertices;
  final List<int> indices;
  final List<Color> colors;
  final List<Vector3> normals;
  
  MeshData({
    required this.vertices,
    required this.indices,
    required this.colors,
    required this.normals,
  });
}
