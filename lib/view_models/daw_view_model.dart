import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart' as recorder;
import 'package:path_provider/path_provider.dart';
import 'package:studio_wiz/services/enhanced_audio_processing_service.dart';
import 'package:studio_wiz/services/audio_resource_manager.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:studio_wiz/models/audio_clip.dart';
import 'package:studio_wiz/models/timing_system.dart';
import 'package:studio_wiz/models/automation_system.dart';
import 'package:studio_wiz/models/audio_effects.dart';

// Simple effect class to track effect states
class AudioEffect {
  final String name;
  final String id;
  bool isEnabled;
  Map<String, dynamic> parameters;

  AudioEffect({
    required this.name,
    required this.id,
    this.isEnabled = false,
    Map<String, dynamic>? parameters,
  }) : parameters = parameters ?? {};
}

class DawViewModel extends ChangeNotifier {
  late Track beatTrack;
  final List<Track> vocalTracks = [];
  Track? mixedVocalTrack; // New track for mixed vocals
  Track? masteredSongTrack; // New track for mastered song
  Track? selectedTrack;

  final recorder.AudioRecorder _audioRecorder = recorder.AudioRecorder();
  final EnhancedAudioProcessingService _audioProcessingService = EnhancedAudioProcessingService();

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Duration _currentPlaybackPosition = Duration.zero;
  Duration get currentPlaybackPosition => _currentPlaybackPosition;

  StreamSubscription<int>? _playbackPositionSubscription;
  
  // Processing states
  bool _isProcessing = false;
  String? _currentOperation;
  double? _processingProgress;
  double masterVolume = 1.0;
  
  // Timing system
  final TimingSystem _timingSystem = TimingSystem();
  
  // Automation system
  final AutomationSystem _automationSystem = AutomationSystem();
  
  // Effects management
  final Map<String, AudioEffect> _effects = {};
  
  // Automation data
  final Map<String, List<Map<String, dynamic>>> _automationData = {};
  bool _isRecordingAutomation = false;
  final Set<String> _automatedParameters = {};
  final Map<String, dynamic> _currentAutomationValues = {};
  bool _isPlayingAutomation = false;
  
  // Getters for processing state
  bool get isProcessing => _isProcessing;
  String? get currentOperation => _currentOperation;
  double? get processingProgress => _processingProgress;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  DawViewModel() {
    _init();
  }

  void _init() {
    beatTrack = Track(id: 'beat', name: 'Beat', type: TrackType.beat);
    for (int i = 0; i < 7; i++) {
      vocalTracks.add(Track(
        id: 'vocal_${i + 1}', 
        name: 'Vocal ${i + 1}', 
        type: TrackType.vocal
      ));
    }
    
    // Initialize common effects
    _effects['eq'] = AudioEffect(name: 'EQ', id: 'eq');
    _effects['compressor'] = AudioEffect(name: 'Compressor', id: 'compressor');
    _effects['reverb'] = AudioEffect(name: 'Reverb', id: 'reverb');
    _effects['delay'] = AudioEffect(name: 'Delay', id: 'delay');
    _effects['chorus'] = AudioEffect(name: 'Chorus', id: 'chorus');
  }

  void addVocalTrack() {
    final newTrackNumber = vocalTracks.length + 1;
    vocalTracks.add(Track(
      id: 'vocal_$newTrackNumber', 
      name: 'Vocal $newTrackNumber', 
      type: TrackType.vocal
    ));
    notifyListeners();
  }

  void selectTrack(Track? track) {
    selectedTrack = track;
    notifyListeners();
  }

