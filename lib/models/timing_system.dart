import 'package:flutter/material.dart';

/// Represents a musical time signature
class TimeSignature {
  final int numerator;
  final int denominator;

  TimeSignature({required this.numerator, required this.denominator});

  /// Common time signatures
  static TimeSignature get common => TimeSignature(numerator: 4, denominator: 4);
  static TimeSignature get cut => TimeSignature(numerator: 2, denominator: 2);
  static TimeSignature get waltz => TimeSignature(numerator: 3, denominator: 4);
  static TimeSignature get sixEight => TimeSignature(numerator: 6, denominator: 8);

  /// Calculate beats per measure
  double get beatsPerMeasure => numerator / (denominator / 4);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSignature &&
        other.numerator == numerator &&
        other.denominator == denominator;
  }

  @override
  int get hashCode => Object.hash(numerator, denominator);

  @override
  String toString() => '$numerator/$denominator';
}

/// Represents a precise musical position in time
class MusicalPosition {
  final int measure;
  final int beat;
  final int tick;
  final int ticksPerBeat;

  MusicalPosition({
    required this.measure,
    required this.beat,
    required this.tick,
    required this.ticksPerBeat,
  });

  /// Create from absolute time in milliseconds
  factory MusicalPosition.fromMilliseconds({
    required int milliseconds,
    required int bpm,
    required TimeSignature timeSignature,
    int ticksPerBeat = 480,
  }) {
    // Calculate beats from milliseconds and BPM
    final beats = (milliseconds / 60000.0 * bpm);
    
    // Calculate measures and beats
    final beatsPerMeasure = timeSignature.beatsPerMeasure;
    final measure = (beats / beatsPerMeasure).floor();
    final beatInMeasure = (beats % beatsPerMeasure).floor();
    
    // Calculate ticks within the beat
    final fractionalBeat = beats % 1;
    final tick = (fractionalBeat * ticksPerBeat).round();
    
    return MusicalPosition(
      measure: measure,
      beat: beatInMeasure,
      tick: tick,
      ticksPerBeat: ticksPerBeat,
    );
  }

  /// Convert to milliseconds
  int toMilliseconds({required int bpm, required TimeSignature timeSignature}) {
    final beatsPerMeasure = timeSignature.beatsPerMeasure;
    final totalBeats = measure * beatsPerMeasure + beat + (tick / ticksPerBeat);
    return (totalBeats * 60000 / bpm).round();
  }

  /// Get the absolute beat number
  int get absoluteBeat => measure * 4 + beat; // Assuming 4/4 time for simplicity

  /// Move position by a number of ticks
  MusicalPosition moveByTicks(int ticks) {
    int newTick = tick + ticks;
    int newBeat = beat;
    int newMeasure = measure;

    // Handle tick overflow/underflow
    while (newTick >= ticksPerBeat) {
      newTick -= ticksPerBeat;
      newBeat++;
    }
    while (newTick < 0) {
      newTick += ticksPerBeat;
      newBeat--;
    }

    // Handle beat overflow/underflow
    while (newBeat >= 4) { // Assuming 4 beats per measure
      newBeat -= 4;
      newMeasure++;
    }
    while (newBeat < 0) {
      newBeat += 4;
      newMeasure--;
    }

    return MusicalPosition(
      measure: newMeasure,
      beat: newBeat,
      tick: newTick,
      ticksPerBeat: ticksPerBeat,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MusicalPosition &&
        other.measure == measure &&
        other.beat == beat &&
        other.tick == tick &&
        other.ticksPerBeat == ticksPerBeat;
  }

  @override
  int get hashCode => Object.hash(measure, beat, tick, ticksPerBeat);

  @override
  String toString() => '$measure:$beat:$tick';
}

/// Advanced timing system for precise musical timing
class TimingSystem {
  int _bpm = 120;
  TimeSignature _timeSignature = TimeSignature.common;
  int _ticksPerBeat = 480;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  // Getters
  int get bpm => _bpm;
  TimeSignature get timeSignature => _timeSignature;
  int get ticksPerBeat => _ticksPerBeat;
  Duration get position => _position;
  bool get isPlaying => _isPlaying;

  // Setters with validation
  set bpm(int value) {
    _bpm = value.clamp(40, 300);
  }

  set timeSignature(TimeSignature value) {
    _timeSignature = value;
  }

  set ticksPerBeat(int value) {
    _ticksPerBeat = value.clamp(96, 960); // Common range for DAWs
  }

  set position(Duration value) {
    _position = value;
  }

  set isPlaying(bool value) {
    _isPlaying = value;
  }

  /// Convert position to musical position
  MusicalPosition get musicalPosition {
    return MusicalPosition.fromMilliseconds(
      milliseconds: _position.inMilliseconds,
      bpm: _bpm,
      timeSignature: _timeSignature,
      ticksPerBeat: _ticksPerBeat,
    );
  }

  /// Get time signature options
  List<TimeSignature> get timeSignatureOptions => [
        TimeSignature.common,
        TimeSignature.cut,
        TimeSignature.waltz,
        TimeSignature.sixEight,
      ];

  /// Get BPM options for common musical styles
  List<int> get bpmPresets => [
        60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200
      ];

  /// Calculate duration of one beat in milliseconds
  int get beatDurationMs {
    return (60000 / _bpm).round();
  }

  /// Calculate duration of one tick in milliseconds
  double get tickDurationMs {
    return beatDurationMs / _ticksPerBeat;
  }

  /// Calculate measures from duration
  int measuresFromDuration(Duration duration) {
    final totalBeats = duration.inMilliseconds / beatDurationMs;
    return (totalBeats / _timeSignature.beatsPerMeasure).ceil();
  }

  /// Snap position to grid
  Duration snapToGrid(Duration position, {int gridSizeTicks = 480}) {
    final positionInTicks = (position.inMilliseconds / tickDurationMs).round();
    final snappedTicks = (positionInTicks / gridSizeTicks).round() * gridSizeTicks;
    return Duration(milliseconds: (snappedTicks * tickDurationMs).round());
  }

  /// Get grid size options
  List<Duration> get gridSizeOptions {
    return [
      Duration(milliseconds: (ticksPerBeat * tickDurationMs).round()), // 1 beat
      Duration(milliseconds: (ticksPerBeat * 2 * tickDurationMs).round()), // 2 beats
      Duration(milliseconds: (ticksPerBeat * 0.5 * tickDurationMs).round()), // 1/2 beat
      Duration(milliseconds: (ticksPerBeat * 0.25 * tickDurationMs).round()), // 1/4 beat
    ];
  }

  /// Format time as MM:SS:ms
  String formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final milliseconds = duration.inMilliseconds % 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
  }

  /// Format time as musical position
  String formatMusicalPosition() {
    final musicalPos = musicalPosition;
    return '${musicalPos.measure + 1}:${musicalPos.beat + 1}:${musicalPos.tick}';
  }

  /// Get tempo description based on BPM
  String get tempoDescription {
    if (_bpm < 60) return 'Largo';
    if (_bpm < 76) return 'Adagio';
    if (_bpm < 108) return 'Andante';
    if (_bpm < 120) return 'Moderato';
    if (_bpm < 168) return 'Allegro';
    return 'Presto';
  }
}
