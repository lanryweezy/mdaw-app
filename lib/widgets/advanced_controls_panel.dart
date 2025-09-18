import 'package:flutter/material.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:provider/provider.dart';

// Simple effect settings dialog
class EffectSettingsDialog extends StatefulWidget {
  final AudioEffect effect;
  
  const EffectSettingsDialog({super.key, required this.effect});

  @override
  State<EffectSettingsDialog> createState() => _EffectSettingsDialogState();
}

class _EffectSettingsDialogState extends State<EffectSettingsDialog> {
  late Map<String, dynamic> _parameters;
  
  @override
  void initState() {
    super.initState();
    _parameters = Map<String, dynamic>.from(widget.effect.parameters);
    
    // Initialize default parameters if not set
    if (widget.effect.id == 'eq') {
      _parameters.putIfAbsent('gain', () => 0.0);
      _parameters.putIfAbsent('frequency', () => 1000.0);
      _parameters.putIfAbsent('q', () => 1.0);
    } else if (widget.effect.id == 'compressor') {
      _parameters.putIfAbsent('threshold', () => -20.0);
      _parameters.putIfAbsent('ratio', () => 4.0);
      _parameters.putIfAbsent('attack', () => 10.0);
      _parameters.putIfAbsent('release', () => 100.0);
    } else if (widget.effect.id == 'reverb') {
      _parameters.putIfAbsent('decay', () => 1.0);
      _parameters.putIfAbsent('mix', () => 0.5);
    } else if (widget.effect.id == 'delay') {
      _parameters.putIfAbsent('time', () => 300.0);
      _parameters.putIfAbsent('feedback', () => 0.3);
      _parameters.putIfAbsent('mix', () => 0.5);
    } else if (widget.effect.id == 'chorus') {
      _parameters.putIfAbsent('rate', () => 1.0);
      _parameters.putIfAbsent('depth', () => 0.5);
      _parameters.putIfAbsent('mix', () => 0.5);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.effect.name} Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildParameterControls(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Save parameters
            final viewModel = Provider.of<DawViewModel>(context, listen: false);
            viewModel.updateEffectParameters(widget.effect.name, _parameters);
            viewModel.closeEffectSettings();
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
  
  List<Widget> _buildParameterControls() {
    final List<Widget> controls = [];
    
    _parameters.forEach((key, value) {
      if (value is double) {
        controls.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatParameterName(key),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Slider(
                  value: value,
                  min: _getMinValue(key),
                  max: _getMaxValue(key),
                  divisions: 100,
                  label: value.toStringAsFixed(2),
                  onChanged: (newValue) {
                    setState(() {
                      _parameters[key] = newValue;
                    });
                  },
                ),
                Text(
                  '${value.toStringAsFixed(2)} ${_getParameterUnit(key)}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      } else if (value is int) {
        controls.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatParameterName(key),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Slider(
                  value: value.toDouble(),
                  min: _getMinValue(key).toDouble(),
                  max: _getMaxValue(key).toDouble(),
                  divisions: (_getMaxValue(key) - _getMinValue(key)).toInt(),
                  label: value.toString(),
                  onChanged: (newValue) {
                    setState(() {
                      _parameters[key] = newValue.toInt();
                    });
                  },
                ),
                Text(
                  '$value ${_getParameterUnit(key)}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }
    });
    
    if (controls.isEmpty) {
      controls.add(const Text('No adjustable parameters'));
    }
    
    return controls;
  }
  
  String _formatParameterName(String name) {
    // Capitalize first letter and add spaces
    final words = <String>[];
    final buffer = StringBuffer();
    
    for (int i = 0; i < name.length; i++) {
      final char = name[i];
      if (char == char.toUpperCase() && i > 0) {
        if (buffer.isNotEmpty) {
          words.add(buffer.toString());
          buffer.clear();
        }
      }
      buffer.write(char);
    }
    
    if (buffer.isNotEmpty) {
      words.add(buffer.toString());
    }
    
    return words.map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
  
  String _getParameterUnit(String name) {
    if (name == 'gain') return 'dB';
    if (name == 'frequency') return 'Hz';
    if (name == 'q') return '';
    if (name == 'threshold') return 'dB';
    if (name == 'ratio') return ':1';
    if (name == 'attack') return 'ms';
    if (name == 'release') return 'ms';
    if (name == 'decay') return 's';
    if (name == 'mix') return '';
    if (name == 'time') return 'ms';
    if (name == 'feedback') return '';
    if (name == 'rate') return 'Hz';
    if (name == 'depth') return '';
    return '';
  }
  
  double _getMinValue(String name) {
    if (name == 'gain') return -20.0;
    if (name == 'frequency') return 20.0;
    if (name == 'q') return 0.1;
    if (name == 'threshold') return -60.0;
    if (name == 'ratio') return 1.0;
    if (name == 'attack') return 0.1;
    if (name == 'release') return 1.0;
    if (name == 'decay') return 0.1;
    if (name == 'mix') return 0.0;
    if (name == 'time') return 10.0;
    if (name == 'feedback') return 0.0;
    if (name == 'rate') return 0.1;
    if (name == 'depth') return 0.0;
    return 0.0;
  }
  
  double _getMaxValue(String name) {
    if (name == 'gain') return 20.0;
    if (name == 'frequency') return 20000.0;
    if (name == 'q') return 10.0;
    if (name == 'threshold') return 0.0;
    if (name == 'ratio') return 20.0;
    if (name == 'attack') return 1000.0;
    if (name == 'release') return 5000.0;
    if (name == 'decay') return 10.0;
    if (name == 'mix') return 1.0;
    if (name == 'time') return 5000.0;
    if (name == 'feedback') return 1.0;
    if (name == 'rate') return 10.0;
    if (name == 'depth') return 1.0;
    return 100.0;
  }
}

class AdvancedControlsPanel extends StatefulWidget {
  const AdvancedControlsPanel({super.key});

  @override
  State<AdvancedControlsPanel> createState() => _AdvancedControlsPanelState();
}

class _AdvancedControlsPanelState extends State<AdvancedControlsPanel> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DawViewModel>(
      builder: (context, viewModel, child) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMixerSection(viewModel),
                  const SizedBox(height: 24),
                  _buildEffectsSection(viewModel),
                  const SizedBox(height: 24),
                  _buildAutomationSection(viewModel),
                ],
              ),
            ),
            // Effect settings dialog overlay
            if (viewModel.currentEffectSettings != null)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    // Close effect settings when tapping outside
                    viewModel.closeEffectSettings();
                  },
                  child: Container(
                    color: Colors.black.withAlpha(127),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          // Prevent tap from closing dialog when tapping inside
                        },
                        child: EffectSettingsDialog(
                          effect: viewModel.currentEffectSettings!,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMixerSection(DawViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mixer',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (viewModel.selectedTrack != null)
                  Text(
                    'Selected: ${viewModel.selectedTrack!.name}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Beat Track
            _buildTrackMixer(
              viewModel,
              'Beat',
              viewModel.beatTrack,
              Colors.blue,
              (volume) => viewModel.setVolume(viewModel.beatTrack, null, volume),
            ),
            const SizedBox(height: 16),
            // Vocal Tracks
            ...viewModel.vocalTracks.asMap().entries.map((entry) {
              final index = entry.key;
              final track = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildTrackMixer(
                  viewModel,
                  'Vocal ${index + 1}',
                  track,
                  _getTrackColor(index),
                  (volume) => viewModel.setVolume(track, null, volume),
                ),
              );
            }),
            // Mixed Vocals
            if (viewModel.mixedVocalTrack != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildTrackMixer(
                  viewModel,
                  'Mixed Vocals',
                  viewModel.mixedVocalTrack!,
                  Colors.purple,
                  (volume) => viewModel.setVolume(viewModel.mixedVocalTrack!, null, volume),
                ),
              ),
            // Mastered Song
            if (viewModel.masteredSongTrack != null)
              _buildTrackMixer(
                viewModel,
                'Mastered Song',
                viewModel.masteredSongTrack!,
                Colors.orange,
                (volume) => viewModel.setVolume(viewModel.masteredSongTrack!, null, volume),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackMixer(DawViewModel viewModel, String name, Track track, Color color, ValueChanged<double> onVolumeChanged) {
    final isSelected = viewModel.selectedTrack?.id == track.id;
    return GestureDetector(
      onTap: () => viewModel.selectTrack(track),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(76) : color.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withAlpha(76),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                // Mute button
                IconButton(
                  icon: Icon(
                    track.muted ? Icons.volume_off : Icons.volume_up,
                    color: track.muted ? Colors.red : color,
                  ),
                  onPressed: () => viewModel.toggleMute(track),
                ),
                // Solo button
                IconButton(
                  icon: Icon(
                    track.soloed ? Icons.hearing : Icons.hearing_disabled,
                    color: track.soloed ? Colors.yellow : color,
                  ),
                  onPressed: () => viewModel.toggleSolo(track),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Volume slider
            Row(
              children: [
                const Icon(Icons.volume_down, size: 20),
                Expanded(
                  child: Slider(
                    value: track.clips.isNotEmpty ? track.clips.first.volume : 1.0,
                    onChanged: onVolumeChanged,
                    min: 0.0,
                    max: 1.0,
                    activeColor: color,
                  ),
                ),
                const Icon(Icons.volume_up, size: 20),
                // Volume display
                Container(
                  width: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${((track.clips.isNotEmpty ? track.clips.first.volume : 1.0) * 100).round()}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            // Pan control
            Row(
              children: [
                const Icon(Icons.pan_tool, size: 20),
                const SizedBox(width: 8),
                const Text('Pan:', style: TextStyle(fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: track.pan,
                    onChanged: (value) {
                      viewModel.setPan(track, value);
                    },
                    min: -1.0,
                    max: 1.0,
                    activeColor: color,
                  ),
                ),
                const Text('L', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                const Text('R', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectsSection(DawViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Effects Rack',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEffectSlot('EQ', Icons.equalizer, true),
            const SizedBox(height: 8),
            _buildEffectSlot('Compressor', Icons.compress, false),
            const SizedBox(height: 8),
            _buildEffectSlot('Reverb', Icons.surround_sound, false),
            const SizedBox(height: 8),
            _buildEffectSlot('Delay', Icons.schedule, false),
            const SizedBox(height: 8),
            _buildEffectSlot('Chorus', Icons.waves, false),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectSlot(String name, IconData icon, bool isActive) {
    final viewModel = Provider.of<DawViewModel>(context, listen: false);
    final effect = viewModel.getEffect(name);
    final bool isEffectActive = effect?.isEnabled ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEffectActive ? Theme.of(context).colorScheme.primary.withAlpha(25) : Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEffectActive ? Theme.of(context).colorScheme.primary : Colors.grey[600]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isEffectActive ? Theme.of(context).colorScheme.primary : Colors.grey[400],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isEffectActive ? Colors.white : Colors.grey[400],
              ),
            ),
          ),
          Switch(
            value: isEffectActive,
            onChanged: (value) {
              // Implement effect toggle
              viewModel.toggleEffect(name, value);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 20),
            onPressed: isEffectActive ? () {
              // Open effect settings
              viewModel.openEffectSettings(name);
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationSection(DawViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Automation',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Implement automation recording
                      viewModel.startAutomationRecording();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Automation recording started!')),
                      );
                    },
                    icon: const Icon(Icons.fiber_manual_record),
                    label: const Text('Record Automation'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Implement automation playback
                      viewModel.playAutomation();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Playing automation!')),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play Automation'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Automation Parameters:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildAutomationParameter('Volume', viewModel.automatedParameters.contains('Volume')),
                _buildAutomationParameter('Pan', viewModel.automatedParameters.contains('Pan')),
                _buildAutomationParameter('EQ', viewModel.automatedParameters.contains('EQ')),
                _buildAutomationParameter('Compressor', viewModel.automatedParameters.contains('Compressor')),
                _buildAutomationParameter('Reverb', viewModel.automatedParameters.contains('Reverb')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutomationParameter(String name, bool isEnabled) {
    return FilterChip(
      label: Text(name),
      selected: isEnabled,
      onSelected: (selected) {
        // Implement automation parameter selection
        final viewModel = Provider.of<DawViewModel>(context, listen: false);
        viewModel.selectAutomationParameter(name, selected);
      },
    );
  }

  Color _getTrackColor(int index) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}
