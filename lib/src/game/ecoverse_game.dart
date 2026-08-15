import 'package:flame/game.dart';
import 'managers/resource_manager.dart';
import 'entities/entities_system.dart';
import 'entities/player/player_controller.dart';
import 'world/chunk_manager.dart';
import 'world/voxel_world.dart';

class EcoVerseGame extends FlameGame {
  late VoxelWorld voxelWorld;
  late ChunkManager chunkManager;
  late PlayerController playerController;
  late ResourceManager resourceManager;
  late EntitiesSystem entitiesSystem;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    resourceManager = ResourceManager();
    await resourceManager.loadAll();

    voxelWorld = VoxelWorld(seed: 42);
    voxelWorld.generateTerrain();

    playerController = PlayerController(
      position: voxelWorld.playerPosition,
      game: this,
    );
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
    chunkManager.updateChunks(playerController.position);
    camera.viewfinder.position = playerController.position;
  }
}
