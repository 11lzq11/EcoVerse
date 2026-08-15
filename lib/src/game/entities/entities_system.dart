import 'package:flame/components.dart';
import 'package:vector_math/vector_math_64.dart';
import '../ecoverse_game.dart';
import '../voxel_types.dart';
import '../world/voxel_world.dart';

/// System that manages all entities in the game
class EntitiesSystem extends Component {
  final EcoVerseGame game;
  final Map<int, Entity> _entities = {};
  int _nextId = 0;
  
  EntitiesSystem(this.game);
  
  /// Spawn a new entity
  void spawn(EntityType type, Vector3 position) {
    final entity = Entity.create(type, position);
    final id = _nextId++;
    _entities[id] = entity;
    add(entity);
    
    game.gameLogger.info('Spawned ${type.name} at $position');
  }
  
  /// Remove an entity
  void remove(Entity entity) {
    _entities.remove(entity.id);
    if (entity.parent != null) {
      entity.removeFromParent();
    }
  }
  
  /// Update all entities
  @override
  void update(double dt) {
    final entitiesToRemove = <Entity>[];
    
    for (final entity in List.from(_entities.values)) {
      if (entity.isAlive) {
        entity.update(dt, game);
      } else {
        entitiesToRemove.add(entity);
      }
    }
    
    // Remove dead entities
    for (final entity in entitiesToRemove) {
      remove(entity);
    }
  }
  
  /// Get entity count
  int get entityCount => _entities.length;
  
  /// Get all entities
  Iterable<Entity> get entities => _entities.values;
  
  /// Spawn passive mobs randomly
  void spawnPassiveMobs() {
    final playerPos = game.playerController.position;
    final random = game.random;
    
    for (var i = 0; i < 10; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = 20 + random.nextDouble() * 30;
      final x = playerPos.x + math.cos(angle) * distance;
      final z = playerPos.z + math.sin(angle) * distance;
      final y = game.world.getHeight(x.round(), z.round()) + 1;
      
      final mobType = [EntityType.chicken, EntityType.cow, EntityType.pig, EntityType.sheep][random.nextInt(4)];
      spawn(mobType, Vector3(x, y, z));
    }
  }
  
  /// Spawn hostile mobs at night
  void spawnHostileMobs() {
    final playerPos = game.playerController.position;
    final random = game.random;
    
    // Only spawn at night
    if (game.renderer.dayTime > 0.25 && game.renderer.dayTime < 0.75) return;
    
    for (var i = 0; i < 5; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = 30 + random.nextDouble() * 20;
      final x = playerPos.x + math.cos(angle) * distance;
      final z = playerPos.z + math.sin(angle) * distance;
      final y = game.world.getHeight(x.round(), z.round()) + 1;
      
      final mobType = [EntityType.zombie, EntityType.skeleton, EntityType.creeper, EntityType.spider][random.nextInt(4)];
      spawn(mobType, Vector3(x, y, z));
    }
  }
}

/// Base entity class
abstract class Entity extends Component {
  final int id;
  Vector3 position = Vector3.zero();
  Vector3 velocity = Vector3.zero();
  double rotationY = 0.0;
  bool isAlive = true;
  
  Entity({required this.id});
  
  factory Entity.create(EntityType type, Vector3 position) {
    switch (type) {
      case EntityType.chicken:
        return Chicken(id: 0, position: position);
      case EntityType.cow:
        return Cow(id: 0, position: position);
      case EntityType.pig:
        return Pig(id: 0, position: position);
      case EntityType.sheep:
        return Sheep(id: 0, position: position);
      case EntityType.zombie:
        return Zombie(id: 0, position: position);
      case EntityType.skeleton:
        return Skeleton(id: 0, position: position);
      case EntityType.creeper:
        return Creeper(id: 0, position: position);
      case EntityType.spider:
        return Spider(id: 0, position: position);
      case EntityType.enderman:
        return Enderman(id: 0, position: position);
    }
  }
  
  void update(double dt, EcoVerseGame game);
}

// ============================================================
// Passive mobs
// ============================================================

class Chicken extends Entity {
  Chicken({required super.id, required Vector3 position}) : super() {
    this.position = position;
    size.setValues(0.3, 0.3, 0.3);
  }
  
