import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_wiz/screens/settings_screen.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    testWidgets('should render settings screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('should display all setting sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Wait for the screen to load
      await tester.pump();

      // Check for section headers
      expect(find.text('Audio Settings'), findsOneWidget);
      expect(find.text('Export Settings'), findsOneWidget);
      expect(find.text('UI Settings'), findsOneWidget);
      expect(find.text('Advanced Settings'), findsOneWidget);
    });

    testWidgets('should display master volume slider', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Look for master volume slider
      expect(find.text('Master Volume'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('should display audio quality dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Look for audio quality dropdown
      expect(find.text('Audio Quality'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('should display bit depth dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Look for bit depth dropdown
      expect(find.text('Bit Depth'), findsOneWidget);
    });

    testWidgets('should display export format dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Look for export format dropdown
      expect(find.text('Default Export Format'), findsOneWidget);
    });

    testWidgets('should display export bitrate slider', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Look for export bitrate slider
      expect(find.text('Export Bitrate (kbps)'), findsOneWidget);
    });

    testWidgets('should display normalize audio switch', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Look for normalize audio switch
      expect(find.text('Normalize Audio'), findsOneWidget);
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('should display dark mode switch', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Look for dark mode switch
      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('should display waveform height slider', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Look for waveform height slider
      expect(find.text('Waveform Height'), findsOneWidget);
    });

    testWidgets('should display show waveforms switch', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Look for show waveforms switch
      expect(find.text('Show Waveforms'), findsOneWidget);
    });

    testWidgets('should display low latency switch', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Look for low latency switch
      expect(find.text('Enable Low Latency'), findsOneWidget);
    });

    testWidgets('should display buffer size slider', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Look for buffer size slider
      expect(find.text('Buffer Size'), findsOneWidget);
    });

    testWidgets('should display cloud sync switch', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Look for cloud sync switch
      expect(find.text('Enable Cloud Sync'), findsOneWidget);
    });

    testWidgets('should handle dropdown interactions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Find and tap audio quality dropdown
      final dropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(dropdown);
      await tester.pump();

      // Should show dropdown options
      expect(find.text('Low (22kHz)'), findsOneWidget);
      expect(find.text('Medium (44.1kHz)'), findsOneWidget);
      expect(find.text('High (48kHz)'), findsOneWidget);
      expect(find.text('Professional (96kHz)'), findsOneWidget);
    });

    testWidgets('should handle slider interactions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Find master volume slider
      final slider = find.byType(Slider).first;
      
      // Drag slider to change value
      await tester.drag(slider, const Offset(50, 0));
      await tester.pump();

      // Slider should still be present
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('should handle switch interactions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Find first switch
      final switchWidget = find.byType(Switch).first;
      
      // Tap switch to toggle
      await tester.tap(switchWidget);
      await tester.pump();

      // Switch should still be present
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('should display reset to defaults button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Look for reset button
      expect(find.text('Reset to Defaults'), findsOneWidget);
    });

    testWidgets('should handle reset button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Find and tap reset button
      final resetButton = find.text('Reset to Defaults');
      await tester.tap(resetButton);
      await tester.pump();

      // Should show confirmation dialog or reset settings
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}
