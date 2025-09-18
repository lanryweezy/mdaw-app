
import 'package:flutter/material.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:studio_wiz/widgets/track_widget.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Main screen for the Digital Audio Workstation (DAW)
class DawScreen extends StatefulWidget {
  const DawScreen({super.key});

  @override
  State<DawScreen> createState() => _DawScreenState();
}

/// State management for DawScreen
class _DawScreenState extends State<DawScreen> {
  /// Flag to indicate if export is in progress
  bool _isExporting = false;

  /// Exports a single track to a file
  /// [track] The track to export
  Future<void> _exportTrack(Track track) async {
    if (track.clips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No audio to export in this track')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export ${track.name}',
        fileName: '${track.name}_${DateTime.now().millisecondsSinceEpoch}',
        type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'aac', 'flac'],
      );

      if (result != null) {
        // For now, just copy the first clip's file
        // In a real implementation, you'd process and export the track properly
        final sourceFile = File(track.clips.first.path);
        final targetFile = File(result);
        await sourceFile.copy(targetFile.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${track.name} exported successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  /// Builds the UI for the DAW screen
  @override
  Widget build(BuildContext context) {
    return Consumer<DawViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('ProStudio DAW'),
            centerTitle: true,
            actions: [
              if (viewModel.masteredSongTrack != null && viewModel.masteredSongTrack!.hasAudio)
                IconButton(
                  icon: _isExporting 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                  onPressed: _isExporting ? null : () => _exportTrack(viewModel.masteredSongTrack!),
                  tooltip: 'Export Final Song',
                ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Clear Project'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export_all',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Export All Tracks'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'clear') {
                    _showClearProjectDialog(context, viewModel);
                  } else if (value == 'export_all') {
                    _exportAllTracks(viewModel);
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Beat Track
              TrackWidget(
                title: viewModel.beatTrack.name,
                track: viewModel.beatTrack,
                color: Colors.blue,
                onImport: () => viewModel.importAudio(viewModel.beatTrack),
                onMute: () => viewModel.toggleMute(viewModel.beatTrack),
                onSolo: () => viewModel.toggleSolo(viewModel.beatTrack),
                onVolumeChanged: (volume) => viewModel.setVolume(
                  viewModel.beatTrack,
                  viewModel.beatTrack.clips.isNotEmpty ? viewModel.beatTrack.clips.first : null, // Pass first clip for volume
                  volume,
                ),
              ),
              const Divider(height: 1, color: Colors.grey),

              // Vocal Tracks
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.vocalTracks.length + // Base vocal tracks
                      (viewModel.mixedVocalTrack != null ? 1 : 0) + // Mixed vocal track
                      (viewModel.masteredSongTrack != null ? 1 : 0), // Mastered song track
                  itemBuilder: (context, index) {
                    if (index < viewModel.vocalTracks.length) {
                      final vocalTrack = viewModel.vocalTracks[index];
                      return TrackWidget(
                        title: vocalTrack.name,
                        track: vocalTrack,
                        color: Colors.green,
                        onImport: () => viewModel.importAudio(vocalTrack),
                        onRecord: () => viewModel.toggleRecording(vocalTrack),
                        onMute: () => viewModel.toggleMute(vocalTrack),
                        onSolo: () => viewModel.toggleSolo(vocalTrack),
                        onVolumeChanged: (volume) => viewModel.setVolume(
                          vocalTrack,
                          vocalTrack.clips.isNotEmpty ? vocalTrack.clips.first : null, // Pass first clip for volume
                          volume,
                        ),
                      );
                    } else if (index == viewModel.vocalTracks.length && viewModel.mixedVocalTrack != null) {
                      // Mixed Vocal Track
                      return TrackWidget(
                        title: viewModel.mixedVocalTrack!.name,
                        track: viewModel.mixedVocalTrack!,
                        color: Colors.purple,
                        onImport: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mixed Vocal Track cannot be imported directly.')),
                          );
                        },
                        onMute: () => viewModel.toggleMute(viewModel.mixedVocalTrack!),
                        onSolo: () => viewModel.toggleSolo(viewModel.mixedVocalTrack!),
                        onVolumeChanged: (volume) => viewModel.setVolume(
                          viewModel.mixedVocalTrack!,
                          viewModel.mixedVocalTrack!.clips.isNotEmpty ? viewModel.mixedVocalTrack!.clips.first : null,
                          volume,
                        ),
                      );
                    } else {
                      // Mastered Song Track
                      return TrackWidget(
                        title: viewModel.masteredSongTrack!.name,
                        track: viewModel.masteredSongTrack!,
                        color: Colors.orange,
                        onImport: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mastered Song Track cannot be imported directly.')),
                          );
                        },
                        onMute: () => viewModel.toggleMute(viewModel.masteredSongTrack!),
                        onSolo: () => viewModel.toggleSolo(viewModel.masteredSongTrack!),
                        onVolumeChanged: (volume) => viewModel.setVolume(
                          viewModel.masteredSongTrack!,
                          viewModel.masteredSongTrack!.clips.isNotEmpty ? viewModel.masteredSongTrack!.clips.first : null,
                          volume,
                        ),
                      );
                    }
                  },
                ),
              ),

              // AI Mixing and Mastering Buttons
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'AI Processing',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => viewModel.magicMixVocals(),
                      icon: const Icon(Icons.auto_awesome, size: 28),
                      label: const Text('Magic Mix Vocals', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => viewModel.aiMasterSong(),
                      icon: const Icon(Icons.star, size: 28),
                      label: const Text('AI Master Song', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Global Playback Controls
              Container(
                padding: const EdgeInsets.all(12.0),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Stop Button
                    IconButton(
                      icon: const Icon(Icons.stop, size: 32),
                      onPressed: viewModel.stop,
                      color: Colors.white,
                    ),
                    // Play/Pause Button
                    IconButton(
                      icon: Icon(
                        viewModel.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        size: 48,
                      ),
                      onPressed: viewModel.isPlaying ? viewModel.pause : viewModel.play,
                      color: Colors.white,
                    ),
                    // Record Button (Global, for first available vocal track)
                    IconButton(
                      icon: Icon(
                        viewModel.isRecording ? Icons.stop_circle : Icons.mic,
                        size: 32,
                      ),
                      onPressed: () {
                        final emptyVocalTrack = viewModel.vocalTracks.firstWhere(
                          (track) => !track.hasAudio,
                          orElse: () => viewModel.vocalTracks.first, // Fallback to first track if all full
                        );
                        viewModel.toggleRecording(emptyVocalTrack);
                      },
                      color: viewModel.isRecording ? Colors.redAccent : Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows confirmation dialog for clearing the project
  /// [context] Build context
  /// [viewModel] DAW view model
  void _showClearProjectDialog(BuildContext context, DawViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Project'),
        content: const Text('Are you sure you want to clear the current project? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.clearProject();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Project cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// Exports all tracks to files
  /// [viewModel] DAW view model
  Future<void> _exportAllTracks(DawViewModel viewModel) async {
    setState(() => _isExporting = true);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${dir.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      int exportedCount = 0;

      // Export beat track
      if (viewModel.beatTrack.hasAudio) {
        final sourceFile = File(viewModel.beatTrack.clips.first.path);
        final targetFile = File('${exportDir.path}/beat_$timestamp.wav');
        await sourceFile.copy(targetFile.path);
        exportedCount++;
      }

      // Export vocal tracks
      for (int i = 0; i < viewModel.vocalTracks.length; i++) {
        final track = viewModel.vocalTracks[i];
        if (track.hasAudio) {
          final sourceFile = File(track.clips.first.path);
          final targetFile = File('${exportDir.path}/vocal_${i + 1}_$timestamp.wav');
          await sourceFile.copy(targetFile.path);
          exportedCount++;
        }
      }

      // Export mixed vocals
      if (viewModel.mixedVocalTrack != null && viewModel.mixedVocalTrack!.hasAudio) {
        final sourceFile = File(viewModel.mixedVocalTrack!.clips.first.path);
        final targetFile = File('${exportDir.path}/mixed_vocals_$timestamp.wav');
        await sourceFile.copy(targetFile.path);
        exportedCount++;
      }

      // Export mastered song
      if (viewModel.masteredSongTrack != null && viewModel.masteredSongTrack!.hasAudio) {
        final sourceFile = File(viewModel.masteredSongTrack!.clips.first.path);
        final targetFile = File('${exportDir.path}/mastered_song_$timestamp.wav');
        await sourceFile.copy(targetFile.path);
        exportedCount++;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$exportedCount tracks exported to ${exportDir.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }
}
