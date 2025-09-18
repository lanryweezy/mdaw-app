import 'package:flutter_test/flutter_test.dart';
import 'package:studio_wiz/view_models/timeline_view_model.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';

void main() {
  group('TimelineViewModel Tests', () {
    late TimelineViewModel timelineViewModel;
    late DawViewModel dawViewModel;

    setUp(() {
      // Initialize Flutter binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
      dawViewModel = DawViewModel();
      timelineViewModel = TimelineViewModel(dawViewModel);
    });

    tearDown(() {
      timelineViewModel.dispose();
      dawViewModel.dispose();
    });

    test('should initialize with default values', () {
      expect(timelineViewModel.currentPosition, Duration.zero);
      expect(timelineViewModel.isPlaying, false);
      expect(timelineViewModel.bpm, 120);
      expect(timelineViewModel.timeSignatureNumerator, 4);
      expect(timelineViewModel.timeSignatureDenominator, 4);
      expect(timelineViewModel.metronomeEnabled, false);
      expect(timelineViewModel.snapToGrid, true);
    });

    test('should seek to position', () {
      const targetPosition = Duration(seconds: 30);
      
      timelineViewModel.seekTo(targetPosition);
      expect(timelineViewModel.currentPosition, targetPosition);
    });

    test('should set BPM', () {
      const newBpm = 140;
      
      timelineViewModel.setBpm(newBpm);
      expect(timelineViewModel.bpm, newBpm);
    });

    test('should set time signature', () {
      const numerator = 3;
      const denominator = 4;
      
      timelineViewModel.setTimeSignature(numerator, denominator);
      
      expect(timelineViewModel.timeSignatureNumerator, numerator);
      expect(timelineViewModel.timeSignatureDenominator, denominator);
    });

    test('should toggle metronome', () {
      expect(timelineViewModel.metronomeEnabled, false);
      
      timelineViewModel.toggleMetronome();
      expect(timelineViewModel.metronomeEnabled, true);
      
      timelineViewModel.toggleMetronome();
      expect(timelineViewModel.metronomeEnabled, false);
    });

    test('should toggle snap to grid', () {
      expect(timelineViewModel.snapToGrid, true);
      
      timelineViewModel.toggleSnapToGrid();
      expect(timelineViewModel.snapToGrid, false);
      
      timelineViewModel.toggleSnapToGrid();
      expect(timelineViewModel.snapToGrid, true);
    });

    test('should handle undo and redo', () {
      expect(timelineViewModel.canUndo, false);
      expect(timelineViewModel.canRedo, false);
      
      // Simulate an action that can be undone
      timelineViewModel.setBpm(130);
      timelineViewModel.setBpm(140);
      
      expect(timelineViewModel.canUndo, true);
      
      timelineViewModel.undo();
      expect(timelineViewModel.bpm, 130);
      expect(timelineViewModel.canRedo, true);
      
      timelineViewModel.redo();
      expect(timelineViewModel.bpm, 140);
    });

    test('should notify listeners on state changes', () {
      bool listenerCalled = false;
      
      timelineViewModel.addListener(() {
        listenerCalled = true;
      });
      
      timelineViewModel.setBpm(130);
      expect(listenerCalled, true);
    });

    test('should validate BPM range', () {
      // Test minimum BPM
      timelineViewModel.setBpm(30);
      expect(timelineViewModel.bpm, 30);
      
      // Test maximum BPM
      timelineViewModel.setBpm(300);
      expect(timelineViewModel.bpm, 300);
    });

    test('should handle position updates during playback', () {
      // Simulate position update
      timelineViewModel.seekTo(const Duration(seconds: 5));
      expect(timelineViewModel.currentPosition, const Duration(seconds: 5));
      
      timelineViewModel.seekTo(const Duration(seconds: 10));
      expect(timelineViewModel.currentPosition, const Duration(seconds: 10));
    });

    test('should handle zoom level changes', () {
      expect(timelineViewModel.zoomLevel, 1.0);
      
      timelineViewModel.setZoomLevel(2.0);
      expect(timelineViewModel.zoomLevel, 2.0);
    });

    test('should handle grid size changes', () {
      const newGridSize = Duration(milliseconds: 500);
      timelineViewModel.setGridSize(newGridSize);
      expect(timelineViewModel.gridSize, newGridSize);
    });
  });
}
