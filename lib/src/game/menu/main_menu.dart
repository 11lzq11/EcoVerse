// Main menu placeholder
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../ecoverse_game.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late EcoVerseGame _game;
  
  @override
  void initState() {
    super.initState();
    _game = EcoVerseGame();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EcoVerse'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => GameWidget(game: _game),
                  ),
                );
              },
              child: Text('开始游戏'),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }
}
