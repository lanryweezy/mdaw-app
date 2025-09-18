import 'package:flutter/material.dart';

/// Types of automation parameters that can be automated
enum AutomationParameterType {
  volume,
  pan,
  mute,
  solo,
  effect,
  tempo,
  pitch,
}

/// Represents a point in an automation curve
class AutomationPoint {
  final Duration time;
  final double value;
  final Curve curve;

  AutomationPoint({
    required this.time,
    required this.value,
    this.curve = Curves.linear,
  });

  /// Create a copy with new values
  AutomationPoint copyWith({
    Duration? time,
    double? value,
    Curve? curve,
  }) {
    return AutomationPoint(
      time: time ?? this.time,
      value: value ?? this.value,
      curve: curve ?? this.curve,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutomationPoint &&
        other.time == time &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(time, value);
}

/// Represents an automation lane for a specific parameter
class AutomationLane {
  final String id;
  final String name;
  final AutomationParameterType parameterType;
  final String targetId; // ID of the track, clip, or effect being automated
  final List<AutomationPoint> points;
  final double minValue;
  final double maxValue;
  final bool isEnabled;
  final Color color;

  AutomationLane({
    required this.id,
    required this.name,
    required this.parameterType,
    required this.targetId,
    List<AutomationPoint>? points,
    this.minValue = 0.0,
    this.maxValue = 1.0,
    this.isEnabled = true,
    this.color = Colors.blue,
  }) : points = points ?? [];

  /// Add a point to the automation lane
  void addPoint(AutomationPoint point) {
    points.add(point);
    _sortPoints();
  }

  /// Remove a point from the automation lane
  void removePoint(AutomationPoint point) {
    points.remove(point);
  }

  /// Get the value at a specific time using interpolation
  double getValueAtTime(Duration time) {
    if (points.isEmpty) return (minValue + maxValue) / 2;
    if (points.length == 1) return points.first.value;

    // Find the two points that bracket the time
    AutomationPoint? beforePoint;
    AutomationPoint? afterPoint;

    for (final point in points) {
      if (point.time <= time) {
        beforePoint = point;
      } else {
        afterPoint = point;
        break;
      }
    }

    // If we're before the first point, return its value
    if (beforePoint == null) return points.first.value;
    
    // If we're after the last point, return its value
    if (afterPoint == null) return points.last.value;

    // Interpolate between the two points
    final timeDiff = afterPoint.time.inMilliseconds - beforePoint.time.inMilliseconds;
    if (timeDiff == 0) return beforePoint.value;

    final ratio = (time.inMilliseconds - beforePoint.time.inMilliseconds) / timeDiff;
    final curvedRatio = beforePoint.curve.transform(ratio);
    
    return beforePoint.value + (afterPoint.value - beforePoint.value) * curvedRatio;
  }

  /// Sort points by time
  void _sortPoints() {
    points.sort((a, b) => a.time.compareTo(b.time));
  }

  /// Create a copy with new values
  AutomationLane copyWith({
    String? id,
    String? name,
    AutomationParameterType? parameterType,
    String? targetId,
    List<AutomationPoint>? points,
    double? minValue,
    double? maxValue,
    bool? isEnabled,
    Color? color,
  }) {
    return AutomationLane(
      id: id ?? this.id,
      name: name ?? this.name,
      parameterType: parameterType ?? this.parameterType,
      targetId: targetId ?? this.targetId,
      points: points ?? List.from(this.points),
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      isEnabled: isEnabled ?? this.isEnabled,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutomationLane &&
        other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Advanced automation system for precise parameter control
class AutomationSystem {
  final List<AutomationLane> lanes;
  bool _isRecording = false;
  bool _isPlaying = false;
  Duration _currentTime = Duration.zero;

  AutomationSystem({List<AutomationLane>? lanes})
      : lanes = lanes ?? [];

  /// Start recording automation
  void startRecording() {
    _isRecording = true;
  }

  /// Stop recording automation
  void stopRecording() {
    _isRecording = false;
  }

  /// Start playing automation
  void startPlayback() {
    _isPlaying = true;
  }

  /// Stop playing automation
  void stopPlayback() {
    _isPlaying = false;
  }

  /// Set current time for automation playback
  void setCurrentTime(Duration time) {
    _currentTime = time;
    if (_isPlaying) {
      _updateAutomatedParameters();
    }
  }

  /// Record a value for a parameter at the current time
  void recordValue({
    required String parameterId,
    required AutomationParameterType parameterType,
    required String targetId,
    required double value,
  }) {
    if (!_isRecording) return;

    // Find or create the automation lane
    final laneId = '${parameterType.name}_$targetId';
    AutomationLane? lane = lanes.firstWhere(
      (l) => l.id == laneId,
      orElse: () => _createAutomationLane(
        id: laneId,
        name: parameterId,
        parameterType: parameterType,
        targetId: targetId,
      ),
    );

    // If this is a new lane, add it to the list
    if (!lanes.contains(lane)) {
      lanes.add(lane);
    }

    // Add the point
    lane.addPoint(AutomationPoint(
      time: _currentTime,
      value: value,
    ));
  }

  /// Create a new automation lane
  AutomationLane _createAutomationLane({
    required String id,
    required String name,
    required AutomationParameterType parameterType,
    required String targetId,
  }) {
    double minValue = 0.0;
    double maxValue = 1.0;
    Color color = Colors.blue;

    switch (parameterType) {
      case AutomationParameterType.pan:
        minValue = -1.0;
        maxValue = 1.0;
        color = Colors.green;
        break;
      case AutomationParameterType.tempo:
        minValue = 60.0;
        maxValue = 200.0;
        color = Colors.orange;
        break;
      case AutomationParameterType.pitch:
        minValue = 0.5;
        maxValue = 2.0;
        color = Colors.purple;
        break;
      case AutomationParameterType.mute:
      case AutomationParameterType.solo:
        maxValue = 1.0;
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }

    return AutomationLane(
      id: id,
      name: name,
      parameterType: parameterType,
      targetId: targetId,
      minValue: minValue,
      maxValue: maxValue,
      color: color,
    );
  }

  /// Update all automated parameters based on current time
  void _updateAutomatedParameters() {
    for (final lane in lanes) {
      if (lane.isEnabled) {
        final value = lane.getValueAtTime(_currentTime);
        // In a real implementation, this would update the actual parameter
        // For now, we'll just print the value

      }
    }
  }

  /// Get all automation lanes for a specific target
  List<AutomationLane> getLanesForTarget(String targetId) {
    return lanes.where((lane) => lane.targetId == targetId).toList();
  }

  /// Enable/disable an automation lane
  void setLaneEnabled(String laneId, bool enabled) {
    final laneIndex = lanes.indexWhere((l) => l.id == laneId);
    if (laneIndex == -1) {
      throw Exception('Automation lane not found: $laneId');
    }
    lanes[laneIndex] = lanes[laneIndex].copyWith(isEnabled: enabled);
  }

  /// Clear all automation data
  void clear() {
    lanes.clear();
  }

  /// Getters
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  Duration get currentTime => _currentTime;
}
