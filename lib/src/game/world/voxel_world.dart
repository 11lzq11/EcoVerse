import 'dart:collection';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:vector_math/vector_math_64.dart';
import '../noise/perlin_noise.dart';
import 'voxel_types.dart';

class VoxelWorld {
  static const int CHUNK_SIZE = 16;
  static const int WORLD_HEIGHT = 64;
  
  final Map<Vector3i, VoxelType> _voxels = HashMap<Vector3i, VoxelType>();
  final Map<String, ChunkData> _chunks = {};
  final PerlinNoise _noise;
  
  VoxelWorld({int seed = 42}) : _noise = PerlinNoise(seed);
  
  Vector3i get playerPosition => Vector3i(0, WORLD_HEIGHT ~/ 2, 0);
  
  void generateTerrain() {
    for (int x = -50; x < 50; x++) {
      for (int z = -50; z < 50; z++) {
        final double height = _noise.octaveNoise(x * 0.05) * 20 + 
                              _noise.octaveNoise(z * 0.05) * 20 + 30;
        final int y = height.floor();
        
        for (int h = 0; h <= y && h < WORLD_HEIGHT; h++) {
          VoxelType type;
          if (h == y) {
            type = VoxelType.grass;
          } else if (h > y - 4) {
            type = VoxelType.dirt;
          } else {
            type = VoxelType.stone;
          }
          setVoxel(x, h, z, type);
        }
        
        // Add water in low areas
        if (y < 20) {
          for (int h = y + 1; h <= 20 && h < WORLD_HEIGHT; h++) {
            setVoxel(x, h, z, VoxelType.water);
          }
        }
      }
    }
  }
  
  void setVoxel(int x, int y, int z, VoxelType type) {
    if (y < 0 || y >= WORLD_HEIGHT) return;
    _voxels[Vector3i(x, y, z)] = type;
    _invalidateChunk(x, z);
  }
  
  VoxelType? getVoxel(int x, int y, int z) {
    if (y < 0 || y >= WORLD_HEIGHT) return null;
    return _voxels[Vector3i(x, y, z)];
  }
  
  bool isSolid(int x, int y, int z) {
    final type = getVoxel(x, y, z);
    return type != null && blockProperties[type!]?.isSolid ?? true;
  }
  
  Vector3 getPlayerHeight() {
    final px = playerPosition.x;
    final pz = playerPosition.z;
    
    for (int y = WORLD_HEIGHT - 1; y >= 0; y--) {
      if (isSolid(px, y, pz)) {
        return Vector3(px.toDouble(), y + 2.0, pz.toDouble());
      }
    }
    return Vector3(px.toDouble(), WORLD_HEIGHT.toDouble() / 2, pz.toDouble());
  }
  
  void invalidateChunk(int x, int z) {
    final cx = (x / CHUNK_SIZE).floor();
    final cz = (z / CHUNK_SIZE).floor();
    _chunks.remove('${cx}_$cz');
  }
  
  ChunkData? getChunk(int cx, int cz) {
    final key = '$cx_$cz';
    if (!_chunks.containsKey(key)) {
      _chunks[key] = _generateChunk(cx, cz);
    }
    return _chunks[key];
  }
  
  ChunkData _generateChunk(int cx, int cz) {
    return ChunkData(
      cx: cx,
      cz: cz,
      voxels: {},
    );
  }
  
  int get chunkCount => _chunks.length;
}

class ChunkData {
  final int cx, cz;
  final Map<Vector3i, VoxelType> voxels;
  
  ChunkData({required this.cx, required this.cz, required this.voxels});
}

const Map<VoxelType, BlockProperties> blockProperties = {};
