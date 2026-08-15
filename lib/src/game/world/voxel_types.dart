// Fixed voxel types with proper enums
enum VoxelType {
  grass,
  dirt,
  stone,
  sand,
  water,
  wood,
  leaves,
  sky,
}

enum ToolType {
  pickaxe,
  sword,
  hand,
}

class BlockProperties {
  final VoxelType type;
  final bool isSolid;
  final double hardness;
  
  const BlockProperties({
    required this.type,
    this.isSolid = true,
    this.hardness = 1.0,
  });
}

const Map<VoxelType, BlockProperties> blockProperties = {
  VoxelType.grass: BlockProperties(type: VoxelType.grass),
  VoxelType.dirt: BlockProperties(type: VoxelType.dirt),
  VoxelType.stone: BlockProperties(type: VoxelType.stone, hardness: 2.0),
  VoxelType.sand: BlockProperties(type: VoxelType.sand),
  VoxelType.water: BlockProperties(type: VoxelType.water, isSolid: false),
  VoxelType.wood: BlockProperties(type: VoxelType.wood),
  VoxelType.leaves: BlockProperties(type: VoxelType.leaves, isSolid: false),
  VoxelType.sky: BlockProperties(type: VoxelType.sky, isSolid: false),
};
