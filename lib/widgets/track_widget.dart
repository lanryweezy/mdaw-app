
import 'package:flutter/material.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:studio_wiz/models/audio_clip.dart';
import 'package:studio_wiz/widgets/audio_clip_widget.dart';

class TrackWidget extends StatelessWidget {
  final String title;
  final Track track;
  final Color color;
  final VoidCallback onImport;
  final VoidCallback? onRecord; // Optional for beat track
  final VoidCallback onMute;
  final VoidCallback onSolo;
  final ValueChanged<double> onVolumeChanged;

  const TrackWidget({
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: color.withAlpha(25),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Track Header (Name, Import/Record Buttons)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: onImport,
                      icon: const Icon(Icons.folder_open, size: 18),
                      label: const Text('Import'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], foregroundColor: Colors.white),
                    ),
                    if (onRecord != null) ...[ // Only show record button if onRecord is provided
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: onRecord,
                        icon: const Icon(Icons.mic, size: 18),
                        label: const Text('Record'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], foregroundColor: Colors.white),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Audio Clips (Waveforms)
            if (track.clips.isNotEmpty)
              Column(
                children: track.clips.map((clip) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: AudioClipWidget(
                      clip: clip,
                      waveformColor: theme.colorScheme.primary,
                    ),
                  );
                }).toList(),
              )
            else
              Container(
                height: 70,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('No audio clips', style: TextStyle(color: Colors.grey[600])),
                ),
              ),
            const SizedBox(height: 12),

            // Mute/Solo/Volume Controls
            Row(
              children: [
                OutlinedButton(
                  onPressed: onMute,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: track.muted ? Colors.white : Colors.grey[400],
                    backgroundColor: track.muted ? Colors.redAccent.withAlpha(178) : Colors.transparent,
                    side: BorderSide(color: track.muted ? Colors.redAccent : Colors.grey),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text('M'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onSolo,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: track.soloed ? Colors.black : Colors.grey[400],
                    backgroundColor: track.soloed ? Colors.yellow.withAlpha(204) : Colors.transparent,
                    side: BorderSide(color: track.soloed ? Colors.yellow : Colors.grey),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text('S'),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.volume_down),
                Expanded(
                  child: Slider(
                    value: track.clips.isNotEmpty ? track.clips.first.volume : 1.0, // Use first clip's volume for now
                    onChanged: onVolumeChanged,
                    min: 0.0,
                    max: 1.0,
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: Colors.grey[700],
                  ),
                ),
                const Icon(Icons.volume_up),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
