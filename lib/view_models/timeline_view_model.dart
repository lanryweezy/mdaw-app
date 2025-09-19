import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:studio_wiz/models/audio_clip.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:studio_wiz/models/timing_system.dart';
import 'package:studio_wiz/services/audio_resource_manager.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';

enum TimelineTool { select, split, trim }

class TimelineState {
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isPlaying;
  final double zoomLevel;
  final bool snapToGrid;
  final Duration gridSize;
  final int bpm;
  final int timeSignatureNumerator;
  final int timeSignatureDenominator;
  final bool metronomeEnabled;
  final int ticksPerBeat;
  final String? selectedClipId;
  final bool isDragging;
  final Offset? dragStartPosition;
  final TimelineTool selectedTool;

  TimelineState({
    required this.currentPosition,
    required this.totalDuration,
    required this.isPlaying,
    required this.zoomLevel,
    required this.snapToGrid,
    required this.gridSize,
    required this.bpm,
    required this.timeSignatureNumerator,
    required this.timeSignatureDenominator,
    required this.metronomeEnabled,
    required this.ticksPerBeat,
    this.selectedClipId,
    this.isDragging = false,
    this.dragStartPosition,
    this.selectedTool = TimelineTool.select,
  });

  TimelineState copyWith({
    Duration? currentPosition,
    Duration? totalDuration,
    bool? isPlaying,
    double? zoomLevel,
    bool? snapToGrid,
    Duration? gridSize,
    int? bpm,
    int? timeSignatureNumerator,
    int? timeSignatureDenominator,
    bool? metronomeEnabled,
    int? ticksPerBeat,
    String? selectedClipId,
    bool? isDragging,
    Offset? dragStartPosition,
    TimelineTool? selectedTool,
  }) {
    return TimelineState(
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      isPlaying: isPlaying ?? this.isPlaying,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      gridSize: gridSize ?? this.gridSize,
      bpm: bpm ?? this.bpm,
      timeSignatureNumerator: timeSignatureNumerator ?? this.timeSignatureNumerator,
      timeSignatureDenominator: timeSignatureDenominator ?? this.timeSignatureDenominator,
      metronomeEnabled: metronomeEnabled ?? this.metronomeEnabled,
      ticksPerBeat: ticksPerBeat ?? this.ticksPerBeat,
      selectedClipId: selectedClipId ?? this.selectedClipId,
      isDragging: isDragging ?? this.isDragging,
      dragStartPosition: dragStartPosition ?? this.dragStartPosition,
      selectedTool: selectedTool ?? this.selectedTool,
    );
  }
}

class TimelineAction {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  TimelineAction({
    required this.type,
    required this.data,
    required this.timestamp,
  });
}

class TimelineViewModel extends ChangeNotifier {
  final DawViewModel _dawViewModel;

  final AudioPlayer _metronomePlayer = AudioPlayer();
  final AudioPlayer _metronomeAccentPlayer = AudioPlayer();

  TimelineState _state = TimelineState(
    currentPosition: Duration.zero,
    totalDuration: const Duration(seconds: 60),
    isPlaying: false,
    zoomLevel: 1.0,
    snapToGrid: true,
    gridSize: const Duration(milliseconds: 500),
    bpm: 120,
    timeSignatureNumerator: 4,
    timeSignatureDenominator: 4,
    metronomeEnabled: false,
    ticksPerBeat: 480,
  );

  final List<TimelineAction> _undoStack = [];
  final List<TimelineAction> _redoStack = [];
  static const int maxUndoSteps = 50;

  Timer? _metronomeTimer;
  bool _metronomeClick = false;

  StreamSubscription<Duration>? _playbackSubscription;

  TimelineViewModel(this._dawViewModel) {
    _initializePlaybackTracking();
  }

  void _initializePlaybackTracking() {
    _dawViewModel.addListener(_onDawStateChanged);
  }

  void _onDawStateChanged() {
    final newState = _state.copyWith(
      isPlaying: _dawViewModel.isPlaying,
      currentPosition: _dawViewModel.currentPlaybackPosition,
    );

    if (newState != _state) {
      _state = newState;
      notifyListeners();
    }
  }

