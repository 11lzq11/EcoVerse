import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';

class EcoVerseGame extends FlameGame with HasKeyboardHandlerComponents {
  final Map<LogicalKeyboardKey, bool> keysDown = {};

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keys) {
    final key = event.logicalKey;
    if (event is RawKeyDownEvent) {
      keysDown[key] = true;
    } else if (event is RawKeyUpEvent) {
      keysDown[key] = false;
    }
    return super.onKeyEvent(event, keys);
  }
}
