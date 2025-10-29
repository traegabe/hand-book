import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hand_book/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HandBookApp());

    // Verify that our app starts with the Login Screen
    expect(find.text('Hand Book'), findsOneWidget);
    expect(find.text('Sua biblioteca sempre à mão'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // Email and Password fields
  });

  testWidgets('Login screen has all required elements', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HandBookApp());

    // Verify that login screen has all required elements
    expect(find.text('Hand Book'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar nova conta'), findsOneWidget);
    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });
}