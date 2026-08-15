import 'package:flutter/foundation.dart';
import '../world/voxel_types.dart';

/// Manages game state like mode, pause, notifications
class GameStateManager extends ChangeNotifier {
  GameMode _currentMode = GameMode.survival;
  bool _isGameStarted = false;
  bool _isPaused = false;
  String _currentNotification = '';
  int _notificationDuration = 3; // seconds
  
  GameMode get currentMode => _currentMode;
  bool get isGameStarted => _isGameStarted;
  bool get isPaused => _isPaused;
  String get notification => _currentNotification;
  
  Future<void> startNewGame() async {
    _isGameStarted = true;
    _isPaused = false;
    notifyListeners();
  }
  
  Future<void> loadWorld() async {
    // World loading handled by Game instance
    _isGameStarted = true;
    notifyListeners();
  }
  
  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }
  
  void setPause(bool paused) {
    _isPaused = paused;
    notifyListeners();
  }
  
  void startCreativeMode() {
    _currentMode = GameMode.creative;
    // Give player creative items
    notifyListeners();
  }
  
  void startSurvivalMode() {
    _currentMode = GameMode.survival;
    notifyListeners();
  }
  
  void toggleDayNightCycle() {
    // This would be handled by the renderer
    notifyListeners();
  }
  
  void showNotification(String message, {int durationSeconds = 3}) {
    _currentNotification = message;
    _notificationDuration = durationSeconds;
    notifyListeners();
    
    // Clear after duration
    Future.delayed(Duration(seconds: durationSeconds), () {
      if (_currentNotification == message) {
        _currentNotification = '';
        notifyListeners();
      }
    });
  }
  
  void clearNotification() {
    _currentNotification = '';
    notifyListeners();
  }
  
  void quitGame() {
    _isGameStarted = false;
    _isPaused = false;
    notifyListeners();
  }
}
