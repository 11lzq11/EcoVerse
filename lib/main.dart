import 'package:flutter/material.dart';
import 'src/game/game_page.dart';

void main() {
  runApp(const EcoVerseApp());
}

class EcoVerseApp extends StatelessWidget {
  const EcoVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoVerse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: const EcoVerseGamePage(),
    );
  }
}
