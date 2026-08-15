import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';

import 'managers/game_state_manager.dart';
import 'managers/resource_manager.dart';
import 'world/voxel_world.dart';
import 'world/chunk_manager.dart';
import 'entities/player/player_controller.dart';
import 'entities/entities_system.dart';
import 'rendering/renderer_3d.dart';
import 'save_system/world_save_manager.dart';

class EcoVerseGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TouchEvents, TapDetector, DragDetector {
  
  late GameStateManager gameStateManager;
  late ResourceManager resourceManager;
  late VoxelWorld world;
  late ChunkManager chunkManager;
  late WorldSaveManager worldSaveManager;
  late PlayerController playerController;
  late EntitiesSystem entitiesSystem;
  late Renderer3D renderer;
  
  // Game configuration
  static const double WORLD_SIZE = 256.0;
  static const int CHUNK_SIZE = 16;
  static const int RENDER_DISTANCE = 8;
  static const double GRAVITY = -20.0;
  static const double PLAYER_HEIGHT = 1.7;
  static const double PLAYER_WIDTH = 0.3;
  
  // Input state
  final Map<String, bool> _keysPressed = {};
  Vector2? _touchStartPosition;
  Vector2? _lastTouchPosition;
  double _cameraYaw = 0.0;
  double _cameraPitch = 0.0;
  
  // Random for entity spawning
  final random = math.Random();
  
  EcoVerseGame({
    required this.gameStateManager,
    required this.resourceManager,
    required VoxelWorld world,
    required ChunkManager chunkManager,
    required this.worldSaveManager,
    required this.playerController,
  }) : world = world,
       chunkManager = chunkManager {
    renderer = Renderer3D(this);
    entitiesSystem = EntitiesSystem(this);
  }
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Load or create world
    await _loadOrCreateWorld();
    
    // Setup input handling
    setupInputHandling();
    
    // Add systems
    add(world);
    add(chunkManager);
    add(playerController);
    add(entitiesSystem);
    add(renderer);
    
    // Set up camera
    camera.viewfinder.anchor = CameraAnchor.center;
    
