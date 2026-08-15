// World renderer placeholder
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'renderer_3d.dart';
import '../world/voxel_world.dart';

class WorldRenderer extends Component {
  final Renderer3D _renderer;
  final VoxelWorld world;
  
  WorldRenderer(this._renderer) : world = _renderer.world;
  
  @override
  void render(Canvas canvas) {
    _renderer.render(canvas);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
  }
}
