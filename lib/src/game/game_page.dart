import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'ecoverse_game.dart';

class EcoVerseGamePage extends StatelessWidget {
  const EcoVerseGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: EcoVerseGame()),
    );
  }
}
