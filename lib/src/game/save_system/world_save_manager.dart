import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../voxel_types.dart';
import '../world/voxel_world.dart';

/// Manages saving and loading of world data
class WorldSaveManager {
  static const String _saveKey = 'ecoverse_world_data';
  static const String _lastSeedKey = 'ecoverse_last_seed';
  static const String _playerPosKey = 'ecoverse_player_pos';
  
  SharedPreferences? _prefs;
  
  WorldSaveManager();
  
  /// Initialize with SharedPreferences instance
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Save world to preferences
  Future<bool> saveWorld(VoxelWorld world) async {
    if (_prefs == null) await init();
    
    try {
      final data = world.serialize();
      final json = _encodeWorldData(data);
      
      await _prefs!.setString(_saveKey, json);
      await _prefs!.setInt(_lastSeedKey, world.seed);
      
      return true;
    } catch (e) {
      print('Error saving world: $e');
      return false;
    }
  }
  
  /// Load world from preferences
  Future<VoxelWorld?> loadWorld() async {
    if (_prefs == null) await init();
    
    try {
      final jsonString = _prefs!.getString(_saveKey);
      if (jsonString == null) return null;
      
      final data = _decodeWorldData(jsonString);
      final seed = _prefs!.getInt(_lastSeedKey) ?? 0;
      
      final world = VoxelWorld(
        worldSize: 256,
        chunkSize: 16,
        seed: seed,
      );
      await world.deserialize(data);
      
      return world;
    } catch (e) {
      print('Error loading world: $e');
      return null;
    }
  }
  
  /// Save player position
  Future<void> savePlayerPosition(Vector3 position) async {
    if (_prefs == null) await init();
    
    try {
      final posData = {
        'x': position.x.toStringAsFixed(2),
        'y': position.y.toStringAsFixed(2),
        'z': position.z.toStringAsFixed(2),
      };
      await _prefs!.setString(_playerPosKey, posData.entries.map((e) => '${e.key}:${e.value}').join(','));
    } catch (e) {
      print('Error saving player position: $e');
    }
  }
  
  /// Load player position
  Vector3? loadPlayerPosition() {
    if (_prefs == null) return null;
    
    try {
      final posStr = _prefs!.getString(_playerPosKey);
      if (posStr == null) return null;
      
      final parts = posStr.split(',');
      final values = <String, double>{};
      for (final part in parts) {
        final kv = part.split(':');
        if (kv.length == 2) {
          values[kv[0]] = double.parse(kv[1]);
        }
      }
      
      return Vector3(values['x'] ?? 128, values['y'] ?? 64, values['z'] ?? 128);
    } catch (e) {
      print('Error loading player position: $e');
      return null;
    }
  }
  
  /// Delete saved world
  Future<bool> deleteWorld() async {
    if (_prefs == null) await init();
    await _prefs!.remove(_saveKey);
    await _prefs!.remove(_lastSeedKey);
    await _prefs!.remove(_playerPosKey);
    return true;
  }
  
  /// Check if a world is saved
  bool hasSavedWorld() {
    if (_prefs == null) return false;
    return _prefs!.containsKey(_saveKey);
  }
  
  String _encodeWorldData(List<Map<String, dynamic>> data) {
    final buffer = StringBuffer();
    buffer.write('[');
    for (var i = 0; i < data.length; i++) {
      if (i > 0) buffer.write(',');
      final entry = data[i];
      buffer.write('{');
      buffer.write('"x":${entry['x']},');
      buffer.write('"y":${entry['y']},');
      buffer.write('"z":${entry['z']},');
      buffer.write('"type":${entry['type']}');
      buffer.write('}');
    }
    buffer.write(']');
    return buffer.toString();
  }
  
  List<Map<String, dynamic>> _decodeWorldData(String json) {
    final data = <Map<String, dynamic>>[];
    final content = json.substring(1, json.length - 1);
    
    var i = 0;
    while (i < content.length) {
      final start = content.indexOf('{', i);
      if (start == -1) break;
      final end = content.indexOf('}', start);
      if (end == -1) break;
      
      final objStr = content.substring(start + 1, end);
      final obj = <String, dynamic>{};
      
      final pairs = objStr.split(',');
      for (final pair in pairs) {
        final kv = pair.split(':');
        if (kv.length == 2) {
          final key = kv[0].replaceAll('"', '');
          obj[key] = int.parse(kv[1]);
        }
      }
      
      data.add(obj);
      i = end + 1;
    }
    
    return data;
  }
}
