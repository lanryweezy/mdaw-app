import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_wiz/screens/enhanced_daw_screen.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:studio_wiz/view_models/timeline_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  group('EnhancedDawScreen Widget Tests', () {
    late DawViewModel dawViewModel;
    late TimelineViewModel timelineViewModel;

    setUp(() {
      dawViewModel = DawViewModel();
      timelineViewModel = TimelineViewModel(dawViewModel); // Pass DawViewModel to constructor
    });

    tearDown(() {
      dawViewModel.dispose();
      timelineViewModel.dispose();
    });

    testWidgets('should render enhanced DAW screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: EnhancedDawScreen(),
          ),
        ),
      );

      expect(find.byType(EnhancedDawScreen), findsOneWidget);
    });

    testWidgets('should display tab bar with correct tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: EnhancedDawScreen(),
          ),
        ),
      );

      // Check for tab bar
      expect(find.byType(TabBar), findsOneWidget);
      
      // Check for tab labels
      expect(find.text('Timeline'), findsOneWidget);
      expect(find.text('Mix'), findsOneWidget);
      expect(find.text('AI Tools'), findsOneWidget);
    });

    testWidgets('should switch between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: EnhancedDawScreen(),
          ),
        ),
      );

      // Tap on Mix tab
      await tester.tap(find.text('Mix'));
      await tester.pumpAndSettle();

      // Tap on AI Tools tab
      await tester.tap(find.text('AI Tools'));
      await tester.pumpAndSettle();

      // Tap on Timeline tab
      await tester.tap(find.text('Timeline'));
      await tester.pumpAndSettle();

      // All tabs should be accessible
      expect(find.text('Timeline'), findsOneWidget);
      expect(find.text('Mix'), findsOneWidget);
      expect(find.text('AI Tools'), findsOneWidget);
    });

    testWidgets('should display transport controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: EnhancedDawScreen(),
          ),
        ),
      );

      // Look for transport control buttons
      expect(find.byIcon(Icons.play_circle_filled), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('should toggle play/pause', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: EnhancedDawScreen(),
          ),
        ),
      );

      final playButton = find.byIcon(Icons.play_circle_filled);
      expect(playButton, findsOneWidget);

      // Initially not playing
      expect(dawViewModel.isPlaying, false);

      // Tap play button
      await tester.tap(playButton);
      await tester.pump();

      // Should be playing now
      expect(dawViewModel.isPlaying, true);

      // Button should change to pause
      expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);
    });

    testWidgets('should display undo/redo buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: EnhancedDawScreen(),
          ),
        ),
      );

      // Look for undo/redo buttons in app bar
      expect(find.byIcon(Icons.undo), findsOneWidget);
      expect(find.byIcon(Icons.redo), findsOneWidget);
    });

    testWidgets('should display metronome toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: EnhancedDawScreen(),
          ),
        ),
      );

      // Look for metronome button
      final metronomeButton = find.byIcon(Icons.music_off);
      expect(metronomeButton, findsOneWidget);

      // Tap metronome button
      await tester.tap(metronomeButton);
      await tester.pump();

      // Metronome should be enabled
      expect(timelineViewModel.metronomeEnabled, true);
    });

    testWidgets('should display tempo controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: EnhancedDawScreen(),
          ),
        ),
      );

      // Switch to Timeline tab
      await tester.tap(find.text('Timeline'));
      await tester.pumpAndSettle();

      // Look for tempo controls
      expect(find.text('BPM'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('should display time signature controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: EnhancedDawScreen(),
          ),
        ),
      );

      // Switch to Timeline tab
      await tester.tap(find.text('Timeline'));
      await tester.pumpAndSettle();

      // Look for time signature controls
      expect(find.text('Time Signature'), findsOneWidget);
      expect(find.byType(DropdownButton<int>), findsNWidgets(2));
    });

    testWidgets('should display professional editing controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: EnhancedDawScreen(),
          ),
        ),
      );

      // Switch to Timeline tab
      await tester.tap(find.text('Timeline'));
      await tester.pumpAndSettle();

      // Look for professional controls
      expect(find.text('Zoom In'), findsOneWidget);
      expect(find.text('Zoom Out'), findsOneWidget);
      expect(find.text('Fit to Screen'), findsOneWidget);
      expect(find.text('Duplicate'), findsOneWidget);
    });

    testWidgets('should handle landscape orientation', (WidgetTester tester) async {
      // Set landscape orientation
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: EnhancedDawScreen(),
          ),
        ),
      );

      // Should still render correctly in landscape
      expect(find.byType(EnhancedDawScreen), findsOneWidget);
    });

    testWidgets('should display AI tools tab content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: EnhancedDawScreen(),
          ),
        ),
      );

      // Switch to AI Tools tab
      await tester.tap(find.text('AI Tools'));
      await tester.pumpAndSettle();

      // Look for AI tools content
      expect(find.text('Vocal Mixing'), findsOneWidget);
      expect(find.text('Mastering'), findsOneWidget);
    });

    testWidgets('should display mix tab content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dawViewModel),
            ChangeNotifierProvider.value(value: timelineViewModel),
          ],
          child: const MaterialApp(
            home: EnhancedDawScreen(),
          ),
        ),
      );

      // Switch to Mix tab
      await tester.tap(find.text('Mix'));
      await tester.pumpAndSettle();

      // Should display mix controls
      expect(find.byType(EnhancedDawScreen), findsOneWidget);
    });
  });
}
