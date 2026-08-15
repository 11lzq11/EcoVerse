"""Voxel type definitions for EcoVerse game."""
from enum import Enum, auto
from dataclasses import dataclass
from typing import Dict, Optional


class VoxelType(Enum):
    """Block types in the voxel world."""
    AIR = 0
    GRASS = 1
    DIRT = 2
    STONE = 3
    SAND = 4
    WATER = 5
    WOOD = 6
    LEAVES = 7
    SNOW = 8
    GLASS = 9
    SANDSTONE = 10
    COBBLESTONE = 11
    BRICK = 12
    IRON_ORE = 13
    GOLD_ORE = 14
    DIAMOND_ORE = 15
    COAL_ORE = 16
    PLANK = 17
    LADDER = 18
    DOOR = 19
    CHEST = 20
    FURNACE = 21
    CRAFTING_TABLE = 22
    TNT = 23
    LAVA = 24
    BEDROCK = 25
    OBSIDIAN = 26


@dataclass(frozen=True)
class BlockProperties:
    """Physical and visual properties of a block."""
    voxel_type: VoxelType
    solid: bool = True
    transparent: bool = False
    hardness: float = 1.0
    display_name: str = ""
    color: tuple = (128, 128, 128)


# Block properties registry
BLOCK_PROPERTIES: Dict[VoxelType, BlockProperties] = {
    VoxelType.AIR: BlockProperties(VoxelType.AIR, solid=False, transparent=True, hardness=0.0, display_name="Air", color=(0, 0, 0)),
    VoxelType.GRASS: BlockProperties(VoxelType.GRASS, hardness=0.6, display_name="Grass", color=(68, 147, 48)),
    VoxelType.DIRT: BlockProperties(VoxelType.DIRT, hardness=0.5, display_name="Dirt", color=(134, 93, 58)),
    VoxelType.STONE: BlockProperties(VoxelType.STONE, hardness=1.5, display_name="Stone", color=(128, 128, 128)),
    VoxelType.SAND: BlockProperties(VoxelType.SAND, hardness=0.5, display_name="Sand", color=(237, 220, 154)),
    VoxelType.WATER: BlockProperties(VoxelType.WATER, solid=False, transparent=True, hardness=0.0, display_name="Water", color=(30, 100, 200)),
    VoxelType.WOOD: BlockProperties(VoxelType.WOOD, hardness=2.0, display_name="Wood", color=(112, 70, 32)),
    VoxelType.LEAVES: BlockProperties(VoxelType.LEAVES, transparent=True, hardness=0.2, display_name="Leaves", color=(48, 128, 48)),
    VoxelType.SNOW: BlockProperties(VoxelType.SNOW, hardness=0.5, display_name="Snow", color=(255, 255, 255)),
    VoxelType.GLASS: BlockProperties(VoxelType.GLASS, transparent=True, hardness=0.3, display_name="Glass", color=(200, 230, 255)),
    VoxelType.BEDROCK: BlockProperties(VoxelType.BEDROCK, hardness=1000.0, display_name="Bedrock", color=(50, 50, 50)),
    VoxelType.IRON_ORE: BlockProperties(VoxelType.IRON_ORE, hardness=3.0, display_name="Iron Ore", color=(180, 150, 130)),
    VoxelType.GOLD_ORE: BlockProperties(VoxelType.GOLD_ORE, hardness=3.0, display_name="Gold Ore", color=(230, 200, 80)),
    VoxelType.DIAMOND_ORE: BlockProperties(VoxelType.DIAMOND_ORE, hardness=4.0, display_name="Diamond Ore", color=(80, 220, 230)),
    VoxelType.COAL_ORE: BlockProperties(VoxelType.COAL_ORE, hardness=2.0, display_name="Coal Ore", color=(60, 60, 60)),
    VoxelType.PLANK: BlockProperties(VoxelType.PLANK, hardness=1.0, display_name="Plank", color=(194, 154, 94)),
    VoxelType.COBBLESTONE: BlockProperties(VoxelType.COBBLESTONE, hardness=2.0, display_name="Cobblestone", color=(100, 100, 100)),
    VoxelType.BRICK: BlockProperties(VoxelType.BRICK, hardness=2.0, display_name="Brick", color=(162, 82, 76)),
    VoxelType.LADDER: BlockProperties(VoxelType.LADDER, solid=False, transparent=True, hardness=0.4, display_name="Ladder", color=(134, 90, 52)),
    VoxelType.Door: BlockProperties(VoxelType.DOOR, solid=False, transparent=True, hardness=1.0, display_name="Door", color=(134, 90, 52)),
    VoxelType.CHEST: BlockProperties(VoxelType.CHEST, solid=False, transparent=True, hardness=1.0, display_name="Chest", color=(134, 90, 52)),
    VoxelType.FURNACE: BlockProperties(VoxelType.FURNACE, hardness=2.0, display_name="Furnace", color=(100, 100, 100)),
    VoxelType.CRAFTING_TABLE: BlockProperties(VoxelType.CRAFTING_TABLE, hardness=1.0, display_name="Crafting Table", color=(134, 90, 52)),
    VoxelType.TNT: BlockProperties(VoxelType.TNT, hardness=0.0, display_name="TNT", color=(220, 50, 50)),
    VoxelType.LAVA: BlockProperties(VoxelType.LAVA, solid=False, transparent=True, hardness=0.0, display_name="Lava", color=(255, 100, 0)),
    VoxelType.OBSIDIAN: BlockProperties(VoxelType.OBSIDIAN, hardness=50.0, display_name="Obsidian", color=(20, 10, 30)),
}


class BlockFace(Enum):
    """Faces of a block for raycasting."""
    TOP = auto()
    BOTTOM = auto()
    NORTH = auto()
    SOUTH = auto()
    EAST = auto()
    WEST = auto()


class MoveDirection(Enum):
    """Player movement directions."""
    FORWARD = auto()
    BACKWARD = auto()
    LEFT = auto()
    RIGHT = auto()
    UP = auto()
    DOWN = auto()


class ToolType(Enum):
    """Tool types for mining/crafting."""
    HAND = auto()
    PICKAXE = auto()
    SWORD = auto()
    AXE = auto()
    HOE = auto()
    SHOVEL = auto()


class EntityType(Enum):
    """Entity types in the game."""
    CHICKEN = auto()
    COW = auto()
    PIG = auto()
    SHEEP = auto()
    ZOMBIE = auto()
    SKELETON = auto()
    CREEPER = auto()
    SPIDER = auto()
    ENDERMAN = auto()


class GameMode(Enum):
    """Game modes."""
    SURVIVAL = auto()
    CREATIVE = auto()
