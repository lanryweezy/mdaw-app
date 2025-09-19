import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';

class EffectSettings extends StatefulWidget {
  final AudioEffect effect;

  const EffectSettings({super.key, required this.effect});

  @override
  State<EffectSettings> createState() => _EffectSettingsState();
}

class _EffectSettingsState extends State<EffectSettings> {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildParameterControls(),
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
                      final viewModel = Provider.of<DawViewModel>(context, listen: false);
                      viewModel.updateEffectParameters(widget.effect.name, _parameters);
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
                      final viewModel = Provider.of<DawViewModel>(context, listen: false);
                      viewModel.updateEffectParameters(widget.effect.name, _parameters);
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