  @override
  void update(double dt, EcoVerseGame game) {
    // Simple wandering behavior
    velocity.x += (game.random.nextDouble() - 0.5) * dt;
    velocity.z += (game.random.nextDouble() - 0.5) * dt;
    
    // Apply gravity
    velocity.y -= 20.0 * dt;
    
    // Move
    position += velocity * dt;
    position.y = math.max(0, position.y);
    
    // Keep within bounds
    position.x = position.x.clamp(0, game.world.worldSize.toDouble());
    position.z = position.z.clamp(0, game.world.worldSize.toDouble());
    
    // Collision with ground
    final groundHeight = game.world.getHeight(position.x.round(), position.z.round());
    if (position.y < groundHeight) {
      position.y = groundHeight;
      velocity.y = 0;
    }
  }
}

class Cow extends Entity {
  Cow({required super.id, required Vector3 position}) : super() {
    this.position = position;
    size.setValues(0.9, 0.9, 1.4);
  }
  
  @override
  void update(double dt, EcoVerseGame game) {
    velocity.x += (game.random.nextDouble() - 0.5) * dt * 0.5;
    velocity.z += (game.random.nextDouble() - 0.5) * dt * 0.5;
    velocity.y -= 20.0 * dt;
    
    position += velocity * dt;
    position.y = math.max(0, position.y);
    
    final groundHeight = game.world.getHeight(position.x.round(), position.z.round());
    if (position.y < groundHeight) {
      position.y = groundHeight;
      velocity.y = 0;
    }
  }
}

class Pig extends Entity {
  Pig({required super.id, required Vector3 position}) : super() {
    this.position = position;
    size.setValues(0.9, 0.9, 1.4);
  }
  
  @override
  void update(double dt, EcoVerseGame game) {
    velocity.x += (game.random.nextDouble() - 0.5) * dt * 0.6;
    velocity.z += (game.random.nextDouble() - 0.5) * dt * 0.6;
    velocity.y -= 20.0 * dt;
    
    position += velocity * dt;
    position.y = math.max(0, position.y);
    
    final groundHeight = game.world.getHeight(position.x.round(), position.z.round());
    if (position.y < groundHeight) {
      position.y = groundHeight;
      velocity.y = 0;
    }
  }
}

class Sheep extends Entity {
  Sheep({required super.id, required Vector3 position}) : super() {
    this.position = position;
    size.setValues(0.9, 0.9, 1.4);
  }
  
  @override
  void update(double dt, EcoVerseGame game) {
    velocity.x += (game.random.nextDouble() - 0.5) * dt * 0.5;
    velocity.z += (game.random.nextDouble() - 0.5) * dt * 0.5;
    velocity.y -= 20.0 * dt;
    
    position += velocity * dt;
    position.y = math.max(0, position.y);
    
    final groundHeight = game.world.getHeight(position.x.round(), position.z.round());
    if (position.y < groundHeight) {
      position.y = groundHeight;
      velocity.y = 0;
    }
  }
}

// ============================================================
// Hostile mobs
// ============================================================

class Zombie extends Entity {
  double attackCooldown = 0;
  
  Zombie({required super.id, required Vector3 position}) : super() {
    this.position = position;
    size.setValues(0.6, 1.9, 0.6);
  }
  
  @override
  void update(double dt, EcoVerseGame game) {
    // Simple AI: move towards player
    final playerPos = game.playerController.position;
    final direction = (playerPos - position)..normalize();
    direction.y = 0;
    
    velocity.x = direction.x * 3.0;
    velocity.z = direction.z * 3.0;
    velocity.y -= 20.0 * dt;
    
    position += velocity * dt;
    
    // Attack player if close
    attackCooldown -= dt;
    if (attackCooldown <= 0 && position.distanceTo(playerPos) < 2.0) {
      game.playerController.takeDamage(3.0);
      attackCooldown = 1.0;
    }
    
    final groundHeight = game.world.getHeight(position.x.round(), position.z.round());
    if (position.y < groundHeight) {
      position.y = groundHeight;
      velocity.y = 0;
    }
  }
}

class Skeleton extends Entity {
  double shootCooldown = 0;
  
  Skeleton({required super.id, required Vector3 position}) : super() {
    this.position = position;
    size.setValues(0.6, 1.8, 0.6);
  }
  
  @override
  void update(double dt, EcoVerseGame game) {
    // Keep distance from player
    final playerPos = game.playerController.position;
    final dist = position.distanceTo(playerPos);
    
    if (dist < 5.0) {
      // Back away
      final direction = (position - playerPos)..normalize();
      velocity.x = direction.x * 2.5;
      velocity.z = direction.z * 2.5;
    } else if (dist < 20.0) {
      // Shoot arrow
      shootCooldown -= dt;
      if (shootCooldown <= 0) {
        _shootArrow(game, playerPos);
        shootCooldown = 2.0;
      }
    }
    
    velocity.y -= 20.0 * dt;
    position += velocity * dt;
    
    final groundHeight = game.world.getHeight(position.x.round(), position.z.round());
    if (position.y < groundHeight) {
      position.y = groundHeight;
      velocity.y = 0;
    }
  }
  
