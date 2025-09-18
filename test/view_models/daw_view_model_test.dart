import 'package:flutter_test/flutter_test.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';

void main() {
  group('DawViewModel Tests', () {
    late DawViewModel dawViewModel;

    setUp(() {
      // Initialize Flutter binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
      dawViewModel = DawViewModel();
    });

    tearDown(() {
      dawViewModel.dispose();
    });

    test('should initialize with default values', () {
      expect(dawViewModel.isPlaying, false);
      expect(dawViewModel.isRecording, false);
      expect(dawViewModel.currentPlaybackPosition, Duration.zero);
      expect(dawViewModel.beatTrack.name, 'Beat');
      expect(dawViewModel.vocalTracks.length, 7);
    });

    test('should have beat track initialized', () {
      expect(dawViewModel.beatTrack.id, 'beat');
      expect(dawViewModel.beatTrack.name, 'Beat');
      expect(dawViewModel.beatTrack.muted, false);
      expect(dawViewModel.beatTrack.soloed, false);
      expect(dawViewModel.beatTrack.hasAudio, false);
    });

    test('should have vocal tracks initialized', () {
      expect(dawViewModel.vocalTracks.length, 7);
      
      for (int i = 0; i < 7; i++) {
        final track = dawViewModel.vocalTracks[i];
        expect(track.id, 'vocal_${i + 1}');
        expect(track.name, 'Vocal ${i + 1}');
        expect(track.muted, false);
        expect(track.soloed, false);
        expect(track.hasAudio, false);
      }
    });

    test('should handle track mute state', () {
      final track = dawViewModel.vocalTracks.first;
      
      expect(track.muted, false);
      
      track.muted = true;
      expect(track.muted, true);
      
      track.muted = false;
      expect(track.muted, false);
    });

    test('should handle track solo state', () {
      final track = dawViewModel.vocalTracks.first;
      
      expect(track.soloed, false);
      
      track.soloed = true;
      expect(track.soloed, true);
      
      track.soloed = false;
      expect(track.soloed, false);
    });

    test('should handle beat track mute state', () {
      expect(dawViewModel.beatTrack.muted, false);
      
      dawViewModel.beatTrack.muted = true;
      expect(dawViewModel.beatTrack.muted, true);
      
      dawViewModel.beatTrack.muted = false;
      expect(dawViewModel.beatTrack.muted, false);
    });

    test('should handle beat track solo state', () {
      expect(dawViewModel.beatTrack.soloed, false);
      
      dawViewModel.beatTrack.soloed = true;
      expect(dawViewModel.beatTrack.soloed, true);
      
      dawViewModel.beatTrack.soloed = false;
      expect(dawViewModel.beatTrack.soloed, false);
    });

    test('should track hasAudio correctly', () {
      final track = dawViewModel.vocalTracks.first;
      
      expect(track.hasAudio, false);
      expect(track.clips.isEmpty, true);
    });

    test('should handle mixed vocal track', () {
      expect(dawViewModel.mixedVocalTrack, isNull);
    });

    test('should handle mastered song track', () {
      expect(dawViewModel.masteredSongTrack, isNull);
    });

    test('should notify listeners on state changes', () {
      bool listenerCalled = false;
      
      dawViewModel.addListener(() {
        listenerCalled = true;
      });
      
      // Trigger a state change
      dawViewModel.beatTrack.muted = true;
      dawViewModel.notifyListeners();
      
      expect(listenerCalled, true);
    });

    test('should handle track IDs correctly', () {
      expect(dawViewModel.beatTrack.id, 'beat');
      
      for (int i = 0; i < dawViewModel.vocalTracks.length; i++) {
        expect(dawViewModel.vocalTracks[i].id, 'vocal_${i + 1}');
      }
    });

    test('should handle track names correctly', () {
      expect(dawViewModel.beatTrack.name, 'Beat');
      
      for (int i = 0; i < dawViewModel.vocalTracks.length; i++) {
        expect(dawViewModel.vocalTracks[i].name, 'Vocal ${i + 1}');
      }
    });

    test('should handle multiple track mute states', () {
      // Mute first vocal track
      dawViewModel.vocalTracks[0].muted = true;
      expect(dawViewModel.vocalTracks[0].muted, true);
      
      // Mute second vocal track
      dawViewModel.vocalTracks[1].muted = true;
      expect(dawViewModel.vocalTracks[1].muted, true);
      
      // Other tracks should remain unmuted
      expect(dawViewModel.vocalTracks[2].muted, false);
    });

    test('should handle multiple track solo states', () {
      // Solo first vocal track
      dawViewModel.vocalTracks[0].soloed = true;
      expect(dawViewModel.vocalTracks[0].soloed, true);
      
      // Solo second vocal track
      dawViewModel.vocalTracks[1].soloed = true;
      expect(dawViewModel.vocalTracks[1].soloed, true);
      
      // Other tracks should remain unsoloed
      expect(dawViewModel.vocalTracks[2].soloed, false);
    });

    test('should validate track structure', () {
      // All tracks should have clips list
      expect(dawViewModel.beatTrack.clips, isA<List>());
      
      for (final track in dawViewModel.vocalTracks) {
        expect(track.clips, isA<List>());
      }
    });
  });
}