  TimelineState get state => _state;
  Duration get currentPosition => _state.currentPosition;
  Duration get totalDuration => _state.totalDuration;
  bool get isPlaying => _state.isPlaying;
  double get zoomLevel => _state.zoomLevel;
  bool get snapToGrid => _state.snapToGrid;
  Duration get gridSize => _state.gridSize;
  int get bpm => _state.bpm;
  int get timeSignatureNumerator => _state.timeSignatureNumerator;
  int get timeSignatureDenominator => _state.timeSignatureDenominator;
  bool get metronomeEnabled => _state.metronomeEnabled;
  int get ticksPerBeat => _state.ticksPerBeat;
  String? get selectedClipId => _state.selectedClipId;
  bool get isDragging => _state.isDragging;
  Offset? get dragStartPosition => _state.dragStartPosition;
  TimelineTool get selectedTool => _state.selectedTool;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  double get pixelsPerSecond => 100.0 * zoomLevel;
  double get trackHeight => 80.0;

  void setTool(TimelineTool tool) {
    _state = _state.copyWith(selectedTool: tool);
    notifyListeners();
  }

  void seekTo(Duration position) {
    final snappedPosition = snapDurationToGrid(position);
    _dawViewModel.seekTo(snappedPosition);
    _state = _state.copyWith(currentPosition: snappedPosition);
    notifyListeners();
  }

  void setZoomLevel(double zoomLevel) {
    _state = _state.copyWith(zoomLevel: zoomLevel.clamp(0.1, 5.0));
    notifyListeners();
  }

  void toggleSnapToGrid() {
    _state = _state.copyWith(snapToGrid: !_state.snapToGrid);
    notifyListeners();
  }

  void setGridSize(Duration gridSize) {
    _state = _state.copyWith(gridSize: gridSize);
    notifyListeners();
  }

  Duration snapDurationToGrid(Duration duration) {
    if (!_state.snapToGrid) return duration;

    final gridMs = _state.gridSize.inMilliseconds;
    final snappedMs = ((duration.inMilliseconds / gridMs).round() * gridMs);
    return Duration(milliseconds: snappedMs);
  }

  void setBpm(int bpm) {
    _state = _state.copyWith(bpm: bpm.clamp(60, 200));
    notifyListeners();
  }

  void setTicksPerBeat(int ticksPerBeat) {
    _state = _state.copyWith(ticksPerBeat: ticksPerBeat.clamp(96, 960));
    notifyListeners();
  }

  void setTimeSignature(int numerator, int denominator) {
    _state = _state.copyWith(
      timeSignatureNumerator: numerator,
      timeSignatureDenominator: denominator,
    );
    notifyListeners();
  }

  MusicalPosition get musicalPosition {
    return MusicalPosition.fromMilliseconds(
      milliseconds: _state.currentPosition.inMilliseconds,
      bpm: _state.bpm,
      timeSignature: TimeSignature(numerator: _state.timeSignatureNumerator, denominator: _state.timeSignatureDenominator),
      ticksPerBeat: _state.ticksPerBeat,
    );
  }

  String formatCurrentTime() {
    final minutes = _state.currentPosition.inMinutes;
    final seconds = _state.currentPosition.inSeconds % 60;
    final milliseconds = _state.currentPosition.inMilliseconds % 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
  }

  String formatMusicalPosition() {
    final musicalPos = musicalPosition;
    return '${musicalPos.measure + 1}:${musicalPos.beat + 1}:${musicalPos.tick}';
  }

  String get tempoDescription {
    if (_state.bpm < 60) return 'Largo';
    if (_state.bpm < 76) return 'Adagio';
    if (_state.bpm < 108) return 'Andante';
    if (_state.bpm < 120) return 'Moderato';
    if (_state.bpm < 168) return 'Allegro';
    return 'Presto';
  }

  void toggleMetronome() {
    final newMetronomeEnabled = !_state.metronomeEnabled;
    _state = _state.copyWith(metronomeEnabled: newMetronomeEnabled);

    if (newMetronomeEnabled) {
      _startMetronome();
    } else {
      _stopMetronome();
    }

    notifyListeners();
  }

