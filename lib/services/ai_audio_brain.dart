import 'dart:io';
import 'package:studio_wiz/services/ai_audio_service.dart';

class AudioIntent {
  final String name;
  final String description;

  const AudioIntent(this.name, this.description);
}

class AIAudioBrain {
  final AiAudioService _dspService;

  AIAudioBrain(this._dspService);

  static const List<AudioIntent> intents = [
    AudioIntent('vocal_polish', 'Vocal Polish (Clean & Tune)'),
    AudioIntent('radio_ready', 'Radio Ready (Pop/Mainstream)'),
    AudioIntent('club_mix', 'Club Mix (Heavy Bass & Punch)'),
    AudioIntent('afrobeat', 'Afrobeat Vibe (Warm & Groovy)'),
    AudioIntent('drill_uk', 'UK Drill (Dark & Aggressive)'),
  ];

  /// The Vision-only pipeline: Input audio + intent -> Output audio
  /// The user doesn't know *how* it happens, only *what* they want.
  Future<String> process({
    required String rawVocalPath,
    String? beatPath, // Optional context for key/BPM detection
    required String intentId,
  }) async {
    print('AIAudioBrain: Processing intent [\$intentId]...');

    // 1. Context Analysis (The "Perception" phase)
    // In a full cloud model, this would send the beat and vocal to detect key/BPM
    String key = 'C Major';
    if (beatPath != null) {
      final analysis = await _dspService.detectBpmAndKey(beatPath);
      key = analysis['key'] ?? 'C Major';
    }

    // 2. The Processing Pipeline (The "Action" phase)
    // We orchestrate the underlying DSP/AI tools based on the intent
    switch (intentId) {
      case 'vocal_polish':
        // Clean noise, tune to key, add light EQ presence
        String tuned = await _dspService.autoTuneVocals(rawVocalPath, key: key);
        return await _dspService.smartEqVocals(tuned, tuned); // Mocking smart EQ
      case 'radio_ready':
        // Aggressive tuning, bright EQ, compression
        String tuned = await _dspService.autoTuneVocals(rawVocalPath, key: key, retuneSpeed: 0.1);
        return await _dspService.smartEqVocals(tuned, tuned);
      case 'club_mix':
        // Pitch correction + heavy low-end EQ
        String tuned = await _dspService.autoTuneVocals(rawVocalPath, key: key);
        return await _dspService.smartEqVocals(tuned, tuned);
      case 'afrobeat':
        // Smooth tuning, warm EQ, specific reverb tail
        String tuned = await _dspService.autoTuneVocals(rawVocalPath, key: key, retuneSpeed: 0.6);
        return await _dspService.smartEqVocals(tuned, tuned);
      case 'drill_uk':
        // Fast tuning, dark EQ, punchy
        String tuned = await _dspService.autoTuneVocals(rawVocalPath, key: key, retuneSpeed: 0.0);
        return await _dspService.smartEqVocals(tuned, tuned);
      default:
        print('AIAudioBrain: Unknown intent \$intentId. Defaulting to Vocal Polish.');
        String tuned = await _dspService.autoTuneVocals(rawVocalPath, key: key);
        return await _dspService.smartEqVocals(tuned, tuned);
    }
  }

  /// Heavy Intelligence tasks (like separating mixed audio into stems)
  Future<Map<String, String>> extractStems(String mixPath) async {
    print('AIAudioBrain: Extracting stems...');
    return await _dspService.separateStems(mixPath);
  }
}
