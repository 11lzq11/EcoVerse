// Voxel types definitions
enum VoxelType {
  grass,
  dirt,
  stone,
  sand,
  water,
  wood,
  leaves,
}

const Map<VoxelType, bool> blockSolid = {
  VoxelType.grass: true,
  VoxelType.dirt: true,
  VoxelType.stone: true,
  VoxelType.sand: true,
  VoxelType.water: false,
  VoxelType.wood: true,
  VoxelType.leaves: false,
};
