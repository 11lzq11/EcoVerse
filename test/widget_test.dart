import 'package:flutter_test/flutter_test.dart';
import 'package:ecoverse/main.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(const EcoVerseApp());
    expect(find.byType(EcoVerseApp), findsOneWidget);
  });
}
