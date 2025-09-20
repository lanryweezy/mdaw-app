import 'dart:io';
import 'dart:math';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Enhanced audio processing service with improved quality and additional features
class EnhancedAudioProcessingService {
  static const String _tempDirName = 'mdaw_audio_processing';

  /// Get temporary directory for processing
  Future<Directory> _getTempDir() async {
    final tempDir = await getTemporaryDirectory();
    final audioTempDir = Directory('${tempDir.path}/$_tempDirName');
    
    if (!await audioTempDir.exists()) {
      await audioTempDir.create(recursive: true);
    }
    
    return audioTempDir;
  }

  /// Vocal doubler effect - creates a doubled vocal track
  Future<String?> vocalDoubler(String inputPath) async {
    final tempDir = await _getTempDir();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/doubled_vocal_$timestamp.wav';
    
    try {
      // Create doubled effect with slight delay and pitch variation
      final command = '''
      -i "$inputPath" 
      -filter_complex "
        [0:a]asplit=2[a1][a2];
        [a1]adelay=40|40[a1_delayed];
        [a2]apitch=1.02[a2_pitched];
        [a1_delayed][a2_pitched]amix=inputs=2:duration=longest:dropout_transition=2,alimiter=level_in=1:level_out=1:limit=-0.1:attack=5:release=50[a]
      " -map "[a]" -c:a pcm_s16le "$outputPath"
      '''.replaceAll('\n', ' ');
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        print('Failed to apply vocal doubler effect');
        return null;
      }
    } catch (e) {
      print('Error in vocal doubler: $e');
      return null;
    }
  }

  /// Harmonizer effect - adds harmony layers
  Future<String?> harmonizer(String inputPath) async {
    final tempDir = await _getTempDir();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/harmonized_$timestamp.wav';
    
    try {
      // Create harmony with pitch-shifted layers
      final command = '''
      -i "$inputPath" 
      -filter_complex "
        [0:a]asplit=3[a1][a2][a3];
        [a1]apitch=1.259921[a1_up];      # Major third up
        [a2]apitch=0.793701[a2_down];   # Minor third down
        [a3]apitch=1.498307[a3_fifth];  # Perfect fifth up
        [a1_up][a2_down][a3_fifth][0:a]amix=inputs=4:duration=longest:dropout_transition=2,alimiter=level_in=1:level_out=1:limit=-0.1:attack=5:release=50[a]
      " -map "[a]" -c:a pcm_s16le "$outputPath"
      '''.replaceAll('\n', ' ');
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        print('Failed to apply harmonizer effect');
        return null;
      }
    } catch (e) {
      print('Error in harmonizer: $e');
      return null;
    }
  }

  /// De-reverb effect
  Future<String?> deReverb(String inputPath) async {
    final tempDir = await _getTempDir();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/de_reverb_$timestamp.wav';
    
    try {
      // Simple de-reverb using spectral subtraction
      final command = '''
      -i "$inputPath" 
      -filter_complex "
        [0:a]arnndn=m=model.rnnn[a]
      " -map "[a]" -c:a pcm_s16le "$outputPath"
      '''.replaceAll('\n', ' ');
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        print('Failed to apply de-reverb effect');
        return null;
      }
    } catch (e) {
      print('Error in de-reverb: $e');
      return null;
    }
  }

  /// Drill processing effect
  Future<String?> drillProcessing(String inputPath) async {
    final tempDir = await _getTempDir();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/drill_processed_$timestamp.wav';
    
    try {
      // Drill-specific processing: heavy compression, low-end boost, aggressive EQ
      final command = '''
      -i "$inputPath" 
      -filter_complex "
        [0:a]
        highpass=f=90[a1];
        [a1]equalizer=f=200:t=q:w=1:g=4[a2];
        [a2]equalizer=f=3500:t=q:w=1:g=5[a3];
        [a3]acompressor=threshold=-12:ratio=7:attack=5:release=40:knee=2[a4];
        [a4]alimiter=level_in=1:level_out=1:limit=-0.1:attack=3:release=30[a]
      " -map "[a]" -c:a pcm_s16le "$outputPath"
      '''.replaceAll('\n', ' ');
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        print('Failed to apply drill processing effect');
        return null;
      }
    } catch (e) {
      print('Error in drill processing: $e');
      return null;
    }
  }

  /// Rap processing effect
  Future<String?> rapProcessing(String inputPath) async {
    final tempDir = await _getTempDir();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/rap_processed_$timestamp.wav';
    
    try {
      // Rap-specific processing: compression, EQ, and presence boost
      final command = '''
      -i "$inputPath" 
      -filter_complex "
        [0:a]
        highpass=f=80[a1];
        [a1]equalizer=f=3000:t=q:w=1:g=3[a2];
        [a2]equalizer=f=8000:t=q:w=1:g=2[a3];
        [a3]acompressor=threshold=-15:ratio=4:attack=5:release=50:knee=2[a4];
        [a4]alimiter=level_in=1:level_out=1:limit=-0.1:attack=3:release=30[a]
      " -map "[a]" -c:a pcm_s16le "$outputPath"
      '''.replaceAll('\n', ' ');
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        print('Failed to apply rap processing effect');
        return null;
      }
    } catch (e) {
      print('Error in rap processing: $e');
      return null;
    }
  }

  /// Clean up temporary files
  Future<void> _cleanTempFiles(List<String> filePaths) async {
    for (final filePath in filePaths) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting temp file: $e');
      }
    }
  }

  /// Get audio file information
  Future<Map<String, dynamic>> getAudioInfo(String filePath) async {
    try {
      final session = await FFprobeKit.getMediaInformation(filePath);
      final information = session.getMediaInformation();
      
      if (information == null) {
        throw Exception('Failed to get media information');
      }
      
      return {
        'duration': information.getDuration() ?? 0,
        'bitrate': information.getBitrate() ?? 0,
        'sample_rate': information.getStreams()?.first.getSampleRate() ?? 0,
        'channels': information.getStreams()?.first.getAllProperties()?['channels'] ?? 0,
        'format': information.getFormat() ?? '',
        'codec': information.getStreams()?.first.getCodec() ?? '',
      };
    } catch (e) {
      throw Exception('Failed to analyze audio file: $e');
    }
  }

  /// Advanced vocal effects processing with multiple enhancement stages
  Future<String?> applyAdvancedVocalEffects(List<String> inputPaths, {
    Map<String, Duration> fadeInDurations = const {},
    Map<String, Duration> fadeOutDurations = const {},
    Map<String, dynamic> effects = const {},
  }) async {
    if (inputPaths.isEmpty) return null;

    final tempDir = await _getTempDir();
    final timestamp = Date
        final command =
            '-i "$inputPath" -filter_complex "[0:a]${fadeCommand.isNotEmpty ? ',$fadeCommand' : ''}${effectsCommand.isNotEmpty ? ',$effectsCommand' : ''},loudnorm=I=-16:TP=-1.5:LRA=11[a]" -map "[a]" -c:a pcm_s16le "$processedPath"';

        final session = await FFmpegKit.execute(command);
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          processedFiles.add(processedPath);
        } else {
          print('Failed to process vocal track $i');
          processedFiles.add(inputPath); // Use original if processing fails
        }
      }

      // Step 2: Mix all processed vocals together
      final mixedPath = '${tempDir.path}/mixed_vocals_$timestamp.wav';
      final mixCommand = _buildMixCommand(processedFiles, mixedPath);
      final mixSession = await FFmpegKit.execute(mixCommand);
      final mixReturnCode = await mixSession.getReturnCode();

      if (!ReturnCode.isSuccess(mixReturnCode)) {
        throw Exception('Failed to mix vocal tracks');
      }

      // Step 3: Final mastering pass
      final finalPath = '${tempDir.path}/final_vocals_$timestamp.wav';
      final masterCommand =
          '-i "$mixedPath" -filter_complex "[0:a]loudnorm=I=-14:TP=-1.0:LRA=7[a]" -map "[a]" -c:a pcm_s16le "$finalPath"';

      final masterSession = await FFmpegKit.execute(masterCommand);
      final masterReturnCode = await masterSession.getReturnCode();

      // Clean up intermediate files
      await _cleanTempFiles([...processedFiles, mixedPath]);

      if (ReturnCode.isSuccess(masterReturnCode)) {
        return finalPath;
      } else {
        throw Exception('Failed to master vocal mix');
      }
    } catch (e) {
      print('Error in vocal effects processing: $e');
      return null;
    }
  }

  String _getEffectCommand(String effectName, Map<String, dynamic> parameters) {
    switch (effectName) {
      case 'eq':
        final gain = parameters['gain'];
        final frequency = parameters['frequency'];
        final q = parameters['q'];
        return ',equalizer=f=$frequency:t=h:width_type=q:w=$q:g=$gain';
      case 'compressor':
        final threshold = parameters['threshold'];
        final ratio = parameters['ratio'];
        final attack = parameters['attack'];
        final release = parameters['release'];
        return ',acompressor=threshold=${threshold}dB:ratio=$ratio:attack=$attack:release=$release';
      case 'reverb':
        final decay = parameters['decay'];
        final mix = parameters['mix'];
        return ',areverb=decay=$decay:mix=$mix';
      case 'delay':
        final time = parameters['time'];
        final feedback = parameters['feedback'];
        final mix = parameters['mix'];
        return ',adelay=$time|$time:gains=$mix|$mix:feedback=$feedback';
      case 'chorus':
        final rate = parameters['rate'];
        final depth = parameters['depth'];
        final mix = parameters['mix'];
        return ',chorus=$mix:$rate:$depth';
      default:
        return '';
    }
  }

  /// Build mix command for multiple audio files
  String _buildMixCommand(List<String> inputFiles, String outputPath) {
    final inputs = inputFiles.map((file) => '-i "$file"').join(' ');
    
    // Create complex filter for mixing
    final mixFilter = StringBuffer();
    mixFilter.write('[0:a]');
    
    for (int i = 1; i < inputFiles.length; i++) {
      mixFilter.write('[$i:a]');
    }
    
    mixFilter.write('amix=inputs=${inputFiles.length}:duration=longest:dropout_transition=2,volume=${1.0 / sqrt(inputFiles.length)}[a]');
    
    return '$inputs -filter_complex "${mixFilter.toString()}" -map "[a]" -c:a pcm_s16le "$outputPath"';
  }

  /// Advanced song mastering with multi-band processing
  Future<String?> masterSongAdvanced(String vocalPath, String beatPath) async {
    if (vocalPath.isEmpty || beatPath.isEmpty) return null;
    
    final tempDir = await _getTempDir();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    try {
      // Step 1: Align and sync vocal and beat
      final alignedPath = '${tempDir.path}/aligned_$timestamp.wav';
      final alignCommand = '''
      -i "$beatPath" -i "$vocalPath"
      -filter_complex "
        [0:a]volume=1.0[a0];
        [1:a]volume=0.8[a1];
        [a0][a1]amix=inputs=2:duration=longest:dropout_transition=2[a]
      " -map "[a]" -c:a pcm_s16le "$alignedPath"
      '''.replaceAll('\n', ' ');

      final alignSession = await FFmpegKit.execute(alignCommand);
      final alignReturnCode = await alignSession.getReturnCode();
      
      if (!ReturnCode.isSuccess(alignReturnCode)) {
        throw Exception('Failed to align vocal and beat');
      }

      // Step 2: Multi-band compression and EQ
      final processedPath = '${tempDir.path}/processed_$timestamp.wav';
      final processCommand = '''
      -i "$alignedPath"
      -filter_complex "
        [0:a]
        loudnorm=I=-16:TP=-1.5:LRA=11,
        equalizer=f=60:t=q:w=1:g=0.5,
        equalizer=f=250:t=q:w=1:g=-0.5,
        equalizer=f=2000:t=q:w=1:g=1.0,
        equalizer=f=8000:t=q:w=1:g=0.5,
        equalizer=f=12000:t=q:w=1:g=1.5,
        acompressor=threshold=-18:ratio=4:attack=10:release=100:knee=3,
        alimiter=level_in=1:level_out=1:limit=-0.1:attack=5:release=50[a]
      " -map "[a]" -c:a pcm_s16le "$processedPath"
      '''.replaceAll('\n', ' ');

      final processSession = await FFmpegKit.execute(processCommand);
      final processReturnCode = await processSession.getReturnCode();

      // Step 3: Stereo enhancement and final limiting
      final finalPath = '${tempDir.path}/mastered_$timestamp.wav';
      final finalCommand = '''
      -i "$processedPath"
      -filter_complex "
        [0:a]
        stereowiden=delay=20:feedback=0.3:crossfeed=0.3,
        loudnorm=I=-14:TP=-1.0:LRA=11,
        alimiter=level_in=1:level_out=1:limit=-0.05:attack=3:release=30[a]
      " -map "[a]" -c:a pcm_s16le "$finalPath"
      '''.replaceAll('\n', ' ');

      final finalSession = await FFmpegKit.execute(finalCommand);
      final finalReturnCode = await finalSession.getReturnCode();

      // Clean up intermediate file
      await _cleanTempFiles([alignedPath, processedPath]);

      if (ReturnCode.isSuccess(finalReturnCode)) {
        return finalPath;
      } else {
        throw Exception('Failed to master song');
      }
    } catch (e) {
      print('Error in song mastering: $e');
      return null;
    }
  }

  /// Noise reduction for audio files
  Future<String?> reduceNoise(String inputPath, {double noiseReduction = 0.5}) async {
    final tempDir = await _getTempDir();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/noise_reduced_$timestamp.wav';
    
    try {
      // First pass: analyze noise profile
      final noiseProfilePath = '${tempDir.path}/noise_profile_$timestamp.wav';
      final analyzeCommand = '-i "$inputPath" -t 1 -c:a pcm_s16le "$noiseProfilePath"';
      
      await FFmpegKit.execute(analyzeCommand);
      
      // Second pass: apply noise reduction
      final reduceCommand = '''
      -i "$inputPath" -i "$noiseProfilePath"
      -filter_complex "
        [1:a]arnndn=m=cb.rnnn[a1];
        [0:a][a1]arnndn=m=cb.rnnn:nr=$noiseReduction[a]
      " -map "[a]" -c:a pcm_s16le "$outputPath"
      '''.replaceAll('\n', ' ');
      
      final session = await FFmpegKit.execute(reduceCommand);
      final returnCode = await session.getReturnCode();
      
      await _cleanTempFiles([noiseProfilePath]);
      
      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        throw Exception('Failed to reduce noise');
      }
    } catch (e) {
      print('Error in noise reduction: $e');
      return null;
    }
  }

  /// Convert audio format with quality settings
  Future<String?> convertAudioFormat(
    String inputPath, 
    String outputFormat, 
    {int bitrate = 320, int sampleRate = 44100}
  ) async {
    final tempDir = await _getTempDir();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/converted_$timestamp.$outputFormat';
    
    try {
      final command = '''
      -i "$inputPath"
      -c:a ${outputFormat == 'mp3' ? 'libmp3lame' : outputFormat == 'aac' ? 'aac' : 'pcm_s16le'}
      -b:a ${bitrate}k
      -ar $sampleRate
      -ac 2
      "$outputPath"
      '''.replaceAll('\n', ' ');
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        throw Exception('Failed to convert audio format');
      }
    } catch (e) {
      print('Error in format conversion: $e');
      return null;
    }
  }

  Future<String?> pitchCorrection(String inputPath) async {
    final tempDir = await _getTempDir();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/pitch_corrected_$timestamp.wav';

    try {
      // Basic pitch correction using rubberband filter
      final command = '-i "$inputPath" -af "rubberband=pitch=1.0" "$outputPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        print('Failed to apply pitch correction');
        return null;
      }
    } catch (e) {
      print('Error in pitch correction: $e');
      return null;
    }
  }
}
