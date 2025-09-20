import 'package:flutter/material.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:provider/provider.dart';
import 'package:studio_wiz/widgets/effect_settings.dart';

class AdvancedControlsPanel extends StatelessWidget {
  final Track track;
  const AdvancedControlsPanel({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DawViewModel>(context);
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildEffectsSection(context, viewModel),
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
                    child: Material(
                      child: EffectSettings(
                        effect: viewModel.currentEffectSettings!,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEffectsSection(BuildContext context, DawViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Effects for ${track.name}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildEffectSlot(context, 'EQ', Icons.equalizer, true),
        const SizedBox(height: 8),
        _buildEffectSlot(context, 'Compressor', Icons.compress, false),
        const SizedBox(height: 8),
        _buildEffectSlot(context, 'Reverb', Icons.surround_sound, false),
        const SizedBox(height: 8),
        _buildEffectSlot(context, 'Delay', Icons.schedule, false),
        const SizedBox(height: 8),
        _buildEffectSlot(context, 'Chorus', Icons.waves, false),
      ],
    );
  }

  Widget _buildEffectSlot(BuildContext context, String name, IconData icon, bool isActive) {
    final viewModel = Provider.of<DawViewModel>(context, listen: false);
    final effect = viewModel.getEffect(name);
    final bool isEffectActive = effect?.isEnabled ?? false;

    return ExpansionTile(
      title: Text(name),
      leading: Icon(
        icon,
        color: isEffectActive ? Theme.of(context).colorScheme.primary : Colors.grey[400],
      ),
      trailing: Switch(
        value: isEffectActive,
        onChanged: (value) {
          viewModel.toggleEffect(name, value);
        },
      ),
      children: isEffectActive
          ? [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: EffectSettings(effect: effect!),
              )
            ]
          : [],
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