  void _startMetronome() {
    _stopMetronome();

    final beatDuration = Duration(milliseconds: (60000 / _state.bpm).round());

    int beatCount = 0;

    _metronomeTimer = Timer.periodic(beatDuration, (timer) {
      if (_state.isPlaying && _state.metronomeEnabled) {
        final isAccent = (beatCount % _state.timeSignatureNumerator) == 0;
        beatCount++;

        if (isAccent) {
          _playBeep(880, 100);
        } else {
          _playBeep(440, 100);
        }

        notifyListeners();
      }
    });
  }

  Future<void> _playBeep(int frequency, int durationMs) async {
    try {
      final player = AudioPlayer();
      await player.dispose();
    } catch (e) {
      print('Error playing metronome beep: $e');
    }
  }

  void _stopMetronome() {
    _metronomeTimer?.cancel();
    _metronomeTimer = null;
    _metronomeClick = false;
  }

  void _addAction(TimelineAction action) {
    _undoStack.add(action);
    if (_undoStack.length > maxUndoSteps) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    notifyListeners();
  }

  void undo() {
    if (_undoStack.isEmpty) return;

    final action = _undoStack.removeLast();
    _redoStack.add(action);

    _executeAction(action, isUndo: true);
    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) return;

    final action = _redoStack.removeLast();
    _undoStack.add(action);

