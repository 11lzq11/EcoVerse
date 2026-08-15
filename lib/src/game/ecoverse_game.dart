import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
import '../managers/resource_manager.dart';
import 'entities/entities_system.dart';
import 'entities/player/player_controller.dart';
import 'world/chunk_manager.dart';
import 'world/voxel_world.dart';

class EcoVerseGame extends FlameGame with HasKeyboardHandlerComponents, TapCallbacks, DragCallbacks {
  late VoxelWorld world;
  late ChunkManager chunkManager;
  late PlayerController playerController;
  late ResourceManager resourceManager;
  late EntitiesSystem entitiesSystem;

  // 键盘输入状态
  final Map<LogicalKeyboardKey, bool> keysDown = {};

  // 触摸输入追踪
  final Map<int, Vector2> touchesBegan = {};
  final Map<int, Vector2> touchesMoved = {};
  final Map<int, Vector2> touchesEnded = {};
  final List<TapDownEvent> tapDowns = [];
  final List<DragStartEvent> dragsStarted = [];
  final List<DragUpdateEvent> drags = [];
  final List<DragEndEvent> dragsEnded = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 初始化资源管理器
    resourceManager = ResourceManager();
    await resourceManager.loadAll();

    // 创建世界
    world = VoxelWorld(seed: 42);
    world.generateTerrain();

    // 添加玩家控制器
    playerController = PlayerController(
      position: world.getPlayerHeight(),
      game: this,
    );
    await add(playerController);

    // 添加chunk管理器
    chunkManager = ChunkManager(world, renderDistance: 4);
    await add(chunkManager);

    // 添加实体系统
    entitiesSystem = EntitiesSystem();
    await add(entitiesSystem);

    // 设置初始相机位置
    camera.viewfinder.position = world.getPlayerHeight();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 处理键盘输入
    _processKeyboardInput(dt);

    // 更新玩家
    playerController.update(dt);

    // 更新chunk管理
    chunkManager.updateChunks(playerController.position);

    // 更新相机跟随
    camera.viewfinder.position = playerController.position;
  }

  void _processKeyboardInput(double dt) {
    const double speed = 10.0;
    final Vector3 direction = Vector3.zero();

    if (keysDown[LogicalKeyboardKey.keyW] == true || keysDown[LogicalKeyboardKey.arrowUp] == true) {
      direction.add(Vector3(0, 0, -1));
    }
    if (keysDown[LogicalKeyboardKey.keyS] == true || keysDown[LogicalKeyboardKey.arrowDown] == true) {
      direction.add(Vector3(0, 0, 1));
    }
    if (keysDown[LogicalKeyboardKey.keyA] == true || keysDown[LogicalKeyboardKey.arrowLeft] == true) {
      direction.add(Vector3(-1, 0, 0));
    }
    if (keysDown[LogicalKeyboardKey.keyD] == true || keysDown[LogicalKeyboardKey.arrowRight] == true) {
      direction.add(Vector3(1, 0, 0));
    }

    if (direction.length() > 0) {
      direction.normalize();
      direction.scale(speed * dt);
      playerController.move(direction);
    }

    // 跳跃
    if (keysDown[LogicalKeyboardKey.space] == true) {
      playerController.jump();
    }
  }

  // 键盘事件处理
  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final LogicalKeyboardKey key = event.logicalKey;
    if (event is RawKeyDownEvent) {
      keysDown[key] = true;
    } else if (event is RawKeyUpEvent) {
      keysDown[key] = false;
    }
    return KeyEventResult.ignore;
  }

  // 触摸事件处理 - TapCallbacks
  @override
  void onTapDown(TapDownEvent event) {
    tapDowns.add(event);
  }

  // 拖拽事件处理 - DragCallbacks
  @override
  void onDragStart(DragStartEvent event) {
    dragsStarted.add(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    drags.add(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    dragsEnded.add(event);
  }

  // 保存世界
  Future<void> saveWorld(String path) async {
    // TODO: Implement save logic
  }
}
