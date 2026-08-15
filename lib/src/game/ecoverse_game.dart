import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import '../managers/resource_manager.dart';
import 'entities/entities_system.dart';
import 'entities/player/player_controller.dart';
import 'world/chunk_manager.dart';
import 'world/voxel_world.dart';

class EcoVerseGame extends FlameGame with HasKeyboardHandlerComponents, TapCallbacks, DragCallbacks {
  late VoxelWorld voxelWorld;
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
    voxelWorld = VoxelWorld(seed: 42);
    voxelWorld.generateTerrain();
    playerController = PlayerController(position: voxelWorld.playerPosition, game: this);
    await add(playerController);
    chunkManager = ChunkManager(voxelWorld, renderDistance: 4);
    await add(chunkManager);
    entitiesSystem = EntitiesSystem();
    await add(entitiesSystem);
    camera.viewfinder.position = voxelWorld.playerPosition;
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
    const speed = 10.0;
    final dir = Vector2.zero();
    if (keysDown[LogicalKeyboardKey.keyW] == true || keysDown[LogicalKeyboardKey.arrowUp] == true) dir.y += 1;
    if (keysDown[LogicalKeyboardKey.keyS] == true || keysDown[LogicalKeyboardKey.arrowDown] == true) dir.y -= 1;
    if (keysDown[LogicalKeyboardKey.keyA] == true || keysDown[LogicalKeyboardKey.arrowLeft] == true) dir.x -= 1;
    if (keysDown[LogicalKeyboardKey.keyD] == true || keysDown[LogicalKeyboardKey.arrowRight] == true) dir.x += 1;
    if (dir.length() > 0) {
      dir.normalize();
      dir.scale(speed * dt);
      playerController.move(dir);
    }
    if (keysDown[LogicalKeyboardKey.space] == true) playerController.jump();
  }

  @override
  void onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final key = event.logicalKey;
    if (event is RawKeyDownEvent) keysDown[key] = true;
    if (event is RawKeyUpEvent) keysDown[key] = false;
    super.onKeyEvent(event, keysPressed);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
  }

  Future<void> saveWorld(String path) async {}
}
