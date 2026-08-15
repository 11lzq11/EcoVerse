import 'dart:collection';
import 'package:flame/components.dart';
import '../noise/perlin_noise.dart';
import 'voxel_types.dart';

class VoxelWorld {
  static const int CHUNK_SIZE = 16;
  static const int WORLD_HEIGHT = 64;

  final PerlinNoise _noise;
  final int seed;
  final Map<Vector2, VoxelType> _voxels = HashMap<Vector2, VoxelType>();

  VoxelWorld({this.seed = 42}) : _noise = PerlinNoise(seed);

  Vector2 get playerPosition => Vector2(0, 0);

  void generateTerrain() {
    for (int x = -50; x < 50; x++) {
      for (int z = -50; z < 50; z++) {
        final double h = _noise.octaveNoise(x * 0.05) * 20 +
            _noise.octaveNoise(z * 0.05) * 20 + 30;
        final int y = h.floor();
        for (int i = 0; i <= y && i < WORLD_HEIGHT; i++) {
          final type = i == y ? VoxelType.grass : (i > y - 4 ? VoxelType.dirt : VoxelType.stone);
          _voxels[Vector2(x.toDouble(), z.toDouble())] = type;
        }
        if (y < 20) {
          for (int i = y + 1; i <= 20 && i < WORLD_HEIGHT; i++) {
            _voxels[Vector2(x.toDouble(), z.toDouble())] = VoxelType.water;
          }
        }
      }
    }
  }

  void setVoxel(int x, int y, int z, VoxelType type) {
    if (y >= 0 && y < WORLD_HEIGHT) {
      _voxels[Vector2(x.toDouble(), z.toDouble())] = type;
    }
  }

  VoxelType? getVoxel(int x, int y, int z) {
    if (y < 0 || y >= WORLD_HEIGHT) return null;
    return _voxels[Vector2(x.toDouble(), z.toDouble())];
  }

  bool isSolid(int x, int y, int z) {
    final type = getVoxel(x, y, z);
    return type != null && blockSolid[type] ?? true;
  }

  Vector2 getPlayerHeight() {
    final px = playerPosition.x;
    final pz = playerPosition.y;
    for (int y = WORLD_HEIGHT - 1; y >= 0; y--) {
      if (isSolid(px.floor(), y, pz.floor())) {
        return Vector2(px, (y + 2).toDouble());
      }
    }
    return Vector2(px, (WORLD_HEIGHT / 2).toDouble());
  }

  int get chunkCount => 0;
}
