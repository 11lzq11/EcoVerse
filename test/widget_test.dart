import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoverse/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(EcoVerseApp());
    
    expect(find.text('EcoVerse'), findsOneWidget);
  });
}
