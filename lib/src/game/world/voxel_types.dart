import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';

/// Voxel type constants for different block types
enum VoxelType {
  air(0),
  grass(1),
  dirt(2),
  stone(3),
  sand(4),
  water(5),
  wood(6),
  leaves(7),
  snow(8),
  glass(9),
  sandstone(10),
  cobblestone(11),
  brick(12),
  ironOre(13),
  goldOre(14),
  diamondOre(15),
  coalOre(16),
  plank(17),
  ladder(18),
  door(19),
  chest(20),
  furnace(21),
  craftingTable(22),
  TNT(23),
  lava(24),
  bedrock(25),
  obsidian(26);

  final int id;
  const VoxelType(this.id);
}

/// Block properties for rendering and physics
class BlockProperties {
  final VoxelType type;
  final bool solid;
  final bool transparent;
  final double hardness;
  final String displayName;
  final Color color;
  
  const BlockProperties({
    required this.type,
    this.solid = true,
    this.transparent = false,
    this.hardness = 1.0,
    this.displayName = '',
    required this.color,
  });
}

/// Simplified 3D vector using int32 for performance
typedef IntVector3 = Vector3i;

extension IntVector3Extension on Vector3i {
  bool get isZero => x == 0 && y == 0 && z == 0;
  
  IntVector3 operator +(IntVector3 other) => 
    Vector3i(x + other.x, y + other.y, z + other.z);
  
  IntVector3 operator -(IntVector3 other) => 
    Vector3i(x - other.x, y - other.y, z - other.z);
  
  IntVector3 operator *(int scalar) => 
    Vector3i(x * scalar, y * scalar, z * scalar);
  
  bool operator ==(Object other) => 
    other is IntVector3 && x == other.x && y == other.y && z == other.z;
  
  int get hashCode => Object.hash(x, y, z);
  
  @override
  String toString() => '($x, $y, $z)';
}

/// Raycast result for block interaction
class RaycastResult {
  final IntVector3 position;
  final Vector3? faceNormal;
  final double distance;
  
  const RaycastResult({
    required this.position,
    this.faceNormal,
    this.distance = 0.0,
  });
}

/// Direction enum for block placement/removal
enum BlockFace {
  top,
  bottom,
  north,
  south,
  east,
  west,
}

/// Get normal vector for a face
Vector3 getFaceNormal(BlockFace face) {
  switch (face) {
    case BlockFace.top: return Vector3(0, 1, 0);
    case BlockFace.bottom: return Vector3(0, -1, 0);
    case BlockFace.north: return Vector3(0, 0, -1);
    case BlockFace.south: return Vector3(0, 0, 1);
    case BlockFace.east: return Vector3(1, 0, 0);
    case BlockFace.west: return Vector3(-1, 0, 0);
  }
}

/// Direction for player movement
enum MoveDirection {
  forward,
  backward,
  left,
  right,
  up,
  down,
}

/// Tool type for player interactions
enum ToolType {
  hand,
  pickaxe,
  sword,
  axe,
  hoe,
  shovel,
}

/// Entity types for spawning
enum EntityType {
  chicken,
  cow,
  pig,
  sheep,
  zombie,
  skeleton,
  creeper,
  spider,
  enderman,
}

/// Simple color class
class Color {
  final int r, g, b, a;
  const Color(this.r, this.g, this.b, [this.a = 255]);
  
  int get argb => (a << 24) | (r << 16) | (g << 8) | b;
  
  @override
  bool operator ==(Object other) => 
    other is Color && r == other.r && g == other.g && b == other.b && a == other.a;
  
  @override
  int get hashCode => Object.hash(r, g, b, a);
}