  // Helper to get all active clips for playback
  List<AudioClip> get _allActiveClips {
    List<AudioClip> activeClips = [];
    bool anySolo = vocalTracks.any((t) => t.soloed) || beatTrack.soloed;

    // Add beat track clips
    if (beatTrack.hasAudio) {
      if (!anySolo || beatTrack.soloed) {
        if (!beatTrack.muted) {
          activeClips.addAll(beatTrack.clips);
        }
      }
    }

    // Add vocal track clips
    for (var track in vocalTracks) {
      if (track.hasAudio) {
        if (!anySolo || track.soloed) {
          if (!track.muted) {
            activeClips.addAll(track.clips);
          }
        }
      }
    }

    // Add mixed vocal track if it exists and is active
    if (mixedVocalTrack != null && mixedVocalTrack!.hasAudio) {
      if (!anySolo || mixedVocalTrack!.soloed) {
        if (!mixedVocalTrack!.muted) {
          activeClips.addAll(mixedVocalTrack!.clips);
        }
      }
    }

    // Add mastered song track if it exists and is active
    if (masteredSongTrack != null && masteredSongTrack!.hasAudio) {
      if (!anySolo || masteredSongTrack!.soloed) {
        if (!masteredSongTrack!.muted) {
          activeClips.addAll(masteredSongTrack!.clips);
        }
      }
    }

    return activeClips;
  }

  void _onPlayerStateChanged(PlayerState state, String clipId) {
    if (state == PlayerState.stopped) {
      bool allCompleted = _allActiveClips.every((clip) =>
          clip.controller.playerState == PlayerState.stopped);
      if (allCompleted) {
        _isPlaying = false;
        _currentPlaybackPosition = Duration.zero; // Reset on full stop
        _playbackPositionSubscription?.cancel(); // Stop listening
        notifyListeners();
      }
    }
  }

  Future<void> importAudio(Track targetTrack) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final clipId = DateTime.now().millisecondsSinceEpoch.toString();
      final controller = PlayerController();

      final waveform = await controller.extractWaveformData(path: path, noOfSamples: 100);

      await controller.preparePlayer(
        path: path,
        shouldExtractWaveform: true,
        noOfSamples: 100,
      );
      controller.onPlayerStateChanged.listen((state) => _onPlayerStateChanged(state, clipId));

      final newClip = AudioClip(
        id: clipId,
        path: path,
        controller: controller,
        volume: 1.0,
        startTime: Duration.zero,
        endTime: Duration(milliseconds: await controller.getDuration() ?? 0),
        waveform: waveform,
      );

