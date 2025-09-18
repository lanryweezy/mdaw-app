import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:studio_wiz/models/audio_clip.dart';

class CollapsibleTrackWidget extends StatefulWidget {
  final String title;
  final Track track;
  final Color color;
  final VoidCallback onImport;
  final VoidCallback? onRecord; // Optional for beat track
  final VoidCallback onMute;
  final VoidCallback onSolo;
  final ValueChanged<double> onVolumeChanged;

  const CollapsibleTrackWidget({
    super.key,
    required this.title,
    required this.track,
    required this.color,
    required this.onImport,
    this.onRecord,
    required this.onMute,
    required this.onSolo,
    required this.onVolumeChanged,
  });

  @override
  State<CollapsibleTrackWidget> createState() => _CollapsibleTrackWidgetState();
}

class _CollapsibleTrackWidgetState extends State<CollapsibleTrackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Set initial state based on track collapsed property
    if (widget.track.collapsed) {
      _animationController.value = 0.0;
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCollapse() {
    final dawViewModel = Provider.of<DawViewModel>(context, listen: false);
    dawViewModel.setCollapsed(widget.track, !widget.track.collapsed);
    setState(() {
      if (widget.track.collapsed) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

    @override
  Widget build(BuildContext context) {
    // Update animation controller based on current track state
    if (widget.track.collapsed && _animationController.value > 0.0) {
      _animationController.reverse();
    } else if (!widget.track.collapsed && _animationController.value < 1.0) {
      _animationController.forward();
    }
    
    final theme = Theme.of(context);
    
    return Card(
      elevation: widget.track.collapsed ? 2 : 4,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      color: widget.track.collapsed ? Colors.grey[800] : Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: widget.track.soloed ? widget.color.withAlpha(178) : Colors.grey[700]!,
          width: widget.track.soloed ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrackHeader(context),
          SizeTransition(
            sizeFactor: _animation,
            child: _buildTrackContent(context),
          ),
          _buildTrackControls(context),
        ],
      ),
    );
  }

  Widget _buildTrackHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.color.withAlpha(25),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(
            _getTrackIcon(),
            color: widget.color,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildTrackStatusChip(),
          // Add a visual indicator for collapsed state
          if (widget.track.collapsed)
            const Icon(
              Icons.expand,
              color: Colors.grey,
              size: 16,
            ),
          IconButton(
            icon: AnimatedRotation(
              turns: widget.track.collapsed ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.track.collapsed ? Icons.expand_more : Icons.expand_less,
                color: widget.track.collapsed ? Colors.grey[400] : Colors.white,
              ),
            ),
            onPressed: _toggleCollapse,
            tooltip: widget.track.collapsed ? 'Expand track' : 'Collapse track',
          ),
        ],
      ),
    );
  }

  Widget _buildTrackStatusChip() {
    if (widget.track.clips.isEmpty) {
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
        color: widget.color.withAlpha(76),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${widget.track.clips.length} clip${widget.track.clips.length > 1 ? 's' : ''}',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildTrackContent(BuildContext context) {
    if (widget.track.clips.isEmpty) {
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
        children: widget.track.clips.map((clip) => _buildClipWidget(clip)).toList(),
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
              color: widget.color,
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

  Widget _buildTrackControls(BuildContext context) {
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
            icon: widget.track.muted ? Icons.volume_off : Icons.volume_up,
            label: 'Mute',
            isActive: widget.track.muted,
            onPressed: widget.onMute,
          ),
          _buildControlButton(
            icon: widget.track.soloed ? Icons.star : Icons.star_border,
            label: 'Solo',
            isActive: widget.track.soloed,
            onPressed: widget.onSolo,
          ),
          _buildVolumeSlider(context),
          _buildAddAudioButton(context),
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
            color: isActive ? widget.color : Colors.grey[400],
            size: 24,
          ),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            color: isActive ? widget.color : Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeSlider(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Slider(
            value: widget.track.clips.isNotEmpty ? widget.track.clips.first.volume : 1.0,
            min: 0.0,
            max: 1.0,
            activeColor: widget.color,
            inactiveColor: Colors.grey[600],
            onChanged: widget.onVolumeChanged,
          ),
          Text(
            '${((widget.track.clips.isNotEmpty ? widget.track.clips.first.volume : 1.0) * 100).toInt()}%',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAudioButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Add Audio'),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.color.withAlpha(178),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 36),
      ),
      onPressed: widget.onImport,
    );
  }

  IconData _getTrackIcon() {
    switch (widget.track.type) {
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