/// Block properties map
final Map<VoxelType, BlockProperties> blockProperties = {
  VoxelType.air: BlockProperties(
    type: VoxelType.air,
    solid: false,
    transparent: true,
    hardness: 0.0,
    displayName: 'Air',
    color: Color(0, 0, 0, 0),
  ),
  VoxelType.grass: BlockProperties(
    type: VoxelType.grass,
    hardness: 0.6,
    displayName: 'Grass',
    color: Color(68, 147, 48),
  ),
  VoxelType.dirt: BlockProperties(
    type: VoxelType.dirt,
    hardness: 0.5,
    displayName: 'Dirt',
    color: Color(134, 93, 58),
  ),
  VoxelType.stone: BlockProperties(
    type: VoxelType.stone,
    hardness: 1.5,
    displayName: 'Stone',
    color: Color(128, 128, 128),
  ),
  VoxelType.sand: BlockProperties(
    type: VoxelType.sand,
    hardness: 0.5,
    displayName: 'Sand',
    color: Color(237, 220, 154),
  ),
  VoxelType.water: BlockProperties(
    type: VoxelType.water,
    solid: false,
    transparent: true,
    hardness: 0.0,
    displayName: 'Water',
    color: Color(30, 100, 200, 150),
  ),
  VoxelType.wood: BlockProperties(
    type: VoxelType.wood,
    hardness: 2.0,
    displayName: 'Wood',
    color: Color(112, 70, 32),
  ),
  VoxelType.leaves: BlockProperties(
    type: VoxelType.leaves,
    solid: true,
    transparent: true,
    hardness: 0.2,
    displayName: 'Leaves',
    color: Color(48, 128, 48),
  ),
  VoxelType.snow: BlockProperties(
    type: VoxelType.snow,
    hardness: 0.5,
    displayName: 'Snow',
    color: Color(255, 255, 255),
  ),
  VoxelType.glass: BlockProperties(
    type: VoxelType.glass,
    solid: true,
    transparent: true,
    hardness: 0.3,
    displayName: 'Glass',
    color: Color(200, 230, 255, 100),
  ),
  VoxelType.bedrock: BlockProperties(
    type: VoxelType.bedrock,
    hardness: 1000.0,
    displayName: 'Bedrock',
    color: Color(50, 50, 50),
  ),
  VoxelType.ironOre: BlockProperties(
    type: VoxelType.ironOre,
    hardness: 3.0,
    displayName: 'Iron Ore',
    color: Color(180, 150, 130),
  ),
  VoxelType.goldOre: BlockProperties(
    type: VoxelType.goldOre,
    hardness: 3.0,
    displayName: 'Gold Ore',
    color: Color(230, 200, 80),
  ),
  VoxelType.diamondOre: BlockProperties(
    type: VoxelType.diamondOre,
    hardness: 4.0,
    displayName: 'Diamond Ore',
    color: Color(80, 220, 230),
  ),
  VoxelType.coalOre: BlockProperties(
    type: VoxelType.coalOre,
    hardness: 2.0,
    displayName: 'Coal Ore',
    color: Color(60, 60, 60),
  ),
  VoxelType.plank: BlockProperties(
    type: VoxelType.plank,
    hardness: 1.0,
    displayName: 'Plank',
    color: Color(194, 154, 94),
  ),
  VoxelType.cobblestone: BlockProperties(
    type: VoxelType.cobblestone,
    hardness: 2.0,
    displayName: 'Cobblestone',
    color: Color(100, 100, 100),
  ),
  VoxelType.brick: BlockProperties(
    type: VoxelType.brick,
    hardness: 2.0,
    displayName: 'Brick',
    color: Color(162, 82, 76),
  ),
  VoxelType.ladder: BlockProperties(
    type: VoxelType.ladder,
    solid: false,
    transparent: true,
    hardness: 0.4,
    displayName: 'Ladder',
    color: Color(134, 90, 52),
  ),
  VoxelType.door: BlockProperties(
    type: VoxelType.door,
    solid: false,
    transparent: true,
    hardness: 1.0,
    displayName: 'Door',
    color: Color(134, 90, 52),
  ),
  VoxelType.chest: BlockProperties(
    type: VoxelType.chest,
    solid: false,
    transparent: true,
    hardness: 1.0,
    displayName: 'Chest',
    color: Color(134, 90, 52),
  ),
  VoxelType.furnace: BlockProperties(
    type: VoxelType.furnace,
    solid: true,
    hardness: 2.0,
    displayName: 'Furnace',
    color: Color(100, 100, 100),
  ),
  VoxelType.craftingTable: BlockProperties(
    type: VoxelType.craftingTable,
    solid: true,
    hardness: 1.0,
    displayName: 'Crafting Table',
    color: Color(134, 90, 52),
  ),
  VoxelType.TNT: BlockProperties(
    type: VoxelType.TNT,
    solid: true,
    hardness: 0.0,
    displayName: 'TNT',
    color: Color(220, 50, 50),
  ),
  VoxelType.lava: BlockProperties(
    type: VoxelType.lava,
    solid: false,
    transparent: true,
    hardness: 0.0,
    displayName: 'Lava',
    color: Color(255, 100, 0),
  ),
  VoxelType.obsidian: BlockProperties(
    type: VoxelType.obsidian,
    hardness: 50.0,
    displayName: 'Obsidian',
    color: Color(20, 10, 30),
  ),
};
