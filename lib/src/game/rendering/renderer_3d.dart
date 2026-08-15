import 'package:flame/components.dart';
import 'package:vector_math/vector_math_64.dart';
import '../ecoverse_game.dart';
import '../world/voxel_types.dart';
import '../world/voxel_world.dart';

/// 3D Renderer using Flame's painter system
class Renderer3D extends Component {
  final EcoVerseGame game;
  
  // Camera settings
  late Vector3 _cameraPosition;
  late double _cameraYaw;
  late double _cameraPitch;
  
  // Lighting
  final Color ambientLight = const Color(200, 200, 200);
  final Color sunlight = const Color(255, 245, 230);
  
  // Day/night cycle
  double dayTime = 0.5; // 0 to 1, where 0.5 is noon
  bool dayNightCycle = true;
  
  // Visible chunks for rendering
  final Set<IntVector3> _visibleChunks = {};
  
  Renderer3D(this.game);
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
  }
  
  @override
  void update(double dt) {
    // Update camera position based on player
    if (game.playerController != null) {
      final playerPos = game.playerController.position;
      _cameraPosition = Vector3(
        playerPos.x,
        playerPos.y + 1.6,
        playerPos.z,
      );
      _cameraYaw = game._cameraYaw;
      _cameraPitch = game._cameraPitch;
    }
    
    // Update day/night cycle
    if (dayNightCycle) {
      dayTime += dt * 0.01; // Full cycle takes ~100 seconds
      if (dayTime > 1.0) dayTime -= 1.0;
    }
    
    // Update visible chunks
    _updateVisibleChunks();
  }
  
  void _updateVisibleChunks() {
    if (game.playerController == null) return;
    
    final playerChunkX = (game.playerController.position.x / game.world.chunkSize).floor();
    final playerChunkZ = (game.playerController.position.z / game.world.chunkSize).floor();
    
    final desiredChunks = <IntVector3>{};
    for (var dx = -game.chunkManager.renderDistance; dx <= game.chunkManager.renderDistance; dx++) {
      for (var dz = -game.chunkManager.renderDistance; dz <= game.chunkManager.renderDistance; dz++) {
        desiredChunks.add(IntVector3(playerChunkX + dx, 0, playerChunkZ + dz));
      }
    }
    
    _visibleChunks.addAll(desiredChunks);
  }
  
  /// Create a ray from screen coordinates
  Ray createRayFromScreen(Vector2 screenPos) {
    final width = game.size.x;
    final height = game.size.y;
    
    // Normalized device coordinates (-1 to 1)
    final ndcX = (screenPos.x / width) * 2 - 1;
    final ndcY = -(screenPos.y / height) * 2 + 1;
    
    // Create ray direction from camera
    final fov = math.pi / 3;
    final aspect = width / height;
    
    final rayDir = Vector3(
      ndcX * math.tan(fov / 2) * aspect,
      ndcY * math.tan(fov / 2),
      -1,
    );
    
    // Apply rotation
    final yaw = _cameraYaw;
    final pitch = _cameraPitch;
    
    rayDir.rotateY(yaw);
    rayDir.rotateX(pitch);
    
    return Ray(_cameraPosition, rayDir.normalize());
  }
  
  /// Get sky color based on time of day
  Color getSkyColor() {
    final t = dayTime;
    // Simple gradient: night -> dawn -> day -> dusk -> night
    if (t < 0.25) {
      // Night to dawn
      return Color.lerp(const Color(10, 10, 30), const Color(255, 150, 100), t * 4) ?? Colors.black;
    } else if (t < 0.5) {
      // Dawn to day
      return Color.lerp(const Color(255, 150, 100), const Color(135, 206, 235), (t - 0.25) * 4) ?? Colors.blue;
    } else if (t < 0.75) {
      // Day to dusk
      return Color.lerp(const Color(135, 206, 235), const Color(255, 100, 50), (t - 0.5) * 4) ?? Colors.orange;
    } else {
      // Dusk to night
      return Color.lerp(const Color(255, 100, 50), const Color(10, 10, 30), (t - 0.75) * 4) ?? Colors.black;
    }
  }
  
  /// Get lighting intensity for the scene
  double getLightIntensity() {
    return (math.sin(dayTime * math.pi * 2) * 0.5 + 0.5).clamp(0.0, 1.0);
  }
  
  /// Get sun direction based on day time
  Vector3 getSunDirection() {
    final angle = dayTime * math.pi * 2;
    return Vector3(
      math.cos(angle),
      math.sin(angle),
      0.5,
    ).normalize();
  }
}
