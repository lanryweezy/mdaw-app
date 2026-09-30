import 'package:audio_waveforms/audio_waveforms.dart';

/// Represents a single audio segment within a track
/// Represents a single audio segment within a track
class AudioClip {
  /// Unique identifier for the clip
  final String id;

  /// File path to the audio file
  final String path;

  /// Controller for audio playback
  final PlayerController controller;

  /// Volume level (0.0 to 1.0)
  double volume;

  /// Waveform data for the clip
  final List<double> waveform;

  /// Start time relative to the beginning of the track
  Duration startTime;

  /// End time relative to the beginning of the track
  Duration endTime;

  /// Fade-in duration
  Duration fadeInDuration;

  /// Fade-out duration
  Duration fadeOutDuration;

  /// Creates a new AudioClip instance
  ///
  /// [id] Unique identifier (required)
  /// [path] Audio file path (required)
  /// [controller] Playback controller (required)
  /// [volume] Initial volume (default 1.0)
  /// [startTime] Start position (default zero)
  /// [endTime] End position (default zero)
  AudioClip({
    required this.id,
    required this.path,
    required this.controller,
    this.volume = 1.0,
    this.startTime = Duration.zero,
    this.endTime = Duration.zero,
    this.waveform = const [],
    this.fadeInDuration = Duration.zero,
    this.fadeOutDuration = Duration.zero,
  });

  /// Duration of the audio clip
  /// Duration of the audio clip
  Duration get duration => endTime - startTime;

  /// Creates a copy of this clip with optional overrides
  AudioClip copyWith({
    String? id,
    String? path,
    PlayerController? controller,
    double? volume,
    Duration? startTime,
    Duration? endTime,
    List<double>? waveform,
    Duration? fadeInDuration,
    Duration? fadeOutDuration,
  }) {
    return AudioClip(
      id: id ?? this.id,
      path: path ?? this.path,
      controller: controller ?? this.controller,
      volume: volume ?? this.volume,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      waveform: waveform ?? this.waveform,
      fadeInDuration: fadeInDuration ?? this.fadeInDuration,
      fadeOutDuration: fadeOutDuration ?? this.fadeOutDuration,
    );
  }

  // ⚡ Bolt: Added operator == and hashCode to prevent unnecessary widget rebuilds
  // during state changes (like audio playback) by correctly determining equality.
  // O(1) scalar properties are evaluated before O(N) waveform collection comparison.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AudioClip) return false;

    // Evaluate O(1) properties first for performance
    if (other.id != id ||
        other.path != path ||
        other.controller != controller ||
        other.volume != volume ||
        other.startTime != startTime ||
        other.endTime != endTime ||
        other.fadeInDuration != fadeInDuration ||
        other.fadeOutDuration != fadeOutDuration) {
      return false;
    }

    // Check if the waveform lists have the same elements (O(N) operation)
    if (waveform.length != other.waveform.length) return false;
    for (int i = 0; i < waveform.length; i++) {
      if (waveform[i] != other.waveform[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      path,
      controller,
      volume,
      Object.hashAll(waveform),
      startTime,
      endTime,
      fadeInDuration,
      fadeOutDuration,
    );
  }
}
