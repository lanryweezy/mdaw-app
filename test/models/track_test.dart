import 'package:flutter_test/flutter_test.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:studio_wiz/models/audio_clip.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

void main() {
  group('Track Model Tests', () {
    test('should create track with default values', () {
      final track = Track(
        id: '1',
        name: 'Test Track',
        type: TrackType.beat,
      );

      expect(track.id, '1');
      expect(track.name, 'Test Track');
      expect(track.type, TrackType.beat);
      expect(track.volume, 1.0);
      expect(track.pan, 0.0);
      expect(track.muted, false);
      expect(track.soloed, false);
      expect(track.hasAudio, false);
      expect(track.clips, isEmpty);
    });

    test('should create track with custom values', () {
      // Create a mock PlayerController for testing
      final mockController = PlayerController();
      
      final clip = AudioClip(
        id: 'clip1',
        path: '/path/to/audio.wav',
        controller: mockController,
        volume: 1.0,
        startTime: Duration.zero,
        endTime: const Duration(minutes: 3, seconds: 30),
      );

      final track = Track(
        id: '2',
        name: 'Custom Track',
        type: TrackType.vocal,
        volume: 0.8,
        pan: -0.5,
        muted: true,
        soloed: false,
        clips: [clip],
      );

      expect(track.id, '2');
      expect(track.name, 'Custom Track');
      expect(track.type, TrackType.vocal);
      expect(track.volume, 0.8);
      expect(track.pan, -0.5);
      expect(track.muted, true);
      expect(track.soloed, false);
      expect(track.hasAudio, true);
      expect(track.clips, isNotEmpty);
      expect(track.clips.length, 1);
    });

    test('should determine hasAudio correctly', () {
      final trackWithoutAudio = Track(
        id: '1',
        name: 'No Audio',
        type: TrackType.beat,
      );

      final mockController = PlayerController();
      final clip = AudioClip(
        id: 'clip1',
        path: '/path/to/audio.wav',
        controller: mockController,
      );

      final trackWithAudio = Track(
        id: '2',
        name: 'With Audio',
        type: TrackType.vocal,
        clips: [clip],
      );

      expect(trackWithoutAudio.hasAudio, false);
      expect(trackWithAudio.hasAudio, true);
    });

    test('should handle different track types', () {
      final beatTrack = Track(
        id: '1',
        name: 'Beat',
        type: TrackType.beat,
      );

      final vocalTrack = Track(
        id: '2',
        name: 'Vocal',
        type: TrackType.vocal,
      );

      final mixedTrack = Track(
        id: '3',
        name: 'Mixed',
        type: TrackType.mixed,
      );

      final masteredTrack = Track(
        id: '4',
        name: 'Mastered',
        type: TrackType.mastered,
      );

      expect(beatTrack.type, TrackType.beat);
      expect(vocalTrack.type, TrackType.vocal);
      expect(mixedTrack.type, TrackType.mixed);
      expect(masteredTrack.type, TrackType.mastered);
    });

    test('should handle volume range', () {
      final track = Track(
        id: '1',
        name: 'Volume Test',
        type: TrackType.beat,
      );

      // Test minimum volume
      track.volume = 0.0;
      expect(track.volume, 0.0);

      // Test maximum volume
      track.volume = 1.0;
      expect(track.volume, 1.0);

      // Test mid volume
      track.volume = 0.5;
      expect(track.volume, 0.5);
    });

    test('should handle pan range', () {
      final track = Track(
        id: '1',
        name: 'Pan Test',
        type: TrackType.beat,
      );

      // Test left pan
      track.pan = -1.0;
      expect(track.pan, -1.0);

      // Test right pan
      track.pan = 1.0;
      expect(track.pan, 1.0);

      // Test center pan
      track.pan = 0.0;
      expect(track.pan, 0.0);
    });

    test('should toggle mute state', () {
      final track = Track(
        id: '1',
        name: 'Mute Test',
        type: TrackType.beat,
      );

      expect(track.muted, false);

      track.muted = true;
      expect(track.muted, true);

      track.muted = false;
      expect(track.muted, false);
    });

    test('should toggle solo state', () {
      final track = Track(
        id: '1',
        name: 'Solo Test',
        type: TrackType.beat,
      );

      expect(track.soloed, false);

      track.soloed = true;
      expect(track.soloed, true);

      track.soloed = false;
      expect(track.soloed, false);
    });

    test('should handle duration correctly', () {
      final track = Track(
        id: '1',
        name: 'Duration Test',
        type: TrackType.beat,
      );

      expect(track.duration, Duration.zero);

      // Create mock clips with durations
      final mockController1 = PlayerController();
      final clip1 = AudioClip(
        id: 'clip1',
        path: '/path/to/audio1.wav',
        controller: mockController1,
        startTime: Duration.zero,
        endTime: const Duration(seconds: 30),
      );

      track.addClip(clip1);
      expect(track.duration, const Duration(seconds: 30));

      // Add another clip that ends later
      final mockController2 = PlayerController();
      final clip2 = AudioClip(
        id: 'clip2',
        path: '/path/to/audio2.wav',
        controller: mockController2,
        startTime: Duration.zero,
        endTime: const Duration(minutes: 2, seconds: 15),
      );

      track.addClip(clip2);
      expect(track.duration, const Duration(minutes: 2, seconds: 15));
    });

    test('should handle clips correctly', () {
      final track = Track(
        id: '1',
        name: 'Clips Test',
        type: TrackType.beat,
      );

      expect(track.clips, isEmpty);
      expect(track.hasAudio, false);

      // Create mock clips
      final mockController = PlayerController();
      final clip = AudioClip(
        id: 'clip1',
        path: '/path/to/audio.wav',
        controller: mockController,
      );

      track.addClip(clip);
      expect(track.clips, isNotEmpty);
      expect(track.clips.length, 1);
      expect(track.hasAudio, true);

      // Test removing clip
      final removed = track.removeClip('clip1');
      expect(removed, true);
      expect(track.clips, isEmpty);
      expect(track.hasAudio, false);

      // Test removing non-existent clip
      final notRemoved = track.removeClip('nonexistent');
      expect(notRemoved, false);
    });

    test('should get clip by ID', () {
      final track = Track(
        id: '1',
        name: 'Get Clip Test',
        type: TrackType.beat,
      );

      // Create mock clips
      final mockController = PlayerController();
      final clip = AudioClip(
        id: 'clip1',
        path: '/path/to/audio.wav',
        controller: mockController,
      );

      track.addClip(clip);

      // Test getting existing clip
      final foundClip = track.getClip('clip1');
      expect(foundClip, isNotNull);
      expect(foundClip!.id, 'clip1');

      // Test getting non-existent clip
      final notFoundClip = track.getClip('nonexistent');
      expect(notFoundClip, isNull);
    });

    test('should create copy with overrides', () {
      // Create mock clips
      final mockController = PlayerController();
      final clip = AudioClip(
        id: 'clip1',
        path: '/path/to/audio.wav',
        controller: mockController,
      );

      final originalTrack = Track(
        id: '1',
        name: 'Original',
        type: TrackType.beat,
        volume: 0.8,
        pan: -0.5,
        muted: true,
        soloed: false,
        clips: [clip],
      );

      final copiedTrack = originalTrack.copyWith(
        name: 'Copied',
        volume: 0.6,
        muted: false,
      );

      // Original should be unchanged
      expect(originalTrack.id, '1');
      expect(originalTrack.name, 'Original');
      expect(originalTrack.type, TrackType.beat);
      expect(originalTrack.volume, 0.8);
      expect(originalTrack.pan, -0.5);
      expect(originalTrack.muted, true);
      expect(originalTrack.soloed, false);
      expect(originalTrack.clips.length, 1);

      // Copy should have new values
      expect(copiedTrack.id, '1'); // ID should be the same
      expect(copiedTrack.name, 'Copied');
      expect(copiedTrack.type, TrackType.beat); // Type should be the same
      expect(copiedTrack.volume, 0.6);
      expect(copiedTrack.pan, -0.5); // Pan should be the same
      expect(copiedTrack.muted, false);
      expect(copiedTrack.soloed, false); // Soloed should be the same
      expect(copiedTrack.clips.length, 1); // Clips should be the same
    });

    test('should implement equality correctly', () {
      // Create mock controllers
      final mockController1 = PlayerController();
      final mockController2 = PlayerController();
      
      final clip1 = AudioClip(
        id: 'clip1',
        path: '/path/to/audio1.wav',
        controller: mockController1,
      );
      
      final clip2 = AudioClip(
        id: 'clip2',
        path: '/path/to/audio2.wav',
        controller: mockController2,
      );

      final track1 = Track(
        id: '1',
        name: 'Test Track',
        type: TrackType.beat,
        volume: 0.8,
        pan: -0.5,
        muted: true,
        soloed: false,
        clips: [clip1],
      );

      final track2 = Track(
        id: '1',
        name: 'Test Track',
        type: TrackType.beat,
        volume: 0.8,
        pan: -0.5,
        muted: true,
        soloed: false,
        clips: [clip1],
      );

      final track3 = Track(
        id: '2',
        name: 'Different Track',
        type: TrackType.vocal,
        volume: 0.6,
        pan: 0.5,
        muted: false,
        soloed: true,
        clips: [clip2],
      );

      expect(track1, equals(track2));
      expect(track1, isNot(equals(track3)));
    });

    test('should implement toString correctly', () {
      final track = Track(
        id: '1',
        name: 'Test Track',
        type: TrackType.beat,
      );

      final trackString = track.toString();
      expect(trackString, contains('Track('));
      expect(trackString, contains('id: 1'));
      expect(trackString, contains('name: Test Track'));
      expect(trackString, contains('type: TrackType.beat'));
      expect(trackString, contains('volume: 1.0'));
      expect(trackString, contains('pan: 0.0'));
      expect(trackString, contains('muted: false'));
      expect(trackString, contains('soloed: false'));
      expect(trackString, contains('clips: 0'));
    });
  });
}