    _executeAction(action, isUndo: false);
    notifyListeners();
  }

  void _executeAction(TimelineAction action, {required bool isUndo}) {
    switch (action.type) {
      case 'clip_move':
        _executeClipMove(action, isUndo);
        break;
      case 'clip_trim':
        _executeClipTrim(action, isUndo);
        break;
      case 'clip_split':
        _executeClipSplit(action, isUndo);
        break;
      case 'clip_delete':
        _executeClipDelete(action, isUndo);
        break;
    }
  }

  void _executeClipMove(TimelineAction action, bool isUndo) {
    final clipId = action.data['clipId'] as String;
    final newStartTime = isUndo
        ? (action.data['oldStartTime'] as int)
        : (action.data['newStartTime'] as int);

    for (final track in _dawViewModel.vocalTracks) {
      final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
      if (clipIndex == -1) continue;

      final clip = track.clips[clipIndex];
      final oldStartTime = clip.startTime;
      final timeDiff = Duration(milliseconds: newStartTime) - oldStartTime;
      clip.startTime = Duration(milliseconds: newStartTime);
      clip.endTime = clip.endTime + timeDiff;

      break;
    }

    _dawViewModel.notifyListeners();
  }

  void setFadeIn(String clipId, Duration fadeInDuration) {
    final clip = _findClipById(clipId);
    if (clip != null) {
      clip.fadeInDuration = fadeInDuration;
      notifyListeners();
    }
  }

  void setFadeOut(String clipId, Duration fadeOutDuration) {
    final clip = _findClipById(clipId);
    if (clip != null) {
      clip.fadeOutDuration = fadeOutDuration;
      notifyListeners();
    }
  }

  void _executeClipTrim(TimelineAction action, bool isUndo) {
    final clipId = action.data['clipId'] as String;
    final newStartTime = isUndo
        ? (action.data['oldStartTime'] as int)
        : (action.data['newStartTime'] as int);
    final newEndTime = isUndo
        ? (action.data['oldEndTime'] as int)
        : (action.data['newEndTime'] as int);

    for (final track in _dawViewModel.vocalTracks) {
      final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
      if (clipIndex == -1) continue;

      final clip = track.clips[clipIndex];
      clip.startTime = Duration(milliseconds: newStartTime);
      clip.endTime = Duration(milliseconds: newEndTime);

      break;
    }

    _dawViewModel.notifyListeners();
  }

  void _executeClipSplit(TimelineAction action, bool isUndo) {
    final clipId = action.data['clipId'] as String;
    final splitTime = action.data['splitTime'] as int;
    final newClipId = action.data['newClipId'] as String;

    if (isUndo) {
      for (final track in _dawViewModel.vocalTracks) {
        final newClipIndex = track.clips.indexWhere((c) => c.id == newClipId);
        if (newClipIndex == -1) continue;

        final originalClipIndex = newClipIndex - 1;
        if (originalClipIndex >= 0) {
          final originalClip = track.clips[originalClipIndex];
          final newClip = track.clips[newClipIndex];

          originalClip.endTime = newClip.endTime;
        }

        track.clips.removeAt(newClipIndex);
        break;
      }
    } else {
      for (final track in _dawViewModel.vocalTracks) {
        final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
        if (clipIndex == -1) continue;

        final clip = track.clips[clipIndex];
        final originalEndTime = clip.endTime;
        final snappedSplitTime = Duration(milliseconds: splitTime);

        final newClip = AudioClip(
          id: newClipId,
          path: clip.path,
          controller: clip.controller,
          volume: clip.volume,
          startTime: snappedSplitTime,
          endTime: originalEndTime,
        );

        clip.endTime = snappedSplitTime;

        track.clips.insert(clipIndex + 1, newClip);
        break;
      }
    }

    _dawViewModel.notifyListeners();
  }

  void _executeClipDelete(TimelineAction action, bool isUndo) {
    if (isUndo) {
      final clipId = action.data['clipId'] as String;
      final trackId = action.data['trackId'] as String;
      final path = action.data['path'] as String;
      final volume = action.data['volume'] as double;
      final startTime = Duration(milliseconds: action.data['startTime'] as int);
      final endTime = Duration(milliseconds: action.data['endTime'] as int);

      Track? targetTrack;
      if (trackId == _dawViewModel.beatTrack.id) {
        targetTrack = _dawViewModel.beatTrack;
      } else {
        try {
          targetTrack = _dawViewModel.vocalTracks.firstWhere((track) => track.id == trackId);
        } catch (e) {
          if (_dawViewModel.mixedVocalTrack?.id == trackId) {
            targetTrack = _dawViewModel.mixedVocalTrack;
          } else if (_dawViewModel.masteredSongTrack?.id == trackId) {
            targetTrack = _dawViewModel.masteredSongTrack;
          }
        }
      }

      if (targetTrack != null) {
        AudioResourceManager().getOrCreateController(path).then((controller) {
          final clip = AudioClip(
            id: clipId,
            path: path,
            controller: controller,
            volume: volume,
            startTime: startTime,
            endTime: endTime,
          );
          targetTrack!.addClip(clip);
          _dawViewModel.notifyListeners();
        });
      }
    } else {
      final clipId = action.data['clipId'] as String;

      bool clipFound = false;
      for (final track in [
        _dawViewModel.beatTrack,
        ..._dawViewModel.vocalTracks,
        if (_dawViewModel.mixedVocalTrack != null) _dawViewModel.mixedVocalTrack!,
        if (_dawViewModel.masteredSongTrack != null) _dawViewModel.masteredSongTrack!,
      ]) {
        final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
        if (clipIndex != -1) {
          track.clips.removeAt(clipIndex);
          clipFound = true;
          break;
        }
      }

      if (clipFound) {
        _dawViewModel.notifyListeners();
      }
    }
  }

  void moveClip(String clipId, Duration newStartTime) {
    final snappedTime = snapDurationToGrid(newStartTime);

    for (final track in _dawViewModel.vocalTracks) {
      final clip = track.clips.firstWhere(
        (c) => c.id == clipId,
        orElse: () => throw Exception('Clip not found'),
      );

      final oldStartTime = clip.startTime;
      clip.startTime = snappedTime;
      clip.endTime = clip.endTime + (snappedTime - oldStartTime);

      _addAction(TimelineAction(
        type: 'clip_move',
        data: {
          'clipId': clipId,
          'oldStartTime': oldStartTime.inMilliseconds,
          'newStartTime': snappedTime.inMilliseconds,
        },
        timestamp: DateTime.now(),
      ));

      break;
    }

    _dawViewModel.notifyListeners();
  }

  void trimClip(String clipId, Duration newStartTime, Duration newEndTime) {
    final snappedStartTime = snapDurationToGrid(newStartTime);
    final snappedEndTime = snapDurationToGrid(newEndTime);

    for (final track in _dawViewModel.vocalTracks) {
      final clip = track.clips.firstWhere(
        (c) => c.id == clipId,
        orElse: () => throw Exception('Clip not found'),
      );

      final oldStartTime = clip.startTime;
      final oldEndTime = clip.endTime;

      clip.startTime = snappedStartTime;
      clip.endTime = snappedEndTime;

      _addAction(TimelineAction(
        type: 'clip_trim',
        data: {
          'clipId': clipId,
          'oldStartTime': oldStartTime.inMilliseconds,
          'oldEndTime': oldEndTime.inMilliseconds,
          'newStartTime': snappedStartTime.inMilliseconds,
          'newEndTime': snappedEndTime.inMilliseconds,
        },
        timestamp: DateTime.now(),
      ));

      break;
    }

    _dawViewModel.notifyListeners();
  }

  void splitClip(String clipId, Duration splitTime) {
    final snappedSplitTime = snapDurationToGrid(splitTime);

    for (final track in _dawViewModel.vocalTracks) {
      final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
      if (clipIndex == -1) continue;

      final clip = track.clips[clipIndex];
      final originalEndTime = clip.endTime;

      final newClip = AudioClip(
        id: '${clip.id}_split_${DateTime.now().millisecondsSinceEpoch}',
        path: clip.path,
        controller: clip.controller,
        volume: clip.volume,
        startTime: snappedSplitTime,
        endTime: originalEndTime,
      );

      clip.endTime = snappedSplitTime;

      track.clips.insert(clipIndex + 1, newClip);

      _addAction(TimelineAction(
        type: 'clip_split',
        data: {
          'clipId': clipId,
          'splitTime': snappedSplitTime.inMilliseconds,
          'newClipId': newClip.id,
        },
        timestamp: DateTime.now(),
      ));

      break;
    }

    _dawViewModel.notifyListeners();
  }

  void deleteClip(String clipId) {
    for (final track in _dawViewModel.vocalTracks) {
      final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
      if (clipIndex == -1) continue;

      final clip = track.clips[clipIndex];
      final clipData = {
        'clipId': clipId,
        'trackId': track.id,
        'path': clip.path,
        'volume': clip.volume,
        'startTime': clip.startTime.inMilliseconds,
        'endTime': clip.endTime.inMilliseconds,
      };

      track.clips.removeAt(clipIndex);

      _addAction(TimelineAction(
        type: 'clip_delete',
        data: clipData,
        timestamp: DateTime.now(),
      ));

      break;
    }

    _dawViewModel.notifyListeners();
  }

  void updateTotalDuration() {
    Duration maxDuration = const Duration(seconds: 60);

    final allClips = [
      ..._dawViewModel.beatTrack.clips,
      ..._dawViewModel.vocalTracks.expand((track) => track.clips),
      if (_dawViewModel.mixedVocalTrack != null) ..._dawViewModel.mixedVocalTrack!.clips,
      if (_dawViewModel.masteredSongTrack != null) ..._dawViewModel.masteredSongTrack!.clips,
    ];

    for (final clip in allClips) {
      if (clip.endTime > maxDuration) {
        maxDuration = clip.endTime;
      }
    }

    if (maxDuration != _state.totalDuration) {
      _state = _state.copyWith(totalDuration: maxDuration);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _dawViewModel.removeListener(_onDawStateChanged);
    _playbackSubscription?.cancel();
    _stopMetronome();

    _metronomePlayer.dispose();
    _metronomeAccentPlayer.dispose();

    super.dispose();
  }

  void zoomIn() {
    final newZoomLevel = (_state.zoomLevel * 1.2).clamp(0.1, 5.0);
    _state = _state.copyWith(zoomLevel: newZoomLevel);
    notifyListeners();
  }

  void zoomOut() {
    final newZoomLevel = (_state.zoomLevel / 1.2).clamp(0.1, 5.0);
    _state = _state.copyWith(zoomLevel: newZoomLevel);
    notifyListeners();
  }

  void fitToScreen() {
    _state = _state.copyWith(zoomLevel: 1.0);
    notifyListeners();
  }

  void duplicateSelectedClip() {
    for (final track in _dawViewModel.vocalTracks) {
      if (track.clips.isNotEmpty) {
        final originalClip = track.clips.first;

        final newClip = AudioClip(
          id: '${originalClip.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
          path: originalClip.path,
          controller: originalClip.controller,
          volume: originalClip.volume,
          startTime: originalClip.startTime + const Duration(seconds: 2),
          endTime: originalClip.endTime + const Duration(seconds: 2),
        );

        track.addClip(newClip);

        updateTotalDuration();

        _dawViewModel.notifyListeners();
        notifyListeners();

        print('Duplicated clip: ${originalClip.id} -> ${newClip.id}');
        return;
      }
    }

    if (_dawViewModel.mixedVocalTrack != null && _dawViewModel.mixedVocalTrack!.clips.isNotEmpty) {
      final originalClip = _dawViewModel.mixedVocalTrack!.clips.first;

      final newClip = AudioClip(
        id: '${originalClip.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
        path: originalClip.path,
        controller: originalClip.controller,
        volume: originalClip.volume,
        startTime: originalClip.startTime + const Duration(seconds: 2),
        endTime: originalClip.endTime + const Duration(seconds: 2),
      );

      _dawViewModel.mixedVocalTrack!.addClip(newClip);
      updateTotalDuration();
      _dawViewModel.notifyListeners();
      notifyListeners();

      print('Duplicated clip: ${originalClip.id} -> ${newClip.id}');
      return;
    }

    print('No clips found to duplicate');
    notifyListeners();
  }

  double durationToPixels(Duration duration) {
    return duration.inMilliseconds / 1000.0 * pixelsPerSecond;
  }

  Duration pixelsToDuration(double pixels) {
    return Duration(milliseconds: (pixels / pixelsPerSecond * 1000).round());
  }

  void selectClip(String? clipId) {
    _state = _state.copyWith(selectedClipId: clipId);
    notifyListeners();
  }

  void startDragging(String clipId, Offset position) {
    _state = _state.copyWith(isDragging: true, dragStartPosition: position, selectedClipId: clipId);
    notifyListeners();
  }

  void dragClip(Offset position) {
    if (!isDragging || dragStartPosition == null) return;

    final deltaX = position.dx - dragStartPosition!.dx;
    final deltaDuration = pixelsToDuration(deltaX);

    final clip = _findClipById(selectedClipId!);
    if (clip == null) return;

    final newStartTime =
        snapToGrid ? snapDurationToGrid(clip.startTime + deltaDuration) : clip.startTime + deltaDuration;

    if (newStartTime >= Duration.zero) {
      moveClip(selectedClipId!, newStartTime);
      _state = _state.copyWith(dragStartPosition: position);
      notifyListeners();
    }
  }

  void stopDragging() {
    _state = _state.copyWith(isDragging: false, dragStartPosition: null);
    notifyListeners();
  }

  AudioClip? _findClipById(String clipId) {
    for (final track in _dawViewModel.vocalTracks) {
      try {
        return track.clips.firstWhere((c) => c.id == clipId);
      } catch (e) {
        // not found in this track
      }
    }
    if (_dawViewModel.beatTrack.clips.any((c) => c.id == clipId)) {
      return _dawViewModel.beatTrack.clips.firstWhere((c) => c.id == clipId);
    }
    if (_dawViewModel.mixedVocalTrack?.clips.any((c) => c.id == clipId) ?? false) {
      return _dawViewModel.mixedVocalTrack!.clips.firstWhere((c) => c.id == clipId);
    }
    if (_dawViewModel.masteredSongTrack?.clips.any((c) => c.id == clipId) ?? false) {
      return _dawViewModel.masteredSongTrack!.clips.firstWhere((c) => c.id == clipId);
    }
    return null;
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final milliseconds = duration.inMilliseconds % 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(milliseconds / 10).round().toString().padLeft(2, '0')}';
  }
}
