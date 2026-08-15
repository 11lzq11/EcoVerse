import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import 'src/game/ecoverse_game.dart';
import 'src/game/managers/game_state_manager.dart';
import 'src/game/managers/resource_manager.dart';
import 'src/game/world/voxel_world.dart';
import 'src/game/world/chunk_manager.dart';
import 'src/game/entities/player/player_controller.dart';
import 'src/game/save_system/world_save_manager.dart';
import 'src/game/ui/hud/hud_widget.dart';
import 'src/game/menu/main_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Enable immersive mode on mobile
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(const EcoVerseApp());
}

class EcoVerseApp extends StatefulWidget {
  const EcoVerseApp({super.key});

  @override
  State<EcoVerseApp> createState() => _EcoVerseAppState();
}

class _EcoVerseAppState extends State<EcoVerseApp> with WidgetsBindingObserver {
  EcoVerseGame? _game;
  final _gameStateManager = GameStateManager();
  final _resourceManager = ResourceManager();
  late final _worldSaveManager;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeGame();
  }
  
  Future<void> _initializeGame() async {
    _worldSaveManager = WorldSaveManager();
    await _worldSaveManager.init();
    
    final world = VoxelWorld(
      worldSize: EcoVerseGame.WORLD_SIZE,
      chunkSize: EcoVerseGame.CHUNK_SIZE,
      seed: EcoVerseGame.generateSeed(),
    );
    
    final chunkManager = ChunkManager(
      world: world,
      renderDistance: EcoVerseGame.RENDER_DISTANCE,
    );
    
    final playerController = PlayerController(world: world);
    
    setState(() {
      _game = EcoVerseGame(
        gameStateManager: _gameStateManager,
        resourceManager: _resourceManager,
        world: world,
        chunkManager: chunkManager,
        worldSaveManager: _worldSaveManager,
        playerController: playerController,
      );
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        if (_game != null && _game!.world != null) {
          _game!.saveWorld();
        }
        break;
      case AppLifecycleState.resumed:
        break;
      default:
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _gameStateManager),
        ChangeNotifierProvider.value(value: _resourceManager),
      ],
      child: MaterialApp(
        title: '灵境 EcoVerse',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: Scaffold(
          body: _game != null 
            ? Stack(
                children: [
                  Positioned.fill(
                    child: GameWidget<EcoVerseGame>(
                      game: _game!,
                      overlayBuilderMap: {
                        'hud': (context, game) => const HudWidget(),
                        'mainMenu': (context, game) => _buildMainMenuOverlay(),
                      },
                      initialActiveOverlays: const ['mainMenu'],
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
  
  Widget _buildMainMenuOverlay() {
    return FutureBuilder<bool>(
      future: _checkForSave(),
      builder: (context, snapshot) {
        return MainMenuScreen(hasSave: snapshot.data ?? false);
      },
    );
  }
  
  Future<bool> _checkForSave() async {
    return _worldSaveManager.hasSavedWorld();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
