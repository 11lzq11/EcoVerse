import 'package:flame/components.dart';
import '../noise/perlin_noise.dart';
import 'voxel_types.dart';

class VoxelWorld {
  static const int CHUNK_SIZE = 16;
  static const int WORLD_HEIGHT = 64;

  final PerlinNoise _noise;
  final int seed;
  final Map<String, VoxelType> _voxels = {};

  VoxelWorld({this.seed = 42}) : _noise = PerlinNoise(seed);

  Vector2 get playerPosition => Vector2(0, 0);

  String _key(int x, int y, int z) => '$x,$y,$z';

  void generateTerrain() {
    for (int x = -50; x < 50; x++) {
      for (int z = -50; z < 50; z++) {
        final double height =
            _noise.octaveNoise(x * 0.05, z * 0.05) * 20 + 30;
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
        if (y < 20) {
          for (int h = y + 1; h <= 20 && h < WORLD_HEIGHT; h++) {
            setVoxel(x, h, z, VoxelType.water);
          }
        }
      }
    }
  }

  void setVoxel(int x, int y, int z, VoxelType type) {
    if (y >= 0 && y < WORLD_HEIGHT) {
      _voxels[_key(x, y, z)] = type;
    }
  }

  VoxelType? getVoxel(int x, int y, int z) {
    if (y < 0 || y >= WORLD_HEIGHT) return null;
    return _voxels[_key(x, y, z)];
  }

  bool isSolid(int x, int y, int z) {
    final type = getVoxel(x, y, z);
    return type != null && (blockSolid[type] ?? false);
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

  int get chunkCount => _voxels.length;
}
