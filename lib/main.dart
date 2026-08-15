import 'package:flutter/material.dart';
import 'src/game/menu/main_menu.dart';

void main() {
  runApp(EcoVerseApp());
}

class EcoVerseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoVerse',
      theme: ThemeData(primarySwatch: Colors.green, brightness: Brightness.dark),
      home: MainMenu(),
    );
  }
}
