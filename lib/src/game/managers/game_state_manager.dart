import 'package:flutter/material.dart';

enum GameMode { survival, creative }

class GameStateManager extends ChangeNotifier {
  GameMode _currentMode = GameMode.creative;
  bool _isSaving = false;
  
  GameMode get currentMode => _currentMode;
  bool get isSaving => _isSaving;
  
  void setGameMode(GameMode mode) {
    _currentMode = mode;
    notifyListeners();
  }
  
  Future<void> saveWorld(String path) async {
    _isSaving = true;
    notifyListeners();
    // Simulate save operation
    await Future.delayed(const Duration(milliseconds: 500));
    _isSaving = false;
    notifyListeners();
  }
}
