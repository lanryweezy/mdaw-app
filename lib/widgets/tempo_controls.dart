import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studio_wiz/view_models/timeline_view_model.dart';

class TempoControls extends StatelessWidget {
  const TempoControls({super.key});

  @override
  Widget build(BuildContext context) {
    final timelineViewModel = Provider.of<TimelineViewModel>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey[700]!, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // BPM control
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BPM', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: () {
                            final currentBpm = timelineViewModel.bpm;
                            timelineViewModel.setBpm(currentBpm - 1);
                          },
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                        ),
                        Container(
                          width: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[600]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${timelineViewModel.bpm}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () {
                            final currentBpm = timelineViewModel.bpm;
                            timelineViewModel.setBpm(currentBpm + 1);
                          },
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Time signature control
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Time Signature', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<int>(
                          value: timelineViewModel.timeSignatureNumerator,
                          items: [4, 3, 2].map((num) {
                            return DropdownMenuItem(
                              value: num,
                              child: Text('$num', style: const TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              timelineViewModel.setTimeSignature(value, timelineViewModel.timeSignatureDenominator);
                            }
                          },
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Text('/', style: TextStyle(fontSize: 12)),
                        DropdownButton<int>(
                          value: timelineViewModel.timeSignatureDenominator,
                          items: [4, 8].map((den) {
                            return DropdownMenuItem(
                              value: den,
                              child: Text('$den', style: const TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              timelineViewModel.setTimeSignature(timelineViewModel.timeSignatureNumerator, value);
                            }
                          },
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Snap to grid toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Snap', style: TextStyle(fontSize: 12)),
                    Switch(
                      value: timelineViewModel.snapToGrid,
                      onChanged: (value) => timelineViewModel.toggleSnapToGrid(),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconButton(
                context: context,
                icon: Icons.zoom_in,
                tooltip: 'Zoom In',
                onPressed: () {
                  timelineViewModel.zoomIn();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Zoomed in')),
                  );
                },
              ),
              _buildIconButton(
                context: context,
                icon: Icons.zoom_out,
                tooltip: 'Zoom Out',
                onPressed: () {
                  timelineViewModel.zoomOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Zoomed out')),
                  );
                },
              ),
              _buildIconButton(
                context: context,
                icon: Icons.center_focus_strong,
                tooltip: 'Fit to Screen',
                onPressed: () {
                  timelineViewModel.fitToScreen();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fit to screen')),
                  );
                },
              ),
              _buildIconButton(
                context: context,
                icon: Icons.content_copy,
                tooltip: 'Duplicate',
                onPressed: () {
                  timelineViewModel.duplicateSelectedClip();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Duplicated selected clip')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(25),
          foregroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(40, 40),
          maximumSize: const Size(40, 40),
        ),
      ),
    );
  }
}
