import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';
import '../world/voxel_types.dart';

/// Player controller component
class PlayerController {
  final VoxelWorld world;
  
  // Physics
  Vector3 position = Vector3(128, 100, 128);
  Vector3 velocity = Vector3.zero();
  double rotationY = 0.0;
  double rotationX = 0.0;
  
  // Stats
  double health = 20.0;
  double maxHealth = 20.0;
  double hunger = 20.0;
  double experience = 0.0;
  int level = 0;
  
  // Movement state
  bool isOnGround = false;
  bool isSprinting = false;
  bool isSneaking = false;
  bool isFlying = false;
  
  // Inventory
  final List<ItemSlot> _inventory = List.generate(36, (i) => ItemSlot());
  int _selectedSlot = 0;
  
  // Tools
  ToolType selectedTool = ToolType.hand;
  VoxelType selectedBlock = VoxelType.dirt;
  
  // Game mode
  GameMode gameMode = GameMode.survival;
  
  PlayerController({required this.world});
  
  /// Update player movement and physics
  void updateMovement({
    required bool forward,
    required bool backward,
    required bool left,
    required bool right,
    required bool jump,
    required bool sprint,
    required EcoVerseGame game,
    required double dt,
  }) {
    if (!isAlive()) return;
    
    isSprinting = sprint && !isSneaking;
    isSneaking = sprint;
    
    // Calculate movement direction based on camera rotation
    final speed = isSprinting ? 8.0 : isSneaking ? 2.0 : 4.0;
    final yaw = rotationY;
    
    double moveX = 0;
    double moveZ = 0;
    
    if (forward) {
      moveX += math.sin(yaw) * speed;
      moveZ -= math.cos(yaw) * speed;
    }
    if (backward) {
      moveX -= math.sin(yaw) * speed;
      moveZ += math.cos(yaw) * speed;
    }
    if (left) {
      moveX += math.cos(yaw) * speed;
      moveZ += math.sin(yaw) * speed;
    }
    if (right) {
      moveX -= math.cos(yaw) * speed;
      moveZ -= math.sin(yaw) * speed;
    }
    
    // Apply horizontal movement
    velocity.x = moveX;
    velocity.z = moveZ;
    
    // Jump
    if (jump && isOnGround) {
      velocity.y = 8.0;
      isOnGround = false;
    }
    
    // Flying mode
    if (gameMode == GameMode.creative) {
      // Simple flying control
      velocity.y = 0;
      isFlying = true;
    } else {
      isFlying = false;
      // Apply gravity
      velocity.y -= 25.0 * dt;
    }
    
    // Update position
    final newPosition = position.clone() + velocity * dt;
    
    // Collision detection
    if (_checkCollision(newPosition)) {
      // Slide along walls
      if (!_checkCollision(Vector3(newPosition.x, position.y, newPosition.z))) {
        position.x = newPosition.x;
      }
      if (!_checkCollision(Vector3(position.x, newPosition.y, position.z))) {
        position.y = newPosition.y;
        isOnGround = velocity.y <= 0;
      }
      if (!_checkCollision(Vector3(position.x, position.y, newPosition.z))) {
        position.z = newPosition.z;
      }
    } else {
      position = newPosition;
      isOnGround = velocity.y <= 0;
    }
    
    // Keep within world bounds
    position.x = position.x.clamp(0, world.worldSize.toDouble());
    position.z = position.z.clamp(0, world.worldSize.toDouble());
    
    // Death by falling
    if (position.y < 0) {
      takeDamage(100);
    }
    
    // Hunger depletion
    if (gameMode == GameMode.survival) {
      hunger = (hunger - 0.01 * dt).clamp(0, 20);
      if (hunger <= 0 && math.Random().nextDouble() < 0.01) {
        takeDamage(1);
      }
    }
  }
  
  /// Check collision at position
  bool _checkCollision(Vector3 pos) {
    final blockPos = pos.floorToInt32() + Vector3i(0, 1, 0);
    final block = world.getBlock(blockPos);
    final props = blockProperties[block];
    
    // Check if block is solid
    return props != null && props.solid && !props.transparent;
  }
  
  /// Take damage
  void takeDamage(double amount) {
    if (gameMode == GameMode.creative) return;
    
    health = (health - amount).clamp(0, maxHealth);
    
    if (health <= 0) {
      _respawn();
    }
  }
  
  /// Heal player
  void heal(double amount) {
    health = (health + amount).clamp(0, maxHealth);
  }
  
  /// Respawn player
  void _respawn() {
    position.setValues(
      world.worldSize / 2,
      world.getHeight(world.worldSize ~/ 2, world.worldSize ~/ 2) + 3,
      world.worldSize / 2,
    );
    health = maxHealth;
    hunger = 20;
    velocity.setZero();
  }
  
  /// Get selected item from inventory
  ItemSlot get selectedItem => _inventory[_selectedSlot];
  
  /// Select inventory slot
  void selectSlot(int index) {
    if (index >= 0 && index < _inventory.length) {
      _selectedSlot = index;
      final item = _inventory[index];
      if (item.type != null) {
        selectedBlock = item.type!;
      }
    }
  }
  
  /// Add item to inventory
  bool addItem(VoxelType type, int count) {
    // Try to stack with existing items
    for (final slot in _inventory) {
      if (slot.type == type && slot.count < slot.maxCount) {
        slot.count += count;
        return true;
      }
    }
    
    // Find empty slot
    for (final slot in _inventory) {
      if (slot.isEmpty) {
        slot.type = type;
        slot.count = count.clamp(0, slot.maxCount);
        return true;
      }
    }
    
    return false; // Inventory full
  }
  
  /// Remove item from inventory
  bool removeItem(VoxelType type, int count) {
    var remaining = count;
    for (int i = _inventory.length - 1; i >= 0 && remaining > 0; i--) {
      final slot = _inventory[i];
      if (slot.type == type) {
        final removed = remaining.clamp(0, slot.count);
        slot.count -= removed;
        remaining -= removed;
        if (slot.count == 0) {
          slot.clear();
        }
      }
    }
    return remaining <= 0;
  }
  
  /// Gain experience
  void gainExperience(double amount) {
    experience += amount;
    final needed = _experienceNeeded(level + 1);
    if (experience >= needed) {
      experience -= needed;
      level++;
    }
  }
  
  /// Get experience needed for next level
  int _experienceNeeded(int level) {
    if (level >= 30) return 112;
    if (level >= 15) return 37 + (level - 15) * 9;
    return 7 + level * 2;
  }
  
  /// Check if player is alive
  bool isAlive() => health > 0;
  
  /// Get player's current slot index
  int get currentSlot => _selectedSlot;
  
  /// Clear inventory
  void clearInventory() {
    for (final slot in _inventory) {
      slot.clear();
    }
  }
}

/// Item slot in inventory
class ItemSlot {
  VoxelType? type;
  int count = 0;
  static const int maxCount = 64;
  
  bool get isEmpty => type == null || count == 0;
  
  void clear() {
    type = null;
    count = 0;
  }
}

/// Game mode enum
enum GameMode { survival, creative, adventure }
