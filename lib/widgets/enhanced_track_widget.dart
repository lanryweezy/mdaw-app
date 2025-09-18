import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:studio_wiz/models/audio_clip.dart';

class EnhancedTrackWidget extends StatelessWidget {
  final String title;
  final Track track;
  final Color color;

  const EnhancedTrackWidget({
    super.key,
    required this.title,
    required this.track,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DawViewModel>(
      builder: (context, viewModel, child) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.grey[850],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: track.soloed ? color.withAlpha(178) : Colors.grey[700]!,
              width: track.soloed ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrackHeader(context, viewModel),
              _buildTrackContent(context, viewModel),
              _buildTrackControls(context, viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrackHeader(BuildContext context, DawViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(
            _getTrackIcon(),
            color: color,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildTrackStatusChip(),
        ],
      ),
    );
  }

  Widget _buildTrackStatusChip() {
    if (track.clips.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Empty',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(76),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${track.clips.length} clip${track.clips.length > 1 ? 's' : ''}',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildTrackContent(BuildContext context, DawViewModel viewModel) {
    if (track.clips.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.audio_file,
                size: 48,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                'No audio loaded',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: track.clips.map((clip) => _buildClipWidget(clip)).toList(),
      ),
    );
  }

  Widget _buildClipWidget(AudioClip clip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clip.path.split('/').last,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatDuration(clip.endTime),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          _buildClipActions(clip),
        ],
      ),
    );
  }

  Widget _buildClipActions(AudioClip clip) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
          onPressed: () => clip.controller.startPlayer(), // Use startPlayer instead of resume
          tooltip: 'Play',
        ),
        IconButton(
          icon: const Icon(Icons.pause, color: Colors.white, size: 20),
          onPressed: () => clip.controller.pausePlayer(), // Use pausePlayer instead of pause
          tooltip: 'Pause',
        ),
        IconButton(
          icon: const Icon(Icons.stop, color: Colors.white, size: 20),
          onPressed: () => clip.controller.stopPlayer(), // Use stopPlayer instead of stop
          tooltip: 'Stop',
        ),
      ],
    );
  }

  Widget _buildTrackControls(BuildContext context, DawViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildControlButton(
            icon: track.muted ? Icons.volume_off : Icons.volume_up,
            label: 'Mute',
            isActive: track.muted,
            onPressed: () => viewModel.toggleMute(track), // Pass track object instead of track.id
          ),
          _buildControlButton(
            icon: track.soloed ? Icons.star : Icons.star_border,
            label: 'Solo',
            isActive: track.soloed,
            onPressed: () => viewModel.toggleSolo(track), // Pass track object instead of track.id
          ),
          _buildVolumeSlider(context, viewModel),
          _buildAddAudioButton(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: isActive ? color : Colors.grey[400],
            size: 24,
          ),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            color: isActive ? color : Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeSlider(BuildContext context, DawViewModel viewModel) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Slider(
            value: track.volume,
            min: 0.0,
            max: 1.0,
            activeColor: color,
            inactiveColor: Colors.grey[600],
            onChanged: (value) {
              // Update track volume
            },
          ),
          Text(
            '${(track.volume * 100).toInt()}%',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAudioButton(BuildContext context, DawViewModel viewModel) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Add Audio'),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(178),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 36),
      ),
      onPressed: () => _showAddAudioDialog(context, viewModel),
    );
  }

  void _showAddAudioDialog(BuildContext context, DawViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Audio'),
        content: const Text('Select audio file to import'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement file picker
            },
            child: const Text('Browse'),
          ),
        ],
      ),
    );
  }

  IconData _getTrackIcon() {
    switch (track.type) {
      case TrackType.beat:
        return Icons.music_note;
      case TrackType.vocal:
        return Icons.mic;
      case TrackType.mixed:
        return Icons.layers;
      case TrackType.mastered:
        return Icons.star;
      default:
        return Icons.audiotrack;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}
