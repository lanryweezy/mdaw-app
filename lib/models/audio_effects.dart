import 'dart:math';

/// Types of audio effects
enum EffectType {
  reverb,
  delay,
  chorus,
  flanger,
  phaser,
  compressor,
  eq,
  distortion,
  limiter,
  gate,
  expander,
  deEsser,
  stereoWidener,
  pitchShifter,
  vocoder,
  autoTune,
}

/// Base class for all audio effects
abstract class AudioEffect {
  final String id;
  final String name;
  final EffectType type;
  bool isEnabled;
  final Map<String, EffectParameter> parameters;

  AudioEffect({
    required this.id,
    required this.name,
    required this.type,
    this.isEnabled = false,
    Map<String, EffectParameter>? parameters,
  }) : parameters = parameters ?? {};

  /// Apply the effect to audio data
  List<double> apply(List<double> input) {
    if (!isEnabled) return input;
    return process(input);
  }

  /// Process audio data with the effect
  List<double> process(List<double> input);

  /// Get a copy of the effect with new values
  AudioEffect copyWith({
    String? id,
    String? name,
    EffectType? type,
    bool? isEnabled,
    Map<String, EffectParameter>? parameters,
  });
}

/// Base class for effect parameters
class EffectParameter {
  final String id;
  final String name;
  final String description;
  double value;
  final double minValue;
  final double maxValue;
  final double defaultValue;
  final String unit;

  EffectParameter({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.defaultValue,
    required this.unit,
  });

  /// Reset to default value
  void reset() {
    value = defaultValue;
  }

  /// Set value with clamping
  void setValue(double newValue) {
    value = newValue.clamp(minValue, maxValue);
  }

  /// Get value as a percentage (0-100)
  double get percentage => ((value - minValue) / (maxValue - minValue)) * 100;

  /// Create a copy with new values
  EffectParameter copyWith({
    String? id,
    String? name,
    String? description,
    double? value,
    double? minValue,
    double? maxValue,
    double? defaultValue,
    String? unit,
  }) {
    return EffectParameter(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      value: value ?? this.value,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      defaultValue: defaultValue ?? this.defaultValue,
      unit: unit ?? this.unit,
    );
  }
}

/// Reverb effect
class ReverbEffect extends AudioEffect {
  ReverbEffect({
    required String id,
    String name = 'Reverb',
    bool isEnabled = false,
  }) : super(
          id: id,
          name: name,
          type: EffectType.reverb,
          isEnabled: isEnabled,
          parameters: {
            'room_size': EffectParameter(
              id: 'room_size',
              name: 'Room Size',
              description: 'Size of the simulated room',
              value: 0.5,
              minValue: 0.0,
              maxValue: 1.0,
              defaultValue: 0.5,
              unit: '',
            ),
            'damping': EffectParameter(
              id: 'damping',
              name: 'Damping',
              description: 'High frequency damping',
              value: 0.5,
              minValue: 0.0,
              maxValue: 1.0,
              defaultValue: 0.5,
              unit: '',
            ),
            'wet_level': EffectParameter(
              id: 'wet_level',
              name: 'Wet Level',
              description: 'Amount of reverb signal',
              value: 0.33,
              minValue: 0.0,
              maxValue: 1.0,
              defaultValue: 0.33,
              unit: '',
            ),
            'dry_level': EffectParameter(
              id: 'dry_level',
              name: 'Dry Level',
              description: 'Amount of original signal',
              value: 0.4,
              minValue: 0.0,
              maxValue: 1.0,
              defaultValue: 0.4,
              unit: '',
            ),
            'width': EffectParameter(
              id: 'width',
              name: 'Width',
              description: 'Stereo width of reverb',
              value: 1.0,
              minValue: 0.0,
              maxValue: 1.0,
              defaultValue: 1.0,
              unit: '',
            ),
          },
        );

  @override
  List<double> process(List<double> input) {
    // Simplified reverb implementation
    // In a real implementation, this would use convolution or algorithmic reverb
    final wetLevel = parameters['wet_level']!.value;
    final dryLevel = parameters['dry_level']!.value;
    
    // Create a simple echo effect as a basic reverb simulation
    final output = List<double>.filled(input.length, 0.0);
    
    for (int i = 0; i < input.length; i++) {
      double reverbSample = 0.0;
      
      // Add delayed samples with decreasing amplitude
      for (int delay = 1000; delay <= 5000; delay += 1000) {
        if (i >= delay) {
          reverbSample += input[i - delay] * (0.5 / (delay / 1000));
        }
      }
      
      output[i] = input[i] * dryLevel + reverbSample * wetLevel;
    }
    
    return output;
  }

