import 'package:flutter/material.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:provider/provider.dart';
import 'package:studio_wiz/widgets/effect_settings.dart';


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
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
