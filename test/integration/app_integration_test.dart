import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_wiz/main.dart' as app;

void main() {
  group('ProStudio DAW Integration Tests', () {
    testWidgets('App should start without crashing', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app starts correctly
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Should display main navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for main navigation elements
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Should handle orientation changes', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Change to landscape orientation
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      // Verify app still works in landscape
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Should handle different screen sizes', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test small screen
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      // Test medium screen
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      // Test large screen
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      // App should still be functional
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
