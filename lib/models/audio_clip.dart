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
}
