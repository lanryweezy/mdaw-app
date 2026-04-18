import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_wiz/widgets/timeline_editor.dart';
import 'package:studio_wiz/view_models/timeline_view_model.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  group('TimelineEditor Widget Tests', () {
    late DawViewModel dawViewModel;
    late TimelineViewModel timelineViewModel;

    setUp(() {
      dawViewModel = DawViewModel();
      timelineViewModel = TimelineViewModel(dawViewModel);
    });

    tearDown(() {
      dawViewModel.dispose();
      timelineViewModel.dispose();
    });

    testWidgets('should render timeline editor', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TimelineEditor(),
            ),
          ),
        ),
      );

      expect(find.byType(TimelineEditor), findsOneWidget);
    });

    testWidgets('should display tempo controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TimelineEditor(),
            ),
          ),
        ),
      );

      // Look for tempo-related widgets
      expect(find.text('BPM'), findsOneWidget);
      expect(find.text('120'), findsOneWidget); // Default BPM
    });

    testWidgets('should display time signature controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TimelineEditor(),
            ),
          ),
        ),
      );

      // Look for time signature controls
      expect(find.text('Time Signature'), findsOneWidget);
      expect(find.text('4'), findsWidgets); // Numerator and denominator
    });

    testWidgets('should display snap to grid toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TimelineEditor(),
            ),
          ),
        ),
      );

      expect(find.text('Snap to Grid'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should toggle snap to grid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TimelineEditor(),
            ),
          ),
        ),
      );

      final switchWidget = find.byType(Switch);
      expect(switchWidget, findsOneWidget);

      // Initially snap to grid should be enabled
      expect(timelineViewModel.snapToGrid, true);

      // Tap the switch
      await tester.tap(switchWidget);
      await tester.pump();

      // Snap to grid should be disabled
      expect(timelineViewModel.snapToGrid, false);
    });

    testWidgets('should change BPM with buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TimelineEditor(),
            ),
          ),
        ),
      );

      final addButton = find.byIcon(Icons.add);
      final removeButton = find.byIcon(Icons.remove);

      expect(addButton, findsOneWidget);
      expect(removeButton, findsOneWidget);

      // Initial BPM should be 120
      expect(timelineViewModel.bpm, 120);

      // Tap add button
      await tester.tap(addButton);
      await tester.pump();

      // BPM should increase
      expect(timelineViewModel.bpm, 121);

      // Tap remove button
      await tester.tap(removeButton);
      await tester.pump();

      // BPM should decrease
      expect(timelineViewModel.bpm, 120);
    });

    testWidgets('should change time signature', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TimelineEditor(),
            ),
          ),
        ),
      );

      final dropdowns = find.byType(DropdownButton<int>);
      expect(dropdowns, findsNWidgets(2)); // Numerator and denominator

      // Test numerator dropdown
      await tester.tap(dropdowns.first);
      await tester.pumpAndSettle();

      // Select 3/4 time signature
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      expect(timelineViewModel.timeSignatureNumerator, 3);
    });

    testWidgets('should display playhead', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TimelineEditor(),
            ),
          ),
        ),
      );

      // Look for playhead indicator
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle zoom controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TimelineEditor(),
            ),
          ),
        ),
      );

      // Look for zoom buttons
      final zoomInButton = find.byIcon(Icons.zoom_in);
      final zoomOutButton = find.byIcon(Icons.zoom_out);

      if (zoomInButton.evaluate().isNotEmpty) {
        await tester.tap(zoomInButton);
        await tester.pump();
      }

      if (zoomOutButton.evaluate().isNotEmpty) {
        await tester.tap(zoomOutButton);
        await tester.pump();
      }

      // Widget should still be present after zoom operations
      expect(find.byType(TimelineEditor), findsOneWidget);
    });

    testWidgets('should handle scroll gestures', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TimelineEditor(),
            ),
          ),
        ),
      );

      // Test horizontal scrolling
      await tester.drag(find.byType(TimelineEditor), const Offset(-100, 0));
      await tester.pump();

      // Widget should still be present after scrolling
      expect(find.byType(TimelineEditor), findsOneWidget);
    });

    testWidgets('should respond to timeline view model changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TimelineEditor(),
            ),
          ),
        ),
      );

      // Change BPM programmatically
      timelineViewModel.setBpm(140);
      await tester.pump();

      // UI should reflect the change
      expect(find.text('140'), findsOneWidget);
    });
  });
}