  void _shootArrow(EcoVerseGame game, Vector3 target) {
    // Create projectile
    final arrow = Arrow(
      id: game.entitiesSystem._nextId++,
      position: position.clone() + Vector3(0, 1.5, 0),
      target: target,
    );
    game.entitiesSystem.add(arrow);
  }
}

class Arrow extends Entity {
  Vector3 target;
  double lifeTime = 3.0;
  
  Arrow({required super.id, required Vector3 position, required this.target}) : super() {
    this.position = position;
    size.setValues(0.1, 0.1, 0.8);
  }
  
  @override
  void update(double dt, EcoVerseGame game) {
    lifeTime -= dt;
    if (lifeTime <= 0) {
      isAlive = false;
      return;
    }
    
    // Move towards target
    final dir = (target - position)..normalize();
    position += dir * 20.0 * dt;
    
    // Check collision with player
    if (position.distanceTo(game.playerController.position) < 1.0) {
      game.playerController.takeDamage(5.0);
      isAlive = false;
    }
  }
}

class Creeper extends Entity {
  double explodeTimer = -1;
  
  Creeper({required super.id, required Vector3 position}) : super() {
    this.position = position;
    size.setValues(0.6, 1.7, 0.6);
  }
  
  @override
  void update(double dt, EcoVerseGame game) {
    final playerPos = game.playerController.position;
    final dist = position.distanceTo(playerPos);
    
    // Move towards player
    if (dist > 1.5) {
      final dir = (playerPos - position)..normalize();
      velocity.x = dir.x * 4.0;
      velocity.z = dir.z * 4.0;
    } else {
      // Start exploding
      if (explodeTimer < 0) explodeTimer = 1.5;
      explodeTimer -= dt;
      
      if (explodeTimer <= 0) {
        _explode(game);
        return;
      }
    }
    
    velocity.y -= 20.0 * dt;
    position += velocity * dt;
    
    final groundHeight = game.world.getHeight(position.x.round(), position.z.round());
    if (position.y < groundHeight) {
      position.y = groundHeight;
      velocity.y = 0;
    }
  }
  
  void _explode(EcoVerseGame game) {
    final playerPos = game.playerController.position;
    final dist = position.distanceTo(playerPos);
    
    // Damage player based on distance
    if (dist < 5.0) {
      final damage = (1 - dist / 5.0) * 10.0;
      game.playerController.takeDamage(damage);
    }
    
    isAlive = false;
  }
}

class Spider extends Entity {
  Spider({required super.id, required Vector3 position}) : super() {
    this.position = position;
    size.setValues(1.4, 0.6, 1.4);
  }
  
  @override
  void update(double dt, EcoVerseGame game) {
    final playerPos = game.playerController.position;
    final dir = (playerPos - position)..normalize();
    
    velocity.x = dir.x * 4.0;
    velocity.z = dir.z * 4.0;
    velocity.y -= 20.0 * dt;
    
    position += velocity * dt;
    
    // Jump occasionally
    if (game.random.nextDouble() < 0.02 && position.y <= game.world.getHeight(position.x.round(), position.z.round())) {
      velocity.y = 8.0;
    }
    
    final groundHeight = game.world.getHeight(position.x.round(), position.z.round());
    if (position.y < groundHeight) {
      position.y = groundHeight;
      velocity.y = 0;
    }
  }
}

class Enderman extends Entity {
  Enderman({required super.id, required Vector3 position}) : super() {
    this.position = position;
    size.setValues(0.6, 2.9, 0.6);
  }
  
  @override
  void update(double dt, EcoVerseGame game) {
    final playerPos = game.playerController.position;
    final dist = position.distanceTo(playerPos);
    
    // Only aggro when looked at
    if (dist < 20.0) {
      final dir = (playerPos - position)..normalize();
      velocity.x = dir.x * 15.0;
      velocity.z = dir.z * 15.0;
      
      // Teleport occasionally
      if (game.random.nextDouble() < 0.01) {
        position = playerPos + Vector3(
          (game.random.nextDouble() - 0.5) * 10,
          position.y,
          (game.random.nextDouble() - 0.5) * 10,
        );
      }
    }
    
    velocity.y -= 20.0 * dt;
    position += velocity * dt;
    
    final groundHeight = game.world.getHeight(position.x.round(), position.z.round());
    if (position.y < groundHeight) {
      position.y = groundHeight;
      velocity.y = 0;
    }
  }
}
