import '../world/voxel_world.dart';

class WorldSaveManager {
  Future<void> saveWorld(VoxelWorld world) async {}
  Future<VoxelWorld> loadWorld() async => VoxelWorld(seed: 42);
}
