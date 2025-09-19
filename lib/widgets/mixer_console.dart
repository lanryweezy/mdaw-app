import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';

class MixerConsole extends StatelessWidget {
  const MixerConsole({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DawViewModel>(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTrackChannel(context, viewModel, viewModel.beatTrack, 'Beat', Colors.blue),
          ...viewModel.vocalTracks.asMap().entries.map((entry) {
            final index = entry.key;
            final track = entry.value;
            return _buildTrackChannel(context, viewModel, track, 'Vocal ${index + 1}', _getTrackColor(index));
          }),
          if (viewModel.mixedVocalTrack != null)
            _buildTrackChannel(context, viewModel, viewModel.mixedVocalTrack!, 'Mixed', Colors.purple),
          if (viewModel.masteredSongTrack != null)
            _buildTrackChannel(context, viewModel, viewModel.masteredSongTrack!, 'Master', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildTrackChannel(BuildContext context, DawViewModel viewModel, Track track, String name, Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(track.muted ? Icons.volume_off : Icons.volume_up),
                onPressed: () => viewModel.toggleMute(track),
                color: track.muted ? Colors.red : null,
              ),
              IconButton(
                icon: Icon(track.soloed ? Icons.star : Icons.star_border),
                onPressed: () => viewModel.toggleSolo(track),
                color: track.soloed ? Colors.yellow : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Pan: ${track.pan.toStringAsFixed(2)}'),
          Slider(
            value: track.pan,
            onChanged: (value) => viewModel.setPan(track, value),
            min: -1,
            max: 1,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: track.clips.isNotEmpty ? track.clips.first.volume : 1.0,
                onChanged: (value) => viewModel.setVolume(track, null, value),
              ),
            ),
          ),
          Text(
            '${((track.clips.isNotEmpty ? track.clips.first.volume : 1.0) * 100).round()}%',
          ),
        ],
      ),
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
