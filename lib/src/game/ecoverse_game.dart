import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import '../managers/resource_manager.dart';
import 'entities/entities_system.dart';
import 'entities/player/player_controller.dart';
import 'world/chunk_manager.dart';
import 'world/voxel_world.dart';

class EcoVerseGame extends FlameGame with HasKeyboardHandlerComponents {
  late VoxelWorld world;
  late ChunkManager chunkManager;
  late PlayerController playerController;
  late ResourceManager resourceManager;
  late EntitiesSystem entitiesSystem;

  final Map<LogicalKeyboardKey, bool> keysDown = {};

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    resourceManager = ResourceManager();
    await resourceManager.loadAll();

    world = VoxelWorld(seed: 42);
    world.generateTerrain();

    playerController = PlayerController(
      position: world.playerPosition,
      game: this,
    );
    await add(playerController);

    chunkManager = ChunkManager(world, renderDistance: 4);
    await add(chunkManager);

    entitiesSystem = EntitiesSystem();
    await add(entitiesSystem);

    camera.viewfinder.position = world.playerPosition;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _processKeyboardInput(dt);
    playerController.update(dt);
    chunkManager.updateChunks(playerController.position);
    camera.viewfinder.position = playerController.position;
  }

  void _processKeyboardInput(double dt) {
    const double speed = 10.0;
    final direction = Vector2.zero();

    if (keysDown[LogicalKeyboardKey.keyW] == true ||
        keysDown[LogicalKeyboardKey.arrowUp] == true) {
      direction.y += 1;
    }
    if (keysDown[LogicalKeyboardKey.keyS] == true ||
        keysDown[LogicalKeyboardKey.arrowDown] == true) {
      direction.y -= 1;
    }
    if (keysDown[LogicalKeyboardKey.keyA] == true ||
        keysDown[LogicalKeyboardKey.arrowLeft] == true) {
      direction.x -= 1;
    }
    if (keysDown[LogicalKeyboardKey.keyD] == true ||
        keysDown[LogicalKeyboardKey.arrowRight] == true) {
      direction.x += 1;
    }

    if (direction.length() > 0) {
      direction.normalize();
      direction.scale(speed * dt);
      playerController.move(direction);
    }

    if (keysDown[LogicalKeyboardKey.space] == true) {
      playerController.jump();
    }
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final key = event.logicalKey;
    if (event is RawKeyDownEvent) {
      keysDown[key] = true;
    } else if (event is RawKeyUpEvent) {
      keysDown.remove(key);
    }
    return super.onKeyEvent(event, keysPressed);
  }

  Future<void> saveWorld(String path) async {
    // TODO: Implement save logic
  }
}