  @override
  AudioEffect copyWith({
    String? id,
    String? name,
    EffectType? type,
    bool? isEnabled,
    Map<String, EffectParameter>? parameters,
  }) {
    return ReverbEffect(
      id: id ?? this.id,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// Compressor effect
class CompressorEffect extends AudioEffect {
  CompressorEffect({
    required String id,
    String name = 'Compressor',
    bool isEnabled = false,
  }) : super(
          id: id,
          name: name,
          type: EffectType.compressor,
          isEnabled: isEnabled,
          parameters: {
            'threshold': EffectParameter(
              id: 'threshold',
              name: 'Threshold',
              description: 'Level at which compression begins (dB)',
              value: -20.0,
              minValue: -60.0,
              maxValue: 0.0,
              defaultValue: -20.0,
              unit: 'dB',
            ),
            'ratio': EffectParameter(
              id: 'ratio',
              name: 'Ratio',
              description: 'Compression ratio',
              value: 4.0,
              minValue: 1.0,
              maxValue: 20.0,
              defaultValue: 4.0,
              unit: ':1',
            ),
            'attack': EffectParameter(
              id: 'attack',
              name: 'Attack',
              description: 'Attack time (ms)',
              value: 10.0,
              minValue: 0.1,
              maxValue: 500.0,
              defaultValue: 10.0,
              unit: 'ms',
            ),
            'release': EffectParameter(
              id: 'release',
              name: 'Release',
              description: 'Release time (ms)',
              value: 100.0,
              minValue: 10.0,
              maxValue: 5000.0,
              defaultValue: 100.0,
              unit: 'ms',
            ),
            'knee': EffectParameter(
              id: 'knee',
              name: 'Knee',
              description: 'Soft knee width (dB)',
              value: 3.0,
              minValue: 0.0,
              maxValue: 10.0,
              defaultValue: 3.0,
              unit: 'dB',
            ),
            'makeup_gain': EffectParameter(
              id: 'makeup_gain',
              name: 'Makeup Gain',
              description: 'Gain applied after compression (dB)',
              value: 0.0,
              minValue: -10.0,
              maxValue: 20.0,
              defaultValue: 0.0,
              unit: 'dB',
            ),
          },
        );

  @override
  List<double> process(List<double> input) {
    // Simplified compressor implementation
    final threshold = parameters['threshold']!.value;
    final ratio = parameters['ratio']!.value;
    final makeupGain = parameters['makeup_gain']!.value;
    
    final output = List<double>.filled(input.length, 0.0);
    
    for (int i = 0; i < input.length; i++) {
      final sample = input[i];
      final absSample = sample.abs();
      
      // Convert threshold from dB to linear
      final thresholdLinear = pow(10, threshold / 20).toDouble();
      
      if (absSample > thresholdLinear) {
        // Apply compression
        final compressedSample = thresholdLinear + (absSample - thresholdLinear) / ratio;
        final gain = compressedSample / absSample;
        output[i] = sample * gain;
      } else {
        // No compression needed
        output[i] = sample;
      }
      
      // Apply makeup gain
      if (makeupGain != 0) {
        final makeupGainLinear = pow(10, makeupGain / 20).toDouble();
        output[i] *= makeupGainLinear;
      }
    }
    
    return output;
  }

  @override
  AudioEffect copyWith({
    String? id,
    String? name,
    EffectType? type,
    bool? isEnabled,
    Map<String, EffectParameter>? parameters,
  }) {
    return CompressorEffect(
      id: id ?? this.id,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// Equalizer effect
class EqEffect extends AudioEffect {
  EqEffect({
    required String id,
    String name = 'Equalizer',
    bool isEnabled = false,
  }) : super(
          id: id,
          name: name,
          type: EffectType.eq,
          isEnabled: isEnabled,
          parameters: {
            'low_gain': EffectParameter(
              id: 'low_gain',
              name: 'Low Gain',
              description: 'Gain for low frequencies (dB)',
              value: 0.0,
              minValue: -15.0,
              maxValue: 15.0,
              defaultValue: 0.0,
              unit: 'dB',
            ),
            'mid_gain': EffectParameter(
              id: 'mid_gain',
              name: 'Mid Gain',
              description: 'Gain for mid frequencies (dB)',
              value: 0.0,
              minValue: -15.0,
              maxValue: 15.0,
              defaultValue: 0.0,
              unit: 'dB',
            ),
            'high_gain': EffectParameter(
              id: 'high_gain',
              name: 'High Gain',
              description: 'Gain for high frequencies (dB)',
              value: 0.0,
              minValue: -15.0,
              maxValue: 15.0,
              defaultValue: 0.0,
              unit: 'dB',
            ),
            'low_freq': EffectParameter(
              id: 'low_freq',
              name: 'Low Frequency',
              description: 'Crossover frequency for low band (Hz)',
              value: 200.0,
              minValue: 50.0,
              maxValue: 500.0,
              defaultValue: 200.0,
              unit: 'Hz',
            ),
            'high_freq': EffectParameter(
              id: 'high_freq',
              name: 'High Frequency',
              description: 'Crossover frequency for high band (Hz)',
              value: 2000.0,
              minValue: 1000.0,
              maxValue: 8000.0,
              defaultValue: 2000.0,
              unit: 'Hz',
            ),
          },
        );

  @override
  List<double> process(List<double> input) {
    // Simplified EQ implementation
    final lowGain = parameters['low_gain']!.value;
    final midGain = parameters['mid_gain']!.value;
    final highGain = parameters['high_gain']!.value;
    
    // Convert gains from dB to linear
    final lowGainLinear = pow(10, lowGain / 20).toDouble();
    final midGainLinear = pow(10, midGain / 20).toDouble();
    final highGainLinear = pow(10, highGain / 20).toDouble();
    
    // In a real implementation, this would use proper filter algorithms
    // For now, we'll apply a simplified frequency-dependent gain
    final output = List<double>.filled(input.length, 0.0);
    
    for (int i = 0; i < input.length; i++) {
      // Simple frequency estimation based on sample position
      // This is a very simplified approach - real EQ uses FFT or filter banks
      final frequencyEstimate = (i % 1000) * 44.1; // Rough estimate
      
      double gain;
      if (frequencyEstimate < parameters['low_freq']!.value) {
        gain = lowGainLinear;
      } else if (frequencyEstimate > parameters['high_freq']!.value) {
        gain = highGainLinear;
      } else {
        gain = midGainLinear;
      }
      
      output[i] = input[i] * gain;
    }
    
    return output;
  }

  @override
  AudioEffect copyWith({
    String? id,
    String? name,
    EffectType? type,
    bool? isEnabled,
    Map<String, EffectParameter>? parameters,
  }) {
    return EqEffect(
      id: id ?? this.id,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// Delay effect
class DelayEffect extends AudioEffect {
  DelayEffect({
    required String id,
    String name = 'Delay',
    bool isEnabled = false,
  }) : super(
          id: id,
          name: name,
          type: EffectType.delay,
          isEnabled: isEnabled,
          parameters: {
            'delay_time': EffectParameter(
              id: 'delay_time',
              name: 'Delay Time',
              description: 'Delay time (ms)',
              value: 300.0,
              minValue: 1.0,
              maxValue: 5000.0,
              defaultValue: 300.0,
              unit: 'ms',
            ),
            'feedback': EffectParameter(
              id: 'feedback',
              name: 'Feedback',
              description: 'Amount of signal fed back',
              value: 0.3,
              minValue: 0.0,
              maxValue: 1.0,
              defaultValue: 0.3,
              unit: '',
            ),
            'mix': EffectParameter(
              id: 'mix',
              name: 'Mix',
              description: 'Dry/wet mix',
              value: 0.5,
              minValue: 0.0,
              maxValue: 1.0,
              defaultValue: 0.5,
              unit: '',
            ),
          },
        );

  @override
  List<double> process(List<double> input) {
    final delayTime = parameters['delay_time']!.value;
    final feedback = parameters['feedback']!.value;
    final mix = parameters['mix']!.value;
    
    // Calculate delay in samples (assuming 44.1kHz sample rate)
    final delaySamples = (delayTime * 44.1).round();
    
    final output = List<double>.filled(input.length, 0.0);
    final delayBuffer = List<double>.filled(delaySamples, 0.0);
    int bufferIndex = 0;
    
    for (int i = 0; i < input.length; i++) {
      // Get delayed sample
      final delayedSample = delayBuffer[bufferIndex];
      
      // Calculate output (dry + wet)
      output[i] = input[i] * (1 - mix) + delayedSample * mix;
      
      // Update delay buffer
      delayBuffer[bufferIndex] = input[i] + delayedSample * feedback;
      
      // Move buffer index
      bufferIndex = (bufferIndex + 1) % delaySamples;
    }
    
    return output;
  }

  @override
  AudioEffect copyWith({
    String? id,
    String? name,
    EffectType? type,
    bool? isEnabled,
    Map<String, EffectParameter>? parameters,
  }) {
    return DelayEffect(
      id: id ?? this.id,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// Effect presets for different musical styles
class EffectPreset {
  final String id;
  final String name;
  final String description;
  final Map<String, Map<String, double>> effectParameters;

  EffectPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.effectParameters,
  });

  /// Apply preset to effect parameters
  void applyToEffect(AudioEffect effect) {
    final effectParams = effectParameters[effect.id];
    if (effectParams != null) {
      effectParams.forEach((paramId, value) {
        if (effect.parameters.containsKey(paramId)) {
          effect.parameters[paramId]!.setValue(value);
        }
      });
    }
  }
}

/// Collection of professional effect presets
class EffectPresetCollection {
  static List<EffectPreset> get vocalPresets => [
        EffectPreset(
          id: 'vocal_pop',
          name: 'Pop Vocals',
          description: 'Bright and present vocal sound',
          effectParameters: {
            'eq': {
              'low_gain': 0.0,
              'mid_gain': 2.0,
              'high_gain': 3.0,
            },
            'compressor': {
              'threshold': -25.0,
              'ratio': 3.0,
              'attack': 5.0,
              'release': 100.0,
            },
            'reverb': {
              'room_size': 0.4,
              'wet_level': 0.25,
            }
          },
        ),
        EffectPreset(
          id: 'vocal_rnb',
          name: 'R&B Vocals',
          description: 'Warm and smooth vocal sound',
          effectParameters: {
            'eq': {
              'low_gain': 1.0,
              'mid_gain': 0.0,
              'high_gain': 2.0,
            },
            'compressor': {
              'threshold': -20.0,
              'ratio': 2.5,
              'attack': 15.0,
              'release': 200.0,
            },
            'reverb': {
              'room_size': 0.6,
              'wet_level': 0.3,
            }
          },
        ),
        EffectPreset(
          id: 'vocal_aggressive',
          name: 'Aggressive Vocals',
          description: 'Hard and in-your-face vocal sound',
          effectParameters: {
            'eq': {
              'low_gain': 2.0,
              'mid_gain': 1.0,
              'high_gain': 4.0,
            },
            'compressor': {
              'threshold': -15.0,
              'ratio': 5.0,
              'attack': 2.0,
              'release': 50.0,
            },
            'reverb': {
              'room_size': 0.3,
              'wet_level': 0.2,
            }
          },
        ),
      ];

  static List<EffectPreset> get mixPresets => [
        EffectPreset(
          id: 'mix_loud_and_clear',
          name: 'Loud & Clear',
          description: 'Commercial loudness with clarity',
          effectParameters: {
            'eq': {
              'low_gain': 1.0,
              'mid_gain': 0.0,
              'high_gain': 1.0,
            },
            'compressor': {
              'threshold': -15.0,
              'ratio': 4.0,
              'attack': 5.0,
              'release': 100.0,
            },
            'limiter': {
              'threshold': -1.0,
              'release': 50.0,
            }
          },
        ),
        EffectPreset(
          id: 'mix_warm_and_analog',
          name: 'Warm & Analog',
          description: 'Vintage analog console sound',
          effectParameters: {
            'eq': {
              'low_gain': 2.0,
              'mid_gain': -1.0,
              'high_gain': -1.0,
            },
            'compressor': {
              'threshold': -20.0,
              'ratio': 3.0,
              'attack': 20.0,
              'release': 200.0,
            },
          },
        ),
      ];
}
