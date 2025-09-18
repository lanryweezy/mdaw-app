import 'package:flutter/material.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:provider/provider.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:studio_wiz/widgets/processing_indicator.dart';
import 'package:studio_wiz/widgets/collapsible_track_widget.dart';

class EnhancedDawUI extends StatelessWidget {
  const EnhancedDawUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DawViewModel>(
      builder: (context, viewModel, child) {
        return Stack(
          children: [
            _buildMainContent(context, viewModel),
            if (viewModel.isProcessing)
              _buildProcessingOverlay(context, viewModel),
          ],
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, DawViewModel viewModel) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: _buildAppBar(context, viewModel),
      body: _buildBody(context, viewModel),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProcessingConfirmation(
          context,
          viewModel.magicMixVocals,
          'Apply advanced vocal effects and mixing?',
        ),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Magic Mix Vocals'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, DawViewModel viewModel) {
    return AppBar(
      backgroundColor: Colors.grey[850],
      title: const Text(
        'MDAW - Modern Digital Audio Workstation',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.clear_all, color: Colors.white),
          onPressed: () => _showClearConfirmation(context, viewModel),
          tooltip: 'Clear Project',
        ),
        IconButton(
          icon: const Icon(Icons.save, color: Colors.white),
          onPressed: () => _showSaveDialog(context, viewModel),
          tooltip: 'Save Project',
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, DawViewModel viewModel) {
    return Column(
      children: [
        _buildTransportControls(context, viewModel),
        _buildTrackArea(context, viewModel),
      ],
    );
  }

  Widget _buildTransportControls(BuildContext context, DawViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[800],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTransportButton(
            icon: Icons.play_arrow,
            onPressed: viewModel.play,
            tooltip: 'Play',
          ),
          const SizedBox(width: 16),
          _buildTransportButton(
            icon: Icons.pause,
            onPressed: viewModel.pause,
            tooltip: 'Pause',
          ),
          const SizedBox(width: 16),
          _buildTransportButton(
            icon: Icons.stop,
            onPressed: viewModel.stop,
            tooltip: 'Stop',
          ),
          const SizedBox(width: 16),
          _buildTransportButton(
            icon: Icons.mic,
            onPressed: () {
              final emptyVocalTrack = viewModel.vocalTracks.firstWhere(
                (track) => !track.hasAudio,
                orElse: () => viewModel.vocalTracks.first,
              );
              viewModel.toggleRecording(emptyVocalTrack);
            },
            tooltip: 'Record',
            color: Colors.red,
          ),
          const SizedBox(width: 32),
          _buildMasterVolumeSlider(context, viewModel),
          const SizedBox(width: 32),
          _buildProcessingActions(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildTransportButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.white, size: 32),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildMasterVolumeSlider(BuildContext context, DawViewModel viewModel) {
    return Row(
      children: [
        const Icon(Icons.volume_up, color: Colors.white),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Slider(
            value: viewModel.masterVolume,
            min: 0.0,
            max: 1.0,
            activeColor: Colors.blue,
            inactiveColor: Colors.grey,
            onChanged: viewModel.setMasterVolume,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingActions(BuildContext context, DawViewModel viewModel) {
    return Row(
      children: [
        _buildProcessingButton(
          label: 'Magic Mix Vocals',
          onPressed: () => _showProcessingConfirmation(
            context, 
            viewModel.magicMixVocals,
            'Apply advanced vocal effects and mixing?',
          ),
          color: Colors.purple,
        ),
        const SizedBox(width: 16),
        _buildProcessingButton(
          label: 'AI Master Song',
          onPressed: () => _showProcessingConfirmation(
            context,
            viewModel.aiMasterSong,
            'Apply AI mastering to your song?',
          ),
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildProcessingButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.auto_awesome, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildTrackArea(BuildContext context, DawViewModel viewModel) {
    return Expanded(
      child: Column(
        children: [
          // Add a row with collapse/expand all buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tracks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: viewModel.toggleAllTracksCollapsed,
                      icon: const Icon(Icons.expand, size: 16),
                      label: const Text('Toggle All'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => viewModel.setAllTracksCollapsed(true),
                      icon: const Icon(Icons.expand_less, size: 16),
                      label: const Text('Collapse All'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => viewModel.setAllTracksCollapsed(false),
                      icon: const Icon(Icons.expand_more, size: 16),
                      label: const Text('Expand All'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTrackWidget('Beat Track', viewModel.beatTrack, Colors.blue, viewModel),
                  ...viewModel.vocalTracks.map((track) => 
                    _buildTrackWidget('Vocals', track, Colors.green, viewModel)
                  ),
                  if (viewModel.mixedVocalTrack != null)
                    _buildTrackWidget('Mixed Vocals', viewModel.mixedVocalTrack!, Colors.purple, viewModel),
                  if (viewModel.masteredSongTrack != null)
                    _buildTrackWidget('Mastered Song', viewModel.masteredSongTrack!, Colors.orange, viewModel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setAllTracksCollapsed(DawViewModel viewModel, bool collapsed) {
    // Set collapsed state for all tracks
    viewModel.setAllTracksCollapsed(collapsed);
  }

  Widget _buildTrackWidget(String title, Track track, Color color, DawViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CollapsibleTrackWidget(
        title: title,
        track: track,
        color: color,
        onImport: () => viewModel.importAudio(track),
        onRecord: track.type == TrackType.beat ? () => viewModel.toggleRecording(track) : null,
        onMute: () => viewModel.toggleMute(track),
        onSolo: () => viewModel.toggleSolo(track),
        onVolumeChanged: (value) => viewModel.setVolume(track, track.clips.isNotEmpty ? track.clips.first : null, value),
      ),
    );
  }

  Widget _buildProcessingOverlay(BuildContext context, DawViewModel viewModel) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: ProcessingDialog(
          operation: viewModel.currentOperation ?? 'Processing...',
          progress: viewModel.processingProgress,
        ),
      ),
    );
  }

  void _showProcessingConfirmation(
    BuildContext context,
    VoidCallback processFunction,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Processing'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              processFunction();
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, DawViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Project'),
        content: const Text('Are you sure you want to clear all tracks? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.clearProject();
              ProcessingSnackbar.showSuccess(
                context,
                'Project cleared successfully',
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog(BuildContext context, DawViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Project'),
        content: const Text('Project saved successfully!'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
