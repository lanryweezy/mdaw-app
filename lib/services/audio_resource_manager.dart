import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:studio_wiz/models/audio_clip.dart';

/// Manages audio resources and prevents memory leaks
class AudioResourceManager {
  static final AudioResourceManager _instance = AudioResourceManager._internal();
  factory AudioResourceManager() => _instance;
  AudioResourceManager._internal();

  /// Cache for player controllers to prevent recreation
  final Map<String, PlayerController> _controllerCache = {};
  
  /// Track active controllers for proper cleanup
  final Set<PlayerController> _activeControllers = {};
  
  /// Cache for audio metadata
  final Map<String, Map<String, dynamic>> _metadataCache = {};

  /// Maximum number of cached controllers
  static const int _maxCacheSize = 10;

  /// Creates or retrieves a cached PlayerController
  Future<PlayerController> getOrCreateController(String path) async {
    // Check cache first
    if (_controllerCache.containsKey(path)) {
      final controller = _controllerCache[path]!;
      if (controller.playerState != PlayerState.stopped) {
        _activeControllers.add(controller);
        return controller;
      }
    }

    // Create new controller
    final controller = PlayerController();
    
    try {
      await controller.preparePlayer(
        path: path,
        shouldExtractWaveform: true,
        noOfSamples: 100,
      );
      
      // Cache the controller if we haven't exceeded limit
      if (_controllerCache.length < _maxCacheSize) {
        _controllerCache[path] = controller;
      }
      
      _activeControllers.add(controller);
      return controller;
    } catch (e) {
      // Clean up if creation fails
      controller.dispose();
      rethrow;
    }
  }

  /// Safely disposes a controller
  Future<void> disposeController(PlayerController controller) async {
    if (_activeControllers.contains(controller)) {
      _activeControllers.remove(controller);
      
      // Don't dispose if it's in cache
      bool isInCache = _controllerCache.values.contains(controller);
      if (!isInCache && controller.playerState != PlayerState.stopped) {
        controller.dispose();
      }
    }
  }

  /// Disposes all active controllers
  Future<void> disposeAllControllers() async {
    final controllersToDispose = List<PlayerController>.from(_activeControllers);
    _activeControllers.clear();
    
    for (final controller in controllersToDispose) {
      if (!_controllerCache.values.contains(controller) && 
          controller.playerState != PlayerState.stopped) {
        controller.dispose();
      }
    }
  }

  /// Clears the controller cache
  Future<void> clearCache() async {
    for (final controller in _controllerCache.values) {
      if (controller.playerState != PlayerState.stopped) {
        controller.dispose();
      }
    }
    _controllerCache.clear();
  }

  /// Caches audio metadata
  void cacheMetadata(String path, Map<String, dynamic> metadata) {
    _metadataCache[path] = metadata;
  }

  /// Retrieves cached audio metadata
  Map<String, dynamic>? getCachedMetadata(String path) {
    return _metadataCache[path];
  }

  /// Clears metadata cache
  void clearMetadataCache() {
    _metadataCache.clear();
  }

  /// Gets the number of active controllers
  int get activeControllerCount => _activeControllers.length;
  
  /// Gets the number of cached controllers
  int get cachedControllerCount => _controllerCache.length;

  /// Checks if a controller is cached
  bool isControllerCached(String path) => _controllerCache.containsKey(path);
}