    // Switch to game mode
    await setOverlayActive('hud');
  }
  
  static int generateSeed() {
    return DateTime.now().millisecondsSinceEpoch % 1000000;
  }
  
  Future<void> _loadOrCreateWorld() async {
    final savedWorld = await worldSaveManager.loadWorld();
    if (savedWorld != null) {
      await world.deserialize(savedWorld.serialize());
      gameLogger.info('World loaded from save');
    } else {
      // Generate new procedural world
      await world.generateTerrain();
      await world.generateStructures();
      gameLogger.info('New world generated');
    }
  }
  
  void setupInputHandling() {
    // Keyboard
    keysDown.add((event) => _handleKeyDown(event));
    keysUp.add((event) => _handleKeyUp(event));
    
    // Touch
    touchesBegan.add(_handleTouchBegin);
    touchesMoved.add(_handleTouchMove);
    touchesEnded.add(_handleTouchEnd);
    
    // Mouse (desktop)
    tapDowns.add(_handleTapDown);
    dragsStarted.add(_handleDragStart);
    drags.add(_handleDrag);
    dragsEnded.add(_handleDragEnd);
  }
  
  void _handleKeyDown(KeyEvent event) {
    _keysPressed[event.logicalKey.keyLabel] = true;
    _updatePlayerInput();
    
    // Special key handlers
    if (event.logicalKey == LogicalKeyboardKey.keyE) {
      // Toggle inventory
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      gameStateManager.togglePause();
    }
    if (event.logicalKey == LogicalKeyboardKey.keyC) {
      // Toggle creative mode
      if (gameStateManager.currentMode.name == 'survival') {
        gameStateManager.startCreativeMode();
      } else {
        gameStateManager.startSurvivalMode();
      }
    }
  }
  
  void _handleKeyUp(KeyEvent event) {
    _keysPressed[event.logicalKey.keyLabel] = false;
    _updatePlayerInput();
  }
  
  void _handleTouchBegin(TouchEvent event) {
    _touchStartPosition = event.pos;
    _lastTouchPosition = event.pos;
  }
  
  void _handleTouchMove(TouchEvent event) {
    if (_touchStartPosition != null) {
      final delta = event.pos - _lastTouchPosition!;
      _handleCameraRotation(delta.x * 0.5, delta.y * 0.5);
      _lastTouchPosition = event.pos;
    }
  }
  
  void _handleTouchEnd(TouchEvent event) {
    _touchStartPosition = null;
    _lastTouchPosition = null;
  }
  
  void _handleTapDown(TapEvent event) {
    final pos = event.pos;
    // Handle block interaction
    _interactWithBlock(pos);
  }
  
  void _handleDragStart(DragStartEvent event) {
    _lastTouchPosition = event.localPosition;
  }
  
  void _handleDrag(DragEvent event) {
    if (_lastTouchPosition != null) {
      final delta = event.localPosition - _lastTouchPosition!;
      _handleCameraRotation(delta.x * 0.3, delta.y * 0.3);
      _lastTouchPosition = event.localPosition;
    }
  }
  
  void _handleDragEnd(DragEndEvent event) {
    _lastTouchPosition = null;
  }
  
  void _handleCameraRotation(double deltaX, double deltaY) {
    _cameraYaw += deltaX * 0.01;
    _cameraPitch -= deltaY * 0.01;
    _cameraPitch = math.max(-math.pi / 2, math.min(math.pi / 2, _cameraPitch));
    
    // Update camera
    camera.node.setAngles(_cameraYaw, _cameraPitch);
  }
  
  void _updatePlayerInput() {
    // WASD/Arrow keys for movement
    final forward = _keysPressed['W'] ?? _keysPressed['ArrowUp'] ?? false;
    final backward = _keysPressed['S'] ?? _keysPressed['ArrowDown'] ?? false;
    final left = _keysPressed['A'] ?? _keysPressed['ArrowLeft'] ?? false;
    final right = _keysPressed['D'] ?? _keysPressed['ArrowRight'] ?? false;
    final jump = _keysPressed[' '] ?? false;
    final sprint = _keysPressed['Shift'] ?? false;
    
    playerController.updateMovement(forward, backward, left, right, jump, sprint);
  }
  
  void _interactWithBlock(Vector2 screenPos) {
    // Raycast to find block under cursor/finger
    final ray = renderer.createRayFromScreen(screenPos);
    final hit = world.raycast(ray.origin, ray.direction, maxDistance: 10.0);
    
    if (hit != null) {
      final tool = playerController.selectedTool;
      
      switch (tool) {
        case ToolType.pickaxe:
        case ToolType.sword:
          // Break block
          world.breakBlock(hit.position);
          resourceManager.playSound('break');
          break;
        case ToolType.hoe:
          // Till soil
          world.breakBlock(hit.position);
          resourceManager.playSound('break');
          break;
        default:
          // Place block
          if (hit.faceNormal != null) {
            final placePos = hit.position + hit.faceNormal!.floorToInt32();
            world.placeBlock(placePos, playerController.selectedBlock);
            resourceManager.playSound('place');
          }
          break;
      }
    }
  }
  
  // Save/Load world
  Future<void> saveWorld() async {
    await worldSaveManager.saveWorld(world);
    gameStateManager.showNotification('World saved!');
  }
  
  // Game lifecycle
  void startCreativeMode() {
    gameStateManager.startCreativeMode();
  }
  
  void startSurvivalMode() {
    gameStateManager.startSurvivalMode();
  }
  
  void toggleDayNightCycle() {
    gameStateManager.toggleDayNightCycle();
  }
  
  void spawnEntity(EntityType type, Vector3 position) {
    entitiesSystem.spawn(type, position);
  }
  
  @override
  void onRemove() {
    // Clean up resources
    resourceManager.dispose();
    super.onRemove();
  }
}
