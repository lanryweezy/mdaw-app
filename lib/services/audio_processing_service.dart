
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

enum VocalMixPreset {
  pop,
  rnb,
  aggressive,
  warm,
  bright,
  vintage,
  rap,
  trap,
  afrobeat,
  drill,
  melodic,
  autotune,
}

enum MasteringPreset {
  loudAndClear,
  warmAndAnalog,
  punchy,
  smooth,
  commercial,
  streaming,
  rap,
  trap,
  afrobeat,
  drill,
  club,
  radio,
}

class AudioProcessingService {
  // Applies a chain of vocal effects to multiple input vocal tracks
  // and mixes them into a single output file.
  Future<String?> applyVocalEffects(
    List<String> vocalInputPaths, {
    VocalMixPreset preset = VocalMixPreset.pop,
  }) async {
    if (vocalInputPaths.isEmpty) return null;

    final dir = await getApplicationDocumentsDirectory();
    final outputPath = '${dir.path}/vocal_mix_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // Construct input part of the FFmpeg command
    String inputs = '';
    for (int i = 0; i < vocalInputPaths.length; i++) {
      inputs += '-i "${vocalInputPaths[i]}" ';
    }

    // Construct filter complex for mixing and effects
    // This is a simplified chain for demonstration:
    // 1. Mix all vocals
    // 2. Apply EQ (simple high-pass/low-pass for clarity)
    // 3. Apply Compressor (to even out dynamics)
    // 4. Apply Reverb (for space)
    String filterComplex = '';
    if (vocalInputPaths.length > 1) {
      // Mix multiple inputs
      filterComplex += '[0:a]';
      for (int i = 1; i < vocalInputPaths.length; i++) {
        filterComplex += '[${i}:a]';
      }
      filterComplex += 'amix=inputs=${vocalInputPaths.length}[vocal_mix];';
    } else {
      filterComplex += '[0:a][vocal_mix];'; // Single input, just label it
    }

    // Apply effects based on preset
    filterComplex += _getVocalEffectsChain(preset);

    final command = '$inputs -filter_complex "$filterComplex" -map "[vocal_final]" -c:a aac -b:a 192k "$outputPath" ';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('Vocal effects applied successfully to: $outputPath');
      return outputPath;
    } else if (ReturnCode.isCancel(returnCode)) {
      print('Vocal effects command cancelled');
    } else {
      print('Vocal effects command failed with state ${await session.getState()} and return code ${returnCode}');
      final output = await session.getOutput();
      print('FFmpeg output: $output');
    }
    return null;
  }

  // Masters the final song by mixing vocal mix and beat, then applying mastering effects.
  Future<String?> masterSong(
    String vocalMixPath, 
    String beatPath, {
    MasteringPreset preset = MasteringPreset.loudAndClear,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputPath = '${dir.path}/final_master_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // Get mastering chain based on preset
    final masteringChain = _getMasteringChain(preset);
    
    final command = '-i "$vocalMixPath" -i "$beatPath" -filter_complex "[0:a][1:a]amix=inputs=2[mix];$masteringChain" -map "[out]" -c:a aac -b:a 256k "$outputPath" ';

    print('FFmpeg Command: $command');
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('Song mastered successfully to: $outputPath');
      return outputPath;
    } else if (ReturnCode.isCancel(returnCode)) {
      print('Mastering command cancelled');
    } else {
      print('Mastering command failed with state ${await session.getState()} and return code ${returnCode}');
      final output = await session.getOutput();
      print('FFmpeg output: $output');
    }
    return null;
  }

  String _getVocalEffectsChain(VocalMixPreset preset) {
    switch (preset) {
      case VocalMixPreset.pop:
        return '[vocal_mix]'
            'anlmdn[vocal_denoise];' // Noise Reduction
            '[vocal_denoise]compand=attacks=0:points=-80/-90|-20/-20|0/-5:gain=5[vocal_deess];' // De-Esser
            '[vocal_deess]equalizer=f=150:t=l:width=100:g=-4:q=1[vocal_eq1];' // Cut low-mids
            '[vocal_eq1]equalizer=f=3000:t=h:width=1000:g=3:q=1[vocal_eq2];' // Boost presence
            '[vocal_eq2]acompressor=ratio=4:attack=20:release=100:threshold=-18dB[vocal_comp];' // Compression
            '[vocal_comp]adelay=delays=300|600:gains=0.5|0.3[vocal_delay];' // Delay
            '[vocal_delay]areverb=reverb_delay=0.5:reverb_decay=0.7[vocal_final]'; // Reverb

      case VocalMixPreset.rnb:
        return '[vocal_mix]'
            'anlmdn[vocal_denoise];' // Noise Reduction
            '[vocal_denoise]equalizer=f=200:t=l:width=150:g=-3:q=1[vocal_eq1];' // Cut lows
            '[vocal_eq1]equalizer=f=2500:t=h:width=800:g=2:q=1[vocal_eq2];' // Boost presence
            '[vocal_eq2]acompressor=ratio=3:attack=30:release=150:threshold=-20dB[vocal_comp];' // Gentle compression
            '[vocal_comp]adelay=delays=200|400:gains=0.4|0.2[vocal_delay];' // Subtle delay
            '[vocal_delay]areverb=reverb_delay=0.3:reverb_decay=0.5[vocal_final]'; // Light reverb

      case VocalMixPreset.aggressive:
        return '[vocal_mix]'
            'anlmdn[vocal_denoise];' // Noise Reduction
            '[vocal_denoise]equalizer=f=100:t=l:width=200:g=-6:q=1[vocal_eq1];' // Heavy low cut
            '[vocal_eq1]equalizer=f=4000:t=h:width=1200:g=4:q=1[vocal_eq2];' // Aggressive presence boost
            '[vocal_eq2]acompressor=ratio=6:attack=10:release=50:threshold=-15dB[vocal_comp];' // Heavy compression
            '[vocal_comp]adelay=delays=100|200:gains=0.6|0.4[vocal_delay];' // Tight delay
            '[vocal_delay]areverb=reverb_delay=0.2:reverb_decay=0.3[vocal_final]'; // Tight reverb

      case VocalMixPreset.warm:
        return '[vocal_mix]'
            'anlmdn[vocal_denoise];' // Noise Reduction
            '[vocal_denoise]equalizer=f=80:t=l:width=100:g=-2:q=1[vocal_eq1];' // Gentle low cut
            '[vocal_eq1]equalizer=f=2000:t=h:width=600:g=2:q=1[vocal_eq2];' // Warm presence
            '[vocal_eq2]acompressor=ratio=2.5:attack=50:release=200:threshold=-22dB[vocal_comp];' // Soft compression
            '[vocal_comp]adelay=delays=400|800:gains=0.3|0.15[vocal_delay];' // Warm delay
            '[vocal_delay]areverb=reverb_delay=0.8:reverb_decay=0.9[vocal_final]'; // Warm reverb

      case VocalMixPreset.bright:
        return '[vocal_mix]'
            'anlmdn[vocal_denoise];' // Noise Reduction
            '[vocal_denoise]equalizer=f=200:t=l:width=150:g=-5:q=1[vocal_eq1];' // Cut lows
            '[vocal_eq1]equalizer=f=5000:t=h:width=1500:g=4:q=1[vocal_eq2];' // Bright presence
            '[vocal_eq2]acompressor=ratio=3.5:attack=25:release=120:threshold=-19dB[vocal_comp];' // Moderate compression
            '[vocal_comp]adelay=delays=250|500:gains=0.4|0.2[vocal_delay];' // Bright delay
            '[vocal_delay]areverb=reverb_delay=0.4:reverb_decay=0.6[vocal_final]'; // Bright reverb

      case VocalMixPreset.vintage:
        return '[vocal_mix]'
            'anlmdn[vocal_denoise];' // Noise Reduction
            '[vocal_denoise]equalizer=f=150:t=l:width=100:g=-3:q=1[vocal_eq1];' // Gentle low cut
            '[vocal_eq1]equalizer=f=1800:t=h:width=500:g=1.5:q=1[vocal_eq2];' // Vintage presence
            '[vocal_eq2]acompressor=ratio=2:attack=100:release=300:threshold=-25dB[vocal_comp];' // Vintage compression
            '[vocal_comp]adelay=delays=600|1200:gains=0.25|0.12[vocal_delay];' // Vintage delay
            '[vocal_delay]areverb=reverb_delay=1.0:reverb_decay=1.2[vocal_final]'; // Vintage reverb

      case VocalMixPreset.rap:
        return '[vocal_mix]'
            'anlmdn[vocal_denoise];' // Noise Reduction
            '[vocal_denoise]equalizer=f=80:t=l:width=150:g=-5:q=1[vocal_eq1];' // Cut low mud
            '[vocal_eq1]equalizer=f=200:t=h:width=100:g=2:q=1[vocal_eq2];' // Boost clarity
            '[vocal_eq2]equalizer=f=3000:t=h:width=800:g=3:q=1[vocal_eq3];' // Boost presence
            '[vocal_eq3]acompressor=ratio=5:attack=15:release=80:threshold=-16dB[vocal_comp];' // Punchy compression
            '[vocal_comp]adelay=delays=150|300:gains=0.4|0.2[vocal_delay];' // Tight delay
            '[vocal_delay]areverb=reverb_delay=0.3:reverb_decay=0.4[vocal_final]'; // Tight reverb

      case VocalMixPreset.trap:
        return '[vocal_mix]'
            'anlmdn[vocal_denoise];' // Noise Reduction
            '[vocal_denoise]equalizer=f=100:t=l:width=200:g=-6:q=1[vocal_eq1];' // Heavy low cut
            '[vocal_eq1]equalizer=f=250:t=h:width=150:g=3:q=1[vocal_eq2];' // Boost punch
            '[vocal_eq2]equalizer=f=4000:t=h:width=1000:g=4:q=1[vocal_eq3];' // Aggressive presence
            '[vocal_eq3]acompressor=ratio=6:attack=8:release=60:threshold=-14dB[vocal_comp];' // Heavy compression
            '[vocal_comp]adelay=delays=100|200:gains=0.5|0.3[vocal_delay];' // Trap delay
            '[vocal_delay]areverb=reverb_delay=0.2:reverb_decay=0.3[vocal_final]'; // Tight reverb

      case VocalMixPreset.afrobeat:
        return '[vocal_mix]'
            'anlmdn[vocal_denoise];' // Noise Reduction
            '[vocal_denoise]equalizer=f=120:t=l:width=100:g=-3:q=1[vocal_eq1];' // Gentle low cut
            '[vocal_eq1]equalizer=f=800:t=h:width=300:g=2:q=1[vocal_eq2];' // Boost warmth
            '[vocal_eq2]equalizer=f=2500:t=h:width=600:g=2.5:q=1[vocal_eq3];' // Boost presence
            '[vocal_eq3]acompressor=ratio=3.5:attack=25:release=120:threshold=-18dB[vocal_comp];' // Smooth compression
            '[vocal_comp]adelay=delays=250|500:gains=0.3|0.15[vocal_delay];' // Afro delay
            '[vocal_delay]areverb=reverb_delay=0.6:reverb_decay=0.8[vocal_final]'; // Warm reverb

      case VocalMixPreset.drill:
        return '[vocal_mix]'
            'anlmdn[vocal_denoise];' // Noise Reduction
            '[vocal_denoise]equalizer=f=90:t=l:width=180:g=-7:q=1[vocal_eq1];' // Heavy low cut
            '[vocal_eq1]equalizer=f=200:t=h:width=120:g=4:q=1[vocal_eq2];' // Boost aggression
            '[vocal_eq2]equalizer=f=3500:t=h:width=900:g=5:q=1[vocal_eq3];' // Aggressive presence
            '[vocal_eq3]acompressor=ratio=7:attack=5:release=40:threshold=-12dB[vocal_comp];' // Very heavy compression
            '[vocal_comp]adelay=delays=80|160:gains=0.6|0.4[vocal_delay];' // Drill delay
            '[vocal_delay]areverb=reverb_delay=0.15:reverb_decay=0.25[vocal_final]'; // Very tight reverb

      case VocalMixPreset.melodic:
        return '[vocal_mix]'
            'anlmdn[vocal_denoise];' // Noise Reduction
            '[vocal_denoise]equalizer=f=100:t=l:width=120:g=-2:q=1[vocal_eq1];' // Gentle low cut
            '[vocal_eq1]equalizer=f=600:t=h:width=400:g=2:q=1[vocal_eq2];' // Boost warmth
            '[vocal_eq2]equalizer=f=2000:t=h:width=500:g=2.5:q=1[vocal_eq3];' // Boost presence
            '[vocal_eq3]acompressor=ratio=2.5:attack=40:release=150:threshold=-20dB[vocal_comp];' // Gentle compression
            '[vocal_comp]adelay=delays=300|600:gains=0.3|0.15[vocal_delay];' // Melodic delay
            '[vocal_delay]areverb=reverb_delay=0.7:reverb_decay=0.9[vocal_final]'; // Warm reverb

      case VocalMixPreset.autotune:
        return '[vocal_mix]'
            'anlmdn[vocal_denoise];' // Noise Reduction
            '[vocal_denoise]equalizer=f=150:t=l:width=100:g=-4:q=1[vocal_eq1];' // Cut lows
            '[vocal_eq1]equalizer=f=3000:t=h:width=800:g=3:q=1[vocal_eq2];' // Boost presence
            '[vocal_eq2]acompressor=ratio=4:attack=20:release=100:threshold=-18dB[vocal_comp];' // Compression
            '[vocal_comp]adelay=delays=200|400:gains=0.4|0.2[vocal_delay];' // Autotune delay
            '[vocal_delay]areverb=reverb_delay=0.4:reverb_decay=0.6[vocal_final]'; // Autotune reverb
    }
  }

  String _getMasteringChain(MasteringPreset preset) {
    switch (preset) {
      case MasteringPreset.loudAndClear:
        return '[mix]loudnorm=I=-14:LRA=7:TP=-1.0[loudnormed];' // Loud normalization
            '[loudnormed]acompressor=ratio=3:attack=10:release=100:threshold=-10dB[compressed];' // Punchy compression
            '[compressed]alimiter=level_in=0.95:level_out=0.95:limit=1:level=0.95[out]'; // Aggressive limiting

      case MasteringPreset.warmAndAnalog:
        return '[mix]loudnorm=I=-16:LRA=11:TP=-1.5[loudnormed];' // Gentle normalization
            '[loudnormed]acompressor=ratio=2:attack=50:release=200:threshold=-15dB[compressed];' // Warm compression
            '[compressed]equalizer=f=100:t=l:width=200:g=1:q=1[warmed];' // Warm EQ
            '[warmed]alimiter=level_in=0.9:level_out=0.9:limit=1:level=0.9[out]'; // Gentle limiting

      case MasteringPreset.punchy:
        return '[mix]loudnorm=I=-15:LRA=9:TP=-1.2[loudnormed];' // Moderate normalization
            '[loudnormed]acompressor=ratio=4:attack=5:release=50:threshold=-12dB[compressed];' // Punchy compression
            '[compressed]equalizer=f=60:t=l:width=100:g=2:q=1[punchy];' // Punchy low end
            '[punchy]alimiter=level_in=0.92:level_out=0.92:limit=1:level=0.92[out]'; // Punchy limiting

      case MasteringPreset.smooth:
        return '[mix]loudnorm=I=-17:LRA=13:TP=-1.8[loudnormed];' // Smooth normalization
            '[loudnormed]acompressor=ratio=1.5:attack=100:release=300:threshold=-20dB[compressed];' // Smooth compression
            '[compressed]equalizer=f=200:t=l:width=300:g=1:q=1[smoothed];' // Smooth EQ
            '[smoothed]alimiter=level_in=0.85:level_out=0.85:limit=1:level=0.85[out]'; // Smooth limiting

      case MasteringPreset.commercial:
        return '[mix]loudnorm=I=-13:LRA=6:TP=-0.8[loudnormed];' // Commercial loudness
            '[loudnormed]acompressor=ratio=5:attack=8:release=80:threshold=-8dB[compressed];' // Commercial compression
            '[compressed]equalizer=f=80:t=l:width=150:g=3:q=1[commercial];' // Commercial EQ
            '[commercial]alimiter=level_in=0.98:level_out=0.98:limit=1:level=0.98[out]'; // Commercial limiting

      case MasteringPreset.streaming:
        return '[mix]loudnorm=I=-16:LRA=11:TP=-1.5[loudnormed];' // Streaming normalization
            '[loudnormed]acompressor=ratio=2.5:attack=20:release=150:threshold=-14dB[compressed];' // Streaming compression
            '[compressed]equalizer=f=120:t=l:width=200:g=1.5:q=1[streaming];' // Streaming EQ
            '[streaming]alimiter=level_in=0.9:level_out=0.9:limit=1:level=0.9[out]'; // Streaming limiting

      case MasteringPreset.rap:
        return '[mix]loudnorm=I=-15:LRA=8:TP=-1.2[loudnormed];' // Rap normalization
            '[loudnormed]acompressor=ratio=4:attack=10:release=80:threshold=-12dB[compressed];' // Punchy compression
            '[compressed]equalizer=f=80:t=l:width=150:g=2:q=1[rap_eq];' // Rap EQ
            '[rap_eq]alimiter=level_in=0.92:level_out=0.92:limit=1:level=0.92[out]'; // Rap limiting

      case MasteringPreset.trap:
        return '[mix]loudnorm=I=-14:LRA=7:TP=-1.0[loudnormed];' // Trap normalization
            '[loudnormed]acompressor=ratio=5:attack=8:release=60:threshold=-10dB[compressed];' // Heavy compression
            '[compressed]equalizer=f=60:t=l:width=120:g=3:q=1[trap_eq];' // Trap EQ
            '[trap_eq]alimiter=level_in=0.95:level_out=0.95:limit=1:level=0.95[out]'; // Trap limiting

      case MasteringPreset.afrobeat:
        return '[mix]loudnorm=I=-16:LRA=10:TP=-1.4[loudnormed];' // Afrobeat normalization
            '[loudnormed]acompressor=ratio=3:attack=25:release=120:threshold=-15dB[compressed];' // Smooth compression
            '[compressed]equalizer=f=100:t=l:width=200:g=1.5:q=1[afro_eq];' // Afrobeat EQ
            '[afro_eq]alimiter=level_in=0.88:level_out=0.88:limit=1:level=0.88[out]'; // Afrobeat limiting

      case MasteringPreset.drill:
        return '[mix]loudnorm=I=-13:LRA=6:TP=-0.8[loudnormed];' // Drill normalization
            '[loudnormed]acompressor=ratio=6:attack=5:release=50:threshold=-8dB[compressed];' // Very heavy compression
            '[compressed]equalizer=f=50:t=l:width=100:g=4:q=1[drill_eq];' // Drill EQ
            '[drill_eq]alimiter=level_in=0.98:level_out=0.98:limit=1:level=0.98[out]'; // Drill limiting

      case MasteringPreset.club:
        return '[mix]loudnorm=I=-12:LRA=5:TP=-0.5[loudnormed];' // Club normalization
            '[loudnormed]acompressor=ratio=8:attack=3:release=30:threshold=-6dB[compressed];' // Club compression
            '[compressed]equalizer=f=40:t=l:width=80:g=5:q=1[club_eq];' // Club EQ
            '[club_eq]alimiter=level_in=1.0:level_out=1.0:limit=1:level=1.0[out]'; // Club limiting

      case MasteringPreset.radio:
        return '[mix]loudnorm=I=-16:LRA=11:TP=-1.5[loudnormed];' // Radio normalization
            '[loudnormed]acompressor=ratio=2:attack=50:release=200:threshold=-18dB[compressed];' // Radio compression
            '[compressed]equalizer=f=150:t=l:width=300:g=1:q=1[radio_eq];' // Radio EQ
            '[radio_eq]alimiter=level_in=0.85:level_out=0.85:limit=1:level=0.85[out]'; // Radio limiting
    }
  }

  // Advanced vocal processing methods
  Future<String?> applyVocalDoubling(String vocalPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputPath = '${dir.path}/vocal_doubled_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // Create vocal doubling effect using pitch shifting and delay
    final command = '-i "$vocalPath" -filter_complex '
        '"[0:a]apitch=shift=0.05[vocal1];' // Slight pitch shift
        '[0:a]apitch=shift=-0.05[vocal2];' // Opposite pitch shift
        '[0:a][vocal1][vocal2]amix=inputs=3:weights=1 0.3 0.3[vocal_doubled]" '
        '-map "[vocal_doubled]" -c:a aac -b:a 192k "$outputPath"';

    print('Vocal Doubling Command: $command');
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('Vocal doubling applied successfully to: $outputPath');
      return outputPath;
    } else {
      print('Vocal doubling failed with return code ${returnCode}');
      return null;
    }
  }

  Future<String?> applyHarmonizer(String vocalPath, List<double> pitchShifts) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputPath = '${dir.path}/vocal_harmonized_${DateTime.now().millisecondsSinceEpoch}.m4a';

    String filterComplex = '';
    String mixInputs = '[0:a]';
    String mixWeights = '1';

    // Create harmonized voices
    for (int i = 0; i < pitchShifts.length; i++) {
      final shift = pitchShifts[i];
      filterComplex += '[0:a]apitch=shift=$shift[harmony$i];';
      mixInputs += '[harmony$i]';
      mixWeights += ' 0.4'; // Lower volume for harmonies
    }

    final command = '-i "$vocalPath" -filter_complex '
        '"$filterComplex$mixInputs amix=inputs=${pitchShifts.length + 1}:weights=$mixWeights[harmonized]" '
        '-map "[harmonized]" -c:a aac -b:a 192k "$outputPath"';

    print('Harmonizer Command: $command');
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('Harmonizer applied successfully to: $outputPath');
      return outputPath;
    } else {
      print('Harmonizer failed with return code ${returnCode}');
      return null;
    }
  }

  Future<String?> applyDeReverb(String vocalPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputPath = '${dir.path}/vocal_dereverbed_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // Simple de-reverb using high-pass filter and noise reduction
    final command = '-i "$vocalPath" -filter_complex '
        '"[0:a]highpass=f=200[hp];' // High-pass filter
        '[hp]anlmdn[dereverbed]" ' // Noise reduction
        '-map "[dereverbed]" -c:a aac -b:a 192k "$outputPath"';

    print('De-Reverb Command: $command');
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('De-reverb applied successfully to: $outputPath');
      return outputPath;
    } else {
      print('De-reverb failed with return code ${returnCode}');
      return null;
    }
  }

  // Specialized processing for rap and trap genres
  Future<String?> applyRapProcessing(String vocalPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputPath = '${dir.path}/vocal_rap_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // Rap-specific processing: aggressive compression, punchy EQ, tight reverb
    final command = '-i "$vocalPath" -filter_complex '
        '"[0:a]anlmdn[denoise];' // Noise reduction
        '[denoise]equalizer=f=80:t=l:width=150:g=-5:q=1[eq1];' // Cut low mud
        '[eq1]equalizer=f=200:t=h:width=100:g=2:q=1[eq2];' // Boost clarity
        '[eq2]equalizer=f=3000:t=h:width=800:g=3:q=1[eq3];' // Boost presence
        '[eq3]acompressor=ratio=5:attack=15:release=80:threshold=-16dB[comp];' // Punchy compression
        '[comp]adelay=delays=150|300:gains=0.4|0.2[delay];' // Tight delay
        '[delay]areverb=reverb_delay=0.3:reverb_decay=0.4[rap_vocal]" ' // Tight reverb
        '-map "[rap_vocal]" -c:a aac -b:a 192k "$outputPath"';

    print('Rap Processing Command: $command');
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('Rap processing applied successfully to: $outputPath');
      return outputPath;
    } else {
      print('Rap processing failed with return code ${returnCode}');
      return null;
    }
  }

  Future<String?> applyTrapProcessing(String vocalPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputPath = '${dir.path}/vocal_trap_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // Trap-specific processing: very aggressive compression, heavy EQ, tight reverb
    final command = '-i "$vocalPath" -filter_complex '
        '"[0:a]anlmdn[denoise];' // Noise reduction
        '[denoise]equalizer=f=100:t=l:width=200:g=-6:q=1[eq1];' // Heavy low cut
        '[eq1]equalizer=f=250:t=h:width=150:g=3:q=1[eq2];' // Boost punch
        '[eq2]equalizer=f=4000:t=h:width=1000:g=4:q=1[eq3];' // Aggressive presence
        '[eq3]acompressor=ratio=6:attack=8:release=60:threshold=-14dB[comp];' // Heavy compression
        '[comp]adelay=delays=100|200:gains=0.5|0.3[delay];' // Trap delay
        '[delay]areverb=reverb_delay=0.2:reverb_decay=0.3[trap_vocal]" ' // Tight reverb
        '-map "[trap_vocal]" -c:a aac -b:a 192k "$outputPath"';

    print('Trap Processing Command: $command');
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('Trap processing applied successfully to: $outputPath');
      return outputPath;
    } else {
      print('Trap processing failed with return code ${returnCode}');
      return null;
    }
  }

  Future<String?> applyAfrobeatProcessing(String vocalPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputPath = '${dir.path}/vocal_afrobeat_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // Afrobeat-specific processing: warm EQ, smooth compression, warm reverb
    final command = '-i "$vocalPath" -filter_complex '
        '"[0:a]anlmdn[denoise];' // Noise reduction
        '[denoise]equalizer=f=120:t=l:width=100:g=-3:q=1[eq1];' // Gentle low cut
        '[eq1]equalizer=f=800:t=h:width=300:g=2:q=1[eq2];' // Boost warmth
        '[eq2]equalizer=f=2500:t=h:width=600:g=2.5:q=1[eq3];' // Boost presence
        '[eq3]acompressor=ratio=3.5:attack=25:release=120:threshold=-18dB[comp];' // Smooth compression
        '[comp]adelay=delays=250|500:gains=0.3|0.15[delay];' // Afro delay
        '[delay]areverb=reverb_delay=0.6:reverb_decay=0.8[afro_vocal]" ' // Warm reverb
        '-map "[afro_vocal]" -c:a aac -b:a 192k "$outputPath"';

    print('Afrobeat Processing Command: $command');
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('Afrobeat processing applied successfully to: $outputPath');
      return outputPath;
    } else {
      print('Afrobeat processing failed with return code ${returnCode}');
      return null;
    }
  }

  Future<String?> applyDrillProcessing(String vocalPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputPath = '${dir.path}/vocal_drill_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // Drill-specific processing: extremely aggressive compression, heavy EQ, very tight reverb
    final command = '-i "$vocalPath" -filter_complex '
        '"[0:a]anlmdn[denoise];' // Noise reduction
        '[denoise]equalizer=f=90:t=l:width=180:g=-7:q=1[eq1];' // Heavy low cut
        '[eq1]equalizer=f=200:t=h:width=120:g=4:q=1[eq2];' // Boost aggression
        '[eq2]equalizer=f=3500:t=h:width=900:g=5:q=1[eq3];' // Aggressive presence
        '[eq3]acompressor=ratio=7:attack=5:release=40:threshold=-12dB[comp];' // Very heavy compression
        '[comp]adelay=delays=80|160:gains=0.6|0.4[delay];' // Drill delay
        '[delay]areverb=reverb_delay=0.15:reverb_decay=0.25[drill_vocal]" ' // Very tight reverb
        '-map "[drill_vocal]" -c:a aac -b:a 192k "$outputPath"';

    print('Drill Processing Command: $command');
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('Drill processing applied successfully to: $outputPath');
      return outputPath;
    } else {
      print('Drill processing failed with return code ${returnCode}');
      return null;
    }
  }
}
