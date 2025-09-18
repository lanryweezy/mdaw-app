import 'audio_clip.dart';

/// Enum representing different types of tracks in the DAW
enum TrackType {
  /// Beat track for rhythm elements
  beat,
  /// Vocal track for voice recordings
  vocal,
  /// Mixed track for combined audio
  mixed,
  /// Mastered track for final output
  mastered,
  /// Processed track for effects-applied audio
  processed,
}

/// Represents a single track in the DAW, which can contain multiple audio clips
/// Represents a single track in the DAW, which can contain multiple audio clips
class Track {
  /// Unique identifier for the track
  final String id;
  /// Name of the track
  String name;
  /// Type of the track
  final TrackType type;
  /// Volume level (0.0 to 1.0)
  double volume;
  /// Pan position (-1.0 left to 1.0 right)
  double pan;
  /// Whether the track is muted
  bool muted;
  /// Whether the track is soloed
  bool soloed;
  /// Whether the track is collapsed
  bool collapsed;
  /// List of audio clips in this track
  List<AudioClip> clips;

  /// Creates a new Track instance
  ///
  /// [id] Unique identifier (required)
  /// [name] Track name (required)
  /// [type] Track type (required)
  /// [volume] Initial volume (default 1.0)
  /// [pan] Initial pan (default 0.0)
  /// [muted] Initial mute state (default false)
  /// [soloed] Initial solo state (default false)
  /// [collapsed] Initial collapsed state (default false)
  /// [clips] Initial list of clips (default empty)
  Track({
    required this.id,
    required this.name,
    required this.type,
    this.volume = 1.0,
    this.pan = 0.0,
    this.muted = false,
    this.soloed = false,
    this.collapsed = false,
    List<AudioClip>? clips,
  }) : clips = clips ?? [];

  /// Whether this track has any audio clips
  /// Whether this track has any audio clips
  bool get hasAudio => clips.isNotEmpty;

  /// Total duration of all clips in this track
  /// Total duration of all clips in this track
  Duration get duration {
    if (clips.isEmpty) return Duration.zero;
    
    Duration maxEnd = Duration.zero;
    for (final clip in clips) {
      final clipEnd = clip.startTime + clip.duration;
      if (clipEnd > maxEnd) {
        maxEnd = clipEnd;
      }
    }
    return maxEnd;
  }

  /// Add a new audio clip to this track
  /// Add a new audio clip to this track
  void addClip(AudioClip clip) {
    clips.add(clip);
  }

  /// Remove an audio clip by ID
  /// Remove an audio clip by ID
  /// Returns true if a clip was removed
  bool removeClip(String clipId) {
    final initialLength = clips.length;
    clips.removeWhere((clip) => clip.id == clipId);
    return clips.length < initialLength;
  }

  /// Get clip by ID
  /// Get clip by ID
  /// Returns null if not found
  AudioClip? getClip(String clipId) {
    return clips.firstWhere((clip) => clip.id == clipId);
  }

  /// Creates a copy of this track with optional overrides
  Track copyWith({
    String? id,
    String? name,
    TrackType? type,
    double? volume,
    double? pan,
    bool? muted,
    bool? soloed,
    bool? collapsed,
    List<AudioClip>? clips,
  }) {
    return Track(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      volume: volume ?? this.volume,
      pan: pan ?? this.pan,
      muted: muted ?? this.muted,
      soloed: soloed ?? this.soloed,
      collapsed: collapsed ?? this.collapsed,
      clips: clips ?? this.clips,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Track &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.volume == volume &&
        other.pan == pan &&
        other.muted == muted &&
        other.soloed == soloed &&
        other.collapsed == collapsed &&
        other.clips == clips;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      type,
      volume,
      pan,
      muted,
      soloed,
      collapsed,
      clips,
    );
  }

  @override
  String toString() {
    return 'Track(id: $id, name: $name, type: $type, volume: $volume, pan: $pan, muted: $muted, soloed: $soloed, collapsed: $collapsed, clips: ${clips.length})';
  }
}
