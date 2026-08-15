import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../world/voxel_world.dart';
import '../world/voxel_types.dart';

class WorldSaveManager {
  static const String _saveKey = 'ecoverse_world_save';

  Future<void> saveWorld(VoxelWorld world) async {
    final prefs = await SharedPreferences.getInstance();
    final data = _serializeWorld(world);
    prefs.setString(_saveKey, jsonEncode(data));
  }

  Map<String, dynamic> _serializeWorld(VoxelWorld world) {
    return {
      'seed': world.seed,
      'chunks': {},
    };
  }

  Future<VoxelWorld> loadWorld() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_saveKey);
    if (jsonString == null) {
      return VoxelWorld(seed: 42);
    }
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return VoxelWorld(seed: data['seed'] ?? 42);
  }
}