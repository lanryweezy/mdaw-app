import 'package:flutter/material.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:provider/provider.dart';
import 'package:studio_wiz/widgets/effect_settings.dart';
import 'package:studio_wiz/widgets/automation_curve_painter.dart';
import 'package:studio_wiz/models/automation_system.dart';

class AdvancedControlsPanel extends StatelessWidget {
  const AdvancedControlsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Controls',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildEffectSlot(context, 'eq', Icons.tune, false),
        _buildEffectSlot(context, 'compressor', Icons.compress, false),
        _buildEffectSlot(context, 'reverb', Icons.spatial_audio_off, false),
        _buildEffectSlot(context, 'delay', Icons.replay, false),
        _buildEffectSlot(context, 'chorus', Icons.group, false),
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
                child: Column(
                  children: [
                    EffectSettings(effect: effect!),
                    _buildAutomationCurve(context, name),
                  ],
                ),
              )
            ]
          : [],
    );
  }

  Widget _buildAutomationCurve(BuildContext context, String targetId) {
    return Consumer<DawViewModel>(
      builder: (context, viewModel, child) {
        final lanes = viewModel.automationSystem.getLanesForTarget(targetId);
        if (lanes.isEmpty) return const SizedBox.shrink();

        // Just show the first lane for this target (e.g. effect mix parameter)
        final lane = lanes.first;
        final totalDuration = viewModel.beatTrack.clips.isNotEmpty
            ? viewModel.beatTrack.clips.first.duration
            : const Duration(minutes: 3); // Fallback duration

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Automation: ${lane.name}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black26,
                border: Border.all(color: Colors.grey[800]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: CustomPaint(
                painter: AutomationCurvePainter(lane: lane, totalDuration: totalDuration),
              ),
            ),
          ],
        );
      }
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