      targetTrack.clips.clear();
      targetTrack.addClip(newClip);
      notifyListeners();
    }
  }

  Future<void> toggleRecording(Track targetTrack) async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        final clipId = DateTime.now().millisecondsSinceEpoch.toString();
        final controller = await AudioResourceManager().getOrCreateController(path);
        final waveform = await controller.extractWaveformData(path: path, noOfSamples: 100);

        controller.onPlayerStateChanged.listen((state) => _onPlayerStateChanged(state, clipId));

        final newClip = AudioClip(
          id: clipId,
          path: path,
          controller: controller,
          volume: 1.0,
          startTime: Duration.zero,
          endTime: Duration(milliseconds: await controller.getDuration() ?? 0),
          waveform: waveform,
        );

        targetTrack.clips.clear();
        targetTrack.addClip(newClip);
      }
      _isRecording = false;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const recorder.RecordConfig(), path: path);
      _isRecording = true;
    }
    notifyListeners();
  }

  void play() {
    if (_isPlaying) return;
    if (_allActiveClips.isEmpty) return;

    // Start listening to playback position from the first active clip
    _playbackPositionSubscription?.cancel(); // Cancel previous subscription
    final firstActiveClip = _allActiveClips.first;
    _playbackPositionSubscription = firstActiveClip.controller.onCurrentDurationChanged.listen((duration) {
      _currentPlaybackPosition = Duration(milliseconds: duration);
      
      // If recording automation, record data points
      if (_isRecordingAutomation) {
        for (final param in _automatedParameters) {
          // In a real implementation, we would get the current value of the parameter
          // For now, we'll just record a dummy value
          final dummyValue = param == 'Volume' ? 0.8 : 0.5;
          recordAutomationDataPoint(param, dummyValue);
        }
      }
      
      // If playing automation, update parameter values
      if (_isPlayingAutomation) {
        for (final param in _automatedParameters) {
          final value = getAutomationValueAtTime(param, _currentPlaybackPosition);
          if (value != null) {
            updateAutomationValue(param, value);
          }
        }
      }
      
      notifyListeners(); // Notify UI about position change
    });

    for (var clip in _allActiveClips) {
      // Apply master volume when starting playback
      final finalVolume = clip.volume * masterVolume;
      clip.controller.setVolume(finalVolume);
      
      clip.controller.seekTo(_currentPlaybackPosition.inMilliseconds); // Seek to current position
      clip.controller.startPlayer();
    }
    _isPlaying = true;
    notifyListeners();
  }

  void pause() {
    if (!_isPlaying) return;
    for (var clip in _allActiveClips) {
      if (clip.controller.playerState == PlayerState.playing) {
        clip.controller.pausePlayer();
      }
    }
    _isPlaying = false;
    _playbackPositionSubscription?.cancel(); // Stop listening
    notifyListeners();
  }

  void stop() {
    for (var clip in _allActiveClips) {
      clip.controller.stopPlayer();
    }
    _isPlaying = false;
    _currentPlaybackPosition = Duration.zero; // Reset to start
    _playbackPositionSubscription?.cancel(); // Stop listening
    
    // Stop automation recording/playback if active
    if (_isRecordingAutomation) {
      stopAutomationRecording();
    }
    if (_isPlayingAutomation) {
      stopAutomationPlayback();
    }
    
    notifyListeners();
  }

  void seekTo(Duration position) {
    _currentPlaybackPosition = position;
    for (var clip in _allActiveClips) {
      clip.controller.seekTo(position.inMilliseconds);
    }
    notifyListeners();
  }

  void setVolume(Track track, AudioClip? clip, double volume) {
    // If clip is null, apply to all clips in the track
    if (clip == null) {
      for (var c in track.clips) {
        c.volume = volume;
        // Apply master volume if currently playing
        if (_isPlaying) {
          final finalVolume = volume * masterVolume;
          c.controller.setVolume(finalVolume);
        } else {
          c.controller.setVolume(volume);
        }
      }
    } else {
      clip.volume = volume;
      // Apply master volume if currently playing
      if (_isPlaying) {
        final finalVolume = volume * masterVolume;
        clip.controller.setVolume(finalVolume);
      } else {
        clip.controller.setVolume(volume);
      }
    }
    notifyListeners();
  }

  void setPan(Track track, double pan) {
    track.pan = pan.clamp(-1.0, 1.0);
    // Note: Actual audio panning would require additional implementation
    // in the audio engine, which is not currently supported by the PlayerController
    notifyListeners();
  }

  void toggleEffect(String effectName, bool isEnabled) {
    // Find effect by name (case insensitive)
    final effect = _effects.values.firstWhere(
      (e) => e.name.toLowerCase() == effectName.toLowerCase(),
      orElse: () {
        // If effect doesn't exist, create it
        final id = effectName.toLowerCase().replaceAll(' ', '_');
        final newEffect = AudioEffect(name: effectName, id: id, isEnabled: isEnabled);
        _effects[id] = newEffect;
        return newEffect;
      },
    );
    
    effect.isEnabled = isEnabled;
    print('Toggling effect ${effect.name}: $isEnabled');
    
    // In a full implementation, this would apply the effect to the audio
    // For now, we just update the state
    notifyListeners();
  }

  void openEffectSettings(String effectName) {
    // Find effect by name (case insensitive)
    final effect = _effects.values.firstWhere(
      (e) => e.name.toLowerCase() == effectName.toLowerCase(),
      orElse: () => throw Exception('Effect not found: $effectName'),
    );
    
    print('Opening settings for effect ${effect.name}');
    
    // In a full implementation, this would open a dialog with effect parameters
    // For now, we just print the current parameters
    print('Current parameters: ${effect.parameters}');
    
    // Store the effect that is currently having its settings opened
    _currentEffectSettings = effect;
    
    notifyListeners();
  }
  
  // Add a field to track which effect settings are being shown
  AudioEffect? _currentEffectSettings;
  AudioEffect? get currentEffectSettings => _currentEffectSettings;
  
  // Method to close effect settings
  void closeEffectSettings() {
    _currentEffectSettings = null;
    notifyListeners();
  }
  
  // Helper method to get effect state
  AudioEffect? getEffect(String effectName) {
    try {
      return _effects.values.firstWhere(
        (e) => e.name.toLowerCase() == effectName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
  
  // Helper method to update effect parameters
  void updateEffectParameters(String effectName, Map<String, dynamic> parameters) {
    final effect = _effects.values.firstWhere(
      (e) => e.name.toLowerCase() == effectName.toLowerCase(),
      orElse: () => throw Exception('Effect not found: $effectName'),
    );
    
    effect.parameters.addAll(parameters);
    notifyListeners();
  }
  
  void toggleMute(Track track) {
    track.muted = !track.muted;
    if (_isPlaying) {
      play(); // Re-evaluate who should play
    }
    notifyListeners();
  }

  void toggleCollapse(Track track) {
    track.collapsed = !track.collapsed;
    notifyListeners();
  }

  void setCollapsed(Track track, bool collapsed) {
    track.collapsed = collapsed;
    notifyListeners();
  }

  void toggleCollapsed(Track track) {
    setCollapsed(track, !track.collapsed);
  }

  void setAllTracksCollapsed(bool collapsed) {
    setCollapsed(beatTrack, collapsed);
    for (var track in vocalTracks) {
      setCollapsed(track, collapsed);
    }
    if (mixedVocalTrack != null) {
      setCollapsed(mixedVocalTrack!, collapsed);
    }
    if (masteredSongTrack != null) {
      setCollapsed(masteredSongTrack!, collapsed);
    }
    notifyListeners();
  }

  void toggleAllTracksCollapsed() {
    // Check if any track is currently expanded
    bool anyExpanded = beatTrack.collapsed == false ||
        vocalTracks.any((track) => track.collapsed == false) ||
        (mixedVocalTrack != null && mixedVocalTrack!.collapsed == false) ||
        (masteredSongTrack != null && masteredSongTrack!.collapsed == false);
    
    // Collapse all if any are expanded, otherwise expand all
    setAllTracksCollapsed(anyExpanded);
  }

void setMasterVolume(double value) {
  masterVolume = value.clamp(0.0, 1.0);
  
  // Apply master volume to all active clips if playing
  if (_isPlaying) {
    for (var clip in _allActiveClips) {
      // Calculate final volume as clip volume * master volume
      final finalVolume = clip.volume * masterVolume;
      clip.controller.setVolume(finalVolume);
    }
  }
  
  notifyListeners();
}

void toggleSolo(Track track) {
    track.soloed = !track.soloed;

    if (track.soloed) {
      // If this track is soloed, unsolo all others
      beatTrack.soloed = false;
      for (var otherTrack in vocalTracks) {
        if (otherTrack.id != track.id) {
          otherTrack.soloed = false;
        }
      }
      if (mixedVocalTrack != null) mixedVocalTrack!.soloed = false;
      if (masteredSongTrack != null) masteredSongTrack!.soloed = false;
    }

    if (_isPlaying) {
      play(); // Re-evaluate who should play
    }
    notifyListeners();
  }

  Future<void> magicMixVocals() async {
    print('Magic Mix Vocals triggered!');
    final vocalInputPaths = vocalTracks.where((t) => t.hasAudio).expand((t) => t.clips.map((c) => c.path)).toList();

    if (vocalInputPaths.isEmpty) {
      print('No vocal tracks to mix.');
      return;
    }

    _startProcessing('Mixing Vocals...');
    
    try {
      final mixedVocalPath = await _audioProcessingService.applyAdvancedVocalEffects(vocalInputPaths);

      if (mixedVocalPath != null) {
        final clipId = DateTime.now().millisecondsSinceEpoch.toString();
        final controller = await AudioResourceManager().getOrCreateController(mixedVocalPath);
        controller.onPlayerStateChanged.listen((state) => _onPlayerStateChanged(state, clipId));

        final newClip = AudioClip(
          id: clipId,
          path: mixedVocalPath,
          controller: controller,
          volume: 1.0,
          startTime: Duration.zero,
          endTime: Duration(milliseconds: await controller.getDuration() ?? 0),
        );

        mixedVocalTrack = Track(
          id: 'mixed_vocals', 
          name: 'Mixed Vocals', 
          type: TrackType.mixed,
          clips: [newClip]
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error mixing vocals: $e');
    } finally {
      _finishProcessing();
    }
  }

  Future<void> applyPitchCorrection() async {
    _startProcessing('Applying pitch correction...');
    try {
      final vocalTrack = vocalTracks.firstWhere(
        (track) => track.hasAudio,
        orElse: () {
          _errorMessage = 'No vocal tracks found for pitch correction.';
          throw Exception(_errorMessage);
        },
      );
      final correctedPath = await _audioProcessingService.pitchCorrection(
        vocalTrack.clips.first.path,
      );
      if (correctedPath != null) {
        final newTrack = Track(id: 'pitch_corrected', name: 'Pitch Corrected', type: TrackType.processed);
        await importAudioFromPath(newTrack, correctedPath);
        vocalTracks.add(newTrack);
      }
    } catch (e) {
      _errorMessage = 'Error applying pitch correction: $e';
      print(_errorMessage);
    } finally {
      _finishProcessing();
    }
  }

  Future<String?> applyVocalMixing(List<String> vocalPaths, VocalMixPreset preset) async {
    _startProcessing('Applying vocal mixing...');
    try {
      final fadeInDurations = <String, Duration>{};
      final fadeOutDurations = <String, Duration>{};
      for (final track in vocalTracks) {
        for (final clip in track.clips) {
          fadeInDurations[clip.path] = clip.fadeInDuration;
          fadeOutDurations[clip.path] = clip.fadeOutDuration;
        }
      }

      final mixedPath = await _audioProcessingService.applyAdvancedVocalEffects(
        vocalPaths,
        fadeInDurations: fadeInDurations,
        fadeOutDurations: fadeOutDurations,
        effects: _effects.map((key, value) => MapEntry(key, {
          'isEnabled': value.isEnabled,
          'parameters': value.parameters,
        })),
      );
      if (mixedPath != null) {
        await importAudioFromPath(
          mixedVocalTrack ??
              (mixedVocalTrack = Track(
                id: 'mixed_vocals',
                name: 'Mixed Vocals',
                type: TrackType.mixed,
              )),
          mixedPath,
        );
      }
      return mixedPath;
    } catch (e) {
      _errorMessage = 'Error applying vocal mixing: $e';
      print(_errorMessage);
      return null;
    } finally {
      _finishProcessing();
    }
  }

  Future<void> applyMastering(MasteringPreset preset) async {
    // We are not using the preset for now, as the advanced service has its own chain.
    // This could be enhanced later to map presets to different chains.
    await aiMasterSong();
  }

  Future<void> aiMasterSong() async {
    _startProcessing('Mastering song...');

    try {
      final vocalInputPaths = vocalTracks.where((t) => t.hasAudio).expand((t) => t.clips.map((c) => c.path)).toList();
      final beatPath = beatTrack.hasAudio ? beatTrack.clips.first.path : null;

      if (vocalInputPaths.isEmpty || beatPath == null) {
        _errorMessage = 'Not enough audio to master. Need at least one vocal and one beat track.';
        print(_errorMessage);
        return;
      }

      // For simplicity, we use the first vocal track for mastering.
      // A more advanced implementation could mix them first.
      final vocalPath = vocalInputPaths.first;

      final masteredPath = await _audioProcessingService.masterSongAdvanced(vocalPath, beatPath);

      if (masteredPath != null) {
        await importAudioFromPath(
          masteredSongTrack ??
              (masteredSongTrack = Track(
                id: 'mastered_song',
                name: 'Mastered Song',
                type: TrackType.mastered,
              )),
          masteredPath,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error mastering song: $e';
      print(_errorMessage);
    } finally {
      _finishProcessing();
    }
  }

  Future<void> applyVocalDoubling() async {
    _startProcessing('Applying vocal doubling...');
    try {
      final vocalTrack = vocalTracks.firstWhere(
        (track) => track.hasAudio,
        orElse: () {
          _errorMessage = 'No vocal tracks found to apply doubling.';
          throw Exception(_errorMessage);
        },
      );
      final doubledPath = await _audioProcessingService.vocalDoubler(
        vocalTrack.clips.first.path,
      );
      if (doubledPath != null) {
        final newTrack = Track(id: 'vocal_doubled', name: 'Vocal Doubled', type: TrackType.processed);
        await importAudioFromPath(newTrack, doubledPath);
        vocalTracks.add(newTrack);
      }
    } catch (e) {
      _errorMessage = 'Error applying vocal doubling: $e';
      print(_errorMessage);
    } finally {
      _finishProcessing();
    }
  }

  Future<void> applyHarmonizer() async {
    _startProcessing('Creating harmonies...');
    try {
      final vocalTrack = vocalTracks.firstWhere(
        (track) => track.hasAudio,
        orElse: () {
          _errorMessage = 'No vocal tracks found to harmonize.';
          throw Exception(_errorMessage);
        },
      );
      final harmonizedPath = await _audioProcessingService.harmonizer(
        vocalTrack.clips.first.path,
      );
      if (harmonizedPath != null) {
        final newTrack = Track(id: 'harmonized', name: 'Harmonized', type: TrackType.processed);
        await importAudioFromPath(newTrack, harmonizedPath);
        vocalTracks.add(newTrack);
      }
    } catch (e) {
      _errorMessage = 'Error creating harmonies: $e';
      print(_errorMessage);
    } finally {
      _finishProcessing();
    }
  }

  Future<void> applyDeReverb() async {
    _startProcessing('Removing reverb...');
    try {
      final vocalTrack = vocalTracks.firstWhere(
        (track) => track.hasAudio,
        orElse: () {
          _errorMessage = 'No vocal tracks found to de-reverb.';
          throw Exception(_errorMessage);
        },
      );
      final dereverbedPath = await _audioProcessingService.deReverb(
        vocalTrack.clips.first.path,
      );
      if (dereverbedPath != null) {
        final newTrack = Track(id: 'de_reverb', name: 'De-Reverb', type: TrackType.processed);
        await importAudioFromPath(newTrack, dereverbedPath);
        vocalTracks.add(newTrack);
      }
    } catch (e) {
      _errorMessage = 'Error removing reverb: $e';
      print(_errorMessage);
    } finally {
      _finishProcessing();
    }
  }

  Future<void> applyRapProcessing() async {
    _startProcessing('Applying rap processing...');
    try {
      final vocalTrack = vocalTracks.firstWhere(
        (track) => track.hasAudio,
        orElse: () {
          _errorMessage = 'No vocal tracks found for rap processing.';
          throw Exception(_errorMessage);
        },
      );
      final rapPath = await _audioProcessingService.rapProcessing(
        vocalTrack.clips.first.path,
      );
      if (rapPath != null) {
        final newTrack = Track(id: 'rap_processed', name: 'Rap Processed', type: TrackType.processed);
        await importAudioFromPath(newTrack, rapPath);
        vocalTracks.add(newTrack);
      }
    } catch (e) {
      _errorMessage = 'Error applying rap processing: $e';
      print(_errorMessage);
    } finally {
      _finishProcessing();
    }
  }

  Future<void> applyTrapProcessing() async {
    _startProcessing('Applying trap processing...');
    try {
      final vocalTrack = vocalTracks.firstWhere(
        (track) => track.hasAudio,
        orElse: () {
          _errorMessage = 'No vocal tracks found for trap processing.';
          throw Exception(_errorMessage);
        },
      );
      final trapPath = await _audioProcessingService.trapProcessing(
        vocalTrack.clips.first.path,
      );
      if (trapPath != null) {
        final newTrack = Track(id: 'trap_processed', name: 'Trap Processed', type: TrackType.processed);
        await importAudioFromPath(newTrack, trapPath);
        vocalTracks.add(newTrack);
      }
    } catch (e) {
      _errorMessage = 'Error applying trap processing: $e';
      print(_errorMessage);
    } finally {
      _finishProcessing();
    }
  }

  Future<void> applyAfrobeatProcessing() async {
    _startProcessing('Applying afrobeat processing...');
    try {
      final vocalTrack = vocalTracks.firstWhere(
        (track) => track.hasAudio,
        orElse: () {
          _errorMessage = 'No vocal tracks found for afrobeat processing.';
          throw Exception(_errorMessage);
        },
      );
      final afrobeatPath = await _audioProcessingService.afrobeatProcessing(
        vocalTrack.clips.first.path,
      );
      if (afrobeatPath != null) {
        final newTrack = Track(id: 'afrobeat_processed', name: 'Afrobeat Processed', type: TrackType.processed);
        await importAudioFromPath(newTrack, afrobeatPath);
        vocalTracks.add(newTrack);
      }
    } catch (e) {
      _errorMessage = 'Error applying afrobeat processing: $e';
      print(_errorMessage);
    } finally {
      _finishProcessing();
    }
  }

  Future<void> applyDrillProcessing() async {
    _startProcessing('Applying drill processing...');
    try {
      final vocalTrack = vocalTracks.firstWhere(
        (track) => track.hasAudio,
        orElse: () {
          _errorMessage = 'No vocal tracks found for drill processing.';
          throw Exception(_errorMessage);
        },
      );
      final drillPath = await _audioProcessingService.drillProcessing(
        vocalTrack.clips.first.path,
      );
      if (drillPath != null) {
        final newTrack = Track(id: 'drill_processed', name: 'Drill Processed', type: TrackType.processed);
        await importAudioFromPath(newTrack, drillPath);
        vocalTracks.add(newTrack);
      }
    } catch (e) {
      _errorMessage = 'Error applying drill processing: $e';
      print(_errorMessage);
    } finally {
      _finishProcessing();
    }
  }

  // Project management methods
  void clearProject() {
    // Stop all playback
    stop();
    
    // Dispose all audio resources using the resource manager
    AudioResourceManager().disposeAllControllers();
    AudioResourceManager().clearCache();
    AudioResourceManager().clearMetadataCache();
    
    // Clear beat track
    beatTrack.clips.clear();
    
    // Clear vocal tracks
    for (var track in vocalTracks) {
      track.clips.clear();
      track.muted = false;
      track.soloed = false;
    }
    
    // Clear mixed and mastered tracks
    mixedVocalTrack = null;
    masteredSongTrack = null;
    
    notifyListeners();
  }

  Future<void> importAudioFromPath(Track track, String path) async {
    try {
      final clipId = DateTime.now().millisecondsSinceEpoch.toString();
      final controller = await AudioResourceManager().getOrCreateController(path);

      final newClip = AudioClip(
        id: clipId,
        path: path,
        controller: controller,
        volume: 1.0,
        startTime: Duration.zero,
        endTime: Duration(milliseconds: await controller.getDuration() ?? 0),
      );

      track.clips.add(newClip);
      notifyListeners();
    } catch (e) {
      print('Error importing audio from path: $e');
    }
  }

  // Processing state management
  void _startProcessing(String operation) {
    _isProcessing = true;
    _currentOperation = operation;
    _processingProgress = null;
    notifyListeners();
  }

  void _updateProgress(double progress) {
    _processingProgress = progress;
    notifyListeners();
  }

  void _finishProcessing() {
    _isProcessing = false;
    _currentOperation = null;
    _processingProgress = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Stop all playback first
    stop();
    
    // Dispose all audio resources using the resource manager
    AudioResourceManager().disposeAllControllers();
    AudioResourceManager().clearCache();
    
    // Dispose the audio recorder
    _audioRecorder.dispose();
    
    // Cancel the playback position subscription
    _playbackPositionSubscription?.cancel();
    
    super.dispose();
  }

  void startAutomationRecording() {
    if (_automatedParameters.isEmpty) {
      print('No parameters selected for automation');
      return;
    }
    
    print('Starting automation recording for parameters: $_automatedParameters');
    
    // Clear any existing automation data for the current parameters
    for (final param in _automatedParameters) {
      _automationData[param] = [];
    }
    
    _isRecordingAutomation = true;
    notifyListeners();
  }
  
  void stopAutomationRecording() {
    print('Stopping automation recording');
    _isRecordingAutomation = false;
    notifyListeners();
  }
  
  // Method to record automation data point
  void recordAutomationDataPoint(String parameter, dynamic value) {
    if (_isRecordingAutomation && _automatedParameters.contains(parameter)) {
      _automationData.putIfAbsent(parameter, () => []).add({
        'time': _currentPlaybackPosition.inMilliseconds,
        'value': value,
      });
      print('Recorded automation data point for $parameter: $value at ${_currentPlaybackPosition.inMilliseconds}ms');
    }
  }
  
  // Method to update current automation values (called during playback)
  void updateAutomationValue(String parameter, dynamic value) {
    _currentAutomationValues[parameter] = value;
    // In a full implementation, this would apply the value to the corresponding parameter
    print('Updated automation value for $parameter: $value');
  }
  
  // Getters for automation state
  bool get isRecordingAutomation => _isRecordingAutomation;
  Set<String> get automatedParameters => Set.unmodifiable(_automatedParameters);
  Map<String, dynamic> get currentAutomationValues => Map.unmodifiable(_currentAutomationValues);
  
  // Method to get recorded automation data for a parameter
  List<Map<String, dynamic>> getAutomationData(String parameter) {
    return _automationData[parameter] ?? [];
  }
  
  void selectAutomationParameter(String parameterName, bool isSelected) {
    print('Selecting automation parameter $parameterName: $isSelected');
    
    if (isSelected) {
      _automatedParameters.add(parameterName);
    } else {
      _automatedParameters.remove(parameterName);
      // Also remove any recorded data for this parameter
      _automationData.remove(parameterName);
    }
    
    notifyListeners();
  }
  
  void playAutomation() {
    if (!_isPlaying) {
      print('Cannot play automation when not playing audio');
      return;
    }
    
    if (_automatedParameters.isEmpty) {
      print('No parameters selected for automation playback');
      return;
    }
    
    print('Playing automation for parameters: $_automatedParameters');
    
    // In a full implementation, this would start playing back the recorded automation data
    // and update the corresponding parameters in real-time during playback
    // For now, we'll just simulate this by setting a flag
    _isPlayingAutomation = true;
    notifyListeners();
  }
  
  void stopAutomationPlayback() {
    print('Stopping automation playback');
    _isPlayingAutomation = false;
    notifyListeners();
  }
  
  // Add getter for automation playback state (field already defined on line 60)
  bool get isPlayingAutomation => _isPlayingAutomation;
  
  // Method to get interpolated automation value at a specific time
  dynamic getAutomationValueAtTime(String parameter, Duration time) {
    final dataPoints = _automationData[parameter];
    if (dataPoints == null || dataPoints.isEmpty) {
      return null;
    }
    
    final timeMs = time.inMilliseconds;
    
    // Find the data points before and after the current time
    Map<String, dynamic>? beforePoint;
    Map<String, dynamic>? afterPoint;
    
    for (final point in dataPoints) {
      final pointTime = point['time'] as int;
      if (pointTime <= timeMs) {
        beforePoint = point;
      } else {
        afterPoint = point;
        break;
      }
    }
    
    // If we only have one point or we're before the first point, return that value
    if (beforePoint == null || afterPoint == null) {
      return beforePoint?['value'] ?? afterPoint?['value'];
    }
    
    // Interpolate between the two points
    final beforeTime = beforePoint['time'] as int;
    final afterTime = afterPoint['time'] as int;
    final beforeValue = beforePoint['value'];
    final afterValue = afterPoint['value'];
    
    // Linear interpolation
    final ratio = (timeMs - beforeTime) / (afterTime - beforeTime);
    
    // Handle different value types
    if (beforeValue is double && afterValue is double) {
      return beforeValue + (afterValue - beforeValue) * ratio;
    } else if (beforeValue is int && afterValue is int) {
      return (beforeValue + (afterValue - beforeValue) * ratio).round();
    }
    
    // For other types, just return the before value
    return beforeValue;
  }

  // Method to cancel processing
  void cancelProcessing() {
    print('Canceling processing...');
    // In a real implementation, this would cancel any ongoing audio processing
    // For now, we just finish the processing to clear the UI
    _finishProcessing();
  }
}
