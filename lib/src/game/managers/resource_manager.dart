import 'package:flutter/foundation.dart';
import '../voxel_types.dart';
import '../world/voxel_world.dart';

/// Manages game resources like textures, sounds, models
class ResourceManager extends ChangeNotifier {
  // Texture atlases
  final Map<VoxelType, TextureAtlas> _textureAtlases = {};
  
  // Sound effects
  final Map<String, AudioBuffer> _sounds = {};
  
  // Models
  final Map<String, Model3D> _models = {};
  
  // Load all resources
  Future<void> loadAllResources() async {
    await _loadTextures();
    await _loadSounds();
    await _loadModels();
  }
  
  Future<void> _loadTextures() async {
    // In production, this would load from asset files
    for (final type in VoxelType.values) {
      if (type != VoxelType.air) {
        _textureAtlases[type] = TextureAtlas(type);
      }
    }
    notifyListeners();
  }
  
  Future<void> _loadSounds() async {
    // Placeholder for sound loading
    _sounds['break'] = AudioBuffer(name: 'block_break', volume: 0.5);
    _sounds['place'] = AudioBuffer(name: 'block_place', volume: 0.4);
    _sounds['step'] = AudioBuffer(name: 'footstep', volume: 0.3);
    _sounds['hurt'] = AudioBuffer(name: 'hurt', volume: 0.6);
    _sounds['jump'] = AudioBuffer(name: 'jump', volume: 0.3);
    _sounds['explosion'] = AudioBuffer(name: 'explosion', volume: 0.8);
    notifyListeners();
  }
  
  Future<void> _loadModels() async {
    // Placeholder for model loading
    _models['player'] = Model3D(name: 'player', scale: Vector3.one);
    _models['zombie'] = Model3D(name: 'zombie', scale: Vector3.all(0.9));
    _models['skeleton'] = Model3D(name: 'skeleton', scale: Vector3.all(0.9));
    _models['creeper'] = Model3D(name: 'creeper', scale: Vector3.all(0.9));
    _models['chicken'] = Model3D(name: 'chicken', scale: Vector3.all(0.3));
    _models['cow'] = Model3D(name: 'cow', scale: Vector3.all(0.9));
    _models['pig'] = Model3D(name: 'pig', scale: Vector3.all(0.9));
    _models['sheep'] = Model3D(name: 'sheep', scale: Vector3.all(0.9));
    notifyListeners();
  }
  
  TextureAtlas? getTextureAtlas(VoxelType type) => _textureAtlases[type];
  bool hasTextureAtlas(VoxelType type) => _textureAtlases.containsKey(type);
  
  AudioBuffer? getSound(String name) => _sounds[name];
  
  Model3D? getModel(String name) => _models[name];
  
  void playSound(String name, {double volume = 1.0}) {
    final sound = _sounds[name];
    if (sound != null) {
      // Play sound logic here
      print('Playing sound: $name at volume $volume');
    }
  }
  
  void dispose() {
    _textureAtlases.clear();
    _sounds.clear();
    _models.clear();
    super.dispose();
  }
}

/// Texture atlas for a block type
class TextureAtlas {
  final VoxelType type;
  final List<Color> faceColors;
  final String texturePath;
  
  TextureAtlas(this.type) 
    : texturePath = 'assets/textures/${type.name}.png',
      faceColors = [
        blockProperties[type]?.color ?? Colors.grey,
      ];
}

/// Audio buffer for sound effects
class AudioBuffer {
  final String name;
  final double volume;
  final String path;
  
  AudioBuffer({
    required this.name,
    this.volume = 1.0,
    this.path = 'assets/sounds/$name.wav',
  });
}

/// 3D model placeholder
class Model3D {
  final String name;
  final Vector3 scale;
  final String path;
  
  Model3D({
    required this.name,
    required this.scale,
    this.path = 'assets/models/$name.obj',
  });
}
