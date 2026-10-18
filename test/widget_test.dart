import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worldsports/main.dart';

void main() {
  testWidgets('WorldSports app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WorldSportsApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
