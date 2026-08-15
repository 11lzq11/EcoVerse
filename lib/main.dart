import 'dart:async';
import 'package:ecoverse/src/game/ecoverse_game.dart';
import 'package:ecoverse/src/game/menu/main_menu.dart';
import 'package:ecoverse/src/game/managers/game_state_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameStateManager()),
      ],
      child: EcoVerseApp(),
    ),
  );
}

class EcoVerseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoVerse',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: MainMenu(),
    );
  }
}
