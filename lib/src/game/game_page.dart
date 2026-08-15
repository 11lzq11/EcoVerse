import 'package:ecoverse/src/game/ecoverse_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class EcoVerseGamePage extends StatelessWidget {
  const EcoVerseGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EcoVerse')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('EcoVerse - Coming Soon'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: null,
              child: Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}
