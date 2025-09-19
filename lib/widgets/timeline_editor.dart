import 'package:flutter/material.dart';
import 'package:studio_wiz/models/audio_clip.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:studio_wiz/view_models/timeline_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class TimelineEditor extends StatelessWidget {
  const TimelineEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final dawViewModel = Provider.of<DawViewModel>(context);
    final timelineViewModel = Provider.of<TimelineViewModel>(context);

    return SafeArea(
      bottom: false,
      child: Column(
      children: [
        _buildTimelineHeader(context, timelineViewModel),
        Expanded(
          child: Row(
            children: [
              _buildTrackList(context, dawViewModel, timelineViewModel),
              Expanded(
                child: _buildTimelineView(context, dawViewModel, timelineViewModel),
              ),
            ],
          ),
        ),
        _buildTimelineControls(context, timelineViewModel),
      ],
      ),
    );
  }

  Widget _buildTimelineHeader(BuildContext context, TimelineViewModel timelineViewModel) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey[700]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Track header
          Container(
            width: 200,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Tracks',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Timeline ruler
          Expanded(
            child: _buildTimelineRuler(context, timelineViewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRuler(BuildContext context, TimelineViewModel timelineViewModel) {
    return SizedBox(
      height: 60,
      child: RepaintBoundary(
        child: CustomPaint(
        painter: TimelineRulerPainter(
          pixelsPerSecond: timelineViewModel.pixelsPerSecond,
          currentPosition: timelineViewModel.currentPosition,
          isPlaying: timelineViewModel.isPlaying,
          totalDuration: timelineViewModel.totalDuration,
        ),
        ),
      ),
    );
  }

  Widget _buildTrackList(BuildContext context, DawViewModel dawViewModel, TimelineViewModel timelineViewModel) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Colors.grey[700]!, width: 1),
        ),
      ),
      child: ListView(
        children: [
          _buildTrackHeader(context, dawViewModel, timelineViewModel, dawViewModel.beatTrack, 'Beat'),
          ...dawViewModel.vocalTracks.map((track) => _buildTrackHeader(context, dawViewModel, timelineViewModel, track, track.name)),
          if (dawViewModel.mixedVocalTrack != null)
            _buildTrackHeader(context, dawViewModel, timelineViewModel, dawViewModel.mixedVocalTrack!, 'Mixed Vocals'),
          if (dawViewModel.masteredSongTrack != null)
            _buildTrackHeader(context, dawViewModel, timelineViewModel, dawViewModel.masteredSongTrack!, 'Mastered Song'),
        ],
      ),
    );
  }

  Widget _buildTrackHeader(BuildContext context, DawViewModel dawViewModel, TimelineViewModel timelineViewModel, Track track, String displayName) {
    return Container(
      constraints: BoxConstraints(minHeight: timelineViewModel.trackHeight),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        gradient: track.collapsed
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[850]!,
                  Colors.grey[900]!,
                ],
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  track.collapsed ? Icons.expand_more : Icons.expand_less,
                  size: 16,
                  color: track.collapsed ? Colors.grey[500] : Colors.white,
                ),
                onPressed: () => dawViewModel.toggleCollapse(track),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                tooltip: track.collapsed ? 'Expand track' : 'Collapse track',
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: track.collapsed ? Colors.grey[400] : Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (track.collapsed && track.clips.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${track.clips.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  track.muted ? Icons.volume_off : Icons.volume_up,
                  size: 16,
                ),
                onPressed: () => dawViewModel.toggleMute(track),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
              IconButton(
                icon: Icon(
                  track.soloed ? Icons.hearing : Icons.hearing_disabled,
                  size: 16,
                ),
                onPressed: () => dawViewModel.toggleSolo(track),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
              if (track.collapsed) ...[
                if (track.muted)
                  const Icon(Icons.volume_off, size: 12, color: Colors.red),
                if (track.soloed)
                  const Icon(Icons.star, size: 12, color: Colors.yellow),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView(BuildContext context, DawViewModel dawViewModel, TimelineViewModel timelineViewModel) {
    final contentWidth = timelineViewModel.durationToPixels(timelineViewModel.totalDuration);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Scrollbar(
        interactive: true,
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: contentWidth,
            child: Stack(
              children: [
                _buildGridBackground(context, timelineViewModel),
                _buildTracks(context, dawViewModel, timelineViewModel),
                _buildPlayhead(context, timelineViewModel),
                Positioned.fill(child: _buildTimelineGestureDetector(context, timelineViewModel)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridBackground(BuildContext context, TimelineViewModel timelineViewModel) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(timelineViewModel.durationToPixels(timelineViewModel.totalDuration), double.infinity),
        painter: GridPainter(
          gridSize: timelineViewModel.gridSize,
          pixelsPerSecond: timelineViewModel.pixelsPerSecond,
          trackHeight: timelineViewModel.trackHeight,
        ),
      ),
    );
  }

  Widget _buildTracks(BuildContext context, DawViewModel dawViewModel, TimelineViewModel timelineViewModel) {
    return Column(
      children: [
        _buildTrackLane(context, dawViewModel, timelineViewModel, dawViewModel.beatTrack, 0),
        ...dawViewModel.vocalTracks.asMap().entries.map((entry) =>
            _buildTrackLane(context, dawViewModel, timelineViewModel, entry.value, entry.key + 1)),
        if (dawViewModel.mixedVocalTrack != null)
          _buildTrackLane(context, dawViewModel, timelineViewModel, dawViewModel.mixedVocalTrack!, dawViewModel.vocalTracks.length + 1),
        if (dawViewModel.masteredSongTrack != null)
          _buildTrackLane(context, dawViewModel, timelineViewModel, dawViewModel.masteredSongTrack!, dawViewModel.vocalTracks.length + 2),
      ],
    );
  }

  Widget _buildTrackLane(BuildContext context, DawViewModel dawViewModel, TimelineViewModel timelineViewModel, Track track, int trackIndex) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: track.collapsed ? timelineViewModel.trackHeight / 2 : timelineViewModel.trackHeight,
      curve: Curves.easeInOut,
      child: Stack(
        children: track.collapsed
            ? [_buildCollapsedTrackView(context, timelineViewModel, track, trackIndex)]
            : track.clips.map((clip) => _buildClip(context, dawViewModel, timelineViewModel, clip, trackIndex)).toList(),
      ),
    );
  }

  Widget _buildCollapsedTrackView(BuildContext context, TimelineViewModel timelineViewModel, Track track, int trackIndex) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(

        color: Colors.grey[800]!.withAlpha(127),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              _getTrackIcon(track),
              color: Colors.grey[400],
              size: 16,
            ),
          ),
          Expanded(
            child: Text(
              track.name,
              style: TextStyle(
                color: track.muted ? Colors.grey[600] : Colors.grey[400],
                fontSize: 12,
                fontWeight: track.soloed ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (track.clips.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${track.clips.length} clip${track.clips.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 10,
                ),
              ),
            ),
          if (track.muted)
            const Icon(Icons.volume_off, size: 14, color: Colors.red),
          if (track.soloed)
            const Icon(Icons.star, size: 14, color: Colors.yellow),
        ],
      ),
    );
  }

  IconData _getTrackIcon(Track track) {
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

  Widget _buildClip(BuildContext context, DawViewModel dawViewModel, TimelineViewModel timelineViewModel, AudioClip clip, int trackIndex) {
    final clipWidth = timelineViewModel.durationToPixels(clip.endTime - clip.startTime);
    final clipX = timelineViewModel.durationToPixels(clip.startTime);
    final isSelected = timelineViewModel.selectedClipId == clip.id;

    final minWidth = 20.0;
    final displayWidth = math.max(clipWidth, minWidth);

    return Positioned(
      left: clipX,
      top: 4,
      child: GestureDetector(
        onTap: () {
          timelineViewModel.selectClip(clip.id);
        },
        onPanStart: (details) {
          timelineViewModel.startDragging(clip.id, details.globalPosition);
        },
        onPanUpdate: (details) {
          timelineViewModel.dragClip(details.globalPosition);
        },
        onPanEnd: (details) {
          timelineViewModel.stopDragging();
        },
        child: Container(
          width: displayWidth,
          height: timelineViewModel.trackHeight - 8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isSelected
                  ? [Theme.of(context).colorScheme.primary.withAlpha(229), Theme.of(context).colorScheme.primary.withAlpha(153)]
                  : [Theme.of(context).colorScheme.secondary.withAlpha(178), Theme.of(context).colorScheme.secondary.withAlpha(102)],            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withAlpha(102),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: WaveformPainter(
                      isSelected: isSelected,
                      color: Theme.of(context).colorScheme.primary,
                      waveform: clip.waveform,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                top: 4,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withAlpha(178),
                        Colors.black.withAlpha(76),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    clip.path.split('/').last.split('.').first,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[300],
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (isSelected) ...[
                // Trim and Fade Handles
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      if (timelineViewModel.selectedTool == TimelineTool.trim) {
                        final deltaX = details.delta.dx;
                        final deltaDuration = timelineViewModel.pixelsToDuration(deltaX);
                        final newStartTime = timelineViewModel.snapDurationToGrid(clip.startTime + deltaDuration);
                        if (newStartTime < clip.endTime && newStartTime >= Duration.zero) {
                          timelineViewModel.trimClip(clip.id, newStartTime, clip.endTime);
                        }
                      } else {
                        final newFadeInDuration = clip.fadeInDuration + timelineViewModel.pixelsToDuration(details.delta.dx);
                        if (newFadeInDuration.inMilliseconds >= 0 && newFadeInDuration < clip.duration) {
                          timelineViewModel.setFadeIn(clip.id, newFadeInDuration);
                        }
                      }
                    },
                    child: Container(
                      width: 12,
                      decoration: BoxDecoration(
                        color: timelineViewModel.selectedTool == TimelineTool.trim
                            ? Colors.yellow.withAlpha(100)
                            : Colors.blue.withAlpha(100),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
                      ),
                      child: Icon(
                        timelineViewModel.selectedTool == TimelineTool.trim ? Icons.arrow_left : Icons.chevron_left,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      if (timelineViewModel.selectedTool == TimelineTool.trim) {
                        final deltaX = details.delta.dx;
                        final deltaDuration = timelineViewModel.pixelsToDuration(deltaX);
                        final newEndTime = timelineViewModel.snapDurationToGrid(clip.endTime + deltaDuration);
                        if (newEndTime > clip.startTime) {
                          timelineViewModel.trimClip(clip.id, clip.startTime, newEndTime);
                        }
                      } else {
                        final newFadeOutDuration = clip.fadeOutDuration - timelineViewModel.pixelsToDuration(details.delta.dx);
                        if (newFadeOutDuration.inMilliseconds >= 0 && newFadeOutDuration < clip.duration) {
                          timelineViewModel.setFadeOut(clip.id, newFadeOutDuration);
                        }
                      }
                    },
                    child: Container(
                      width: 12,
                      decoration: BoxDecoration(
                        color: timelineViewModel.selectedTool == TimelineTool.trim
                            ? Colors.yellow.withAlpha(100)
                            : Colors.blue.withAlpha(100),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
                      ),
                      child: Icon(
                        timelineViewModel.selectedTool == TimelineTool.trim ? Icons.arrow_right : Icons.chevron_right,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayhead(BuildContext context, TimelineViewModel timelineViewModel) {
    final playheadX = timelineViewModel.durationToPixels(timelineViewModel.currentPosition);

    return Positioned(
      left: playheadX,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        decoration: BoxDecoration(
          color: Colors.red,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withAlpha(127),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineGestureDetector(BuildContext context, TimelineViewModel timelineViewModel) {
    return GestureDetector(
      onTapDown: (details) {
        final localPosition = details.localPosition;
        final newPosition = timelineViewModel.pixelsToDuration(localPosition.dx);

        if (timelineViewModel.selectedTool == TimelineTool.split) {
          final trackIndex = (localPosition.dy / timelineViewModel.trackHeight).floor();
          final dawViewModel = Provider.of<DawViewModel>(context, listen: false);
          final tracks = [
            dawViewModel.beatTrack,
            ...dawViewModel.vocalTracks,
            if (dawViewModel.mixedVocalTrack != null) dawViewModel.mixedVocalTrack!,
            if (dawViewModel.masteredSongTrack != null) dawViewModel.masteredSongTrack!,
          ];
          if (trackIndex < tracks.length) {
            final track = tracks[trackIndex];
            for (final clip in track.clips) {
              if (newPosition >= clip.startTime && newPosition <= clip.endTime) {
                timelineViewModel.splitClip(clip.id, newPosition);
                break;
              }
            }
          }
        } else {
          timelineViewModel.seekTo(newPosition);
          timelineViewModel.selectClip(null);
        }
      },
      child: Container(
        // Fills via Positioned.fill from parent Stack
        color: Colors.transparent,
      ),
    );
  }

  Widget _buildTimelineControls(BuildContext context, TimelineViewModel timelineViewModel) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey[700]!, width: 1),
        ),
      ),
      child: Scrollbar(
        interactive: true,
        thumbVisibility: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            IconButton(
              icon: const Icon(Icons.zoom_out, size: 18),
              onPressed: () => timelineViewModel.setZoomLevel(timelineViewModel.zoomLevel - 0.1),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            Text('${(timelineViewModel.zoomLevel * 100).round()}%', style: const TextStyle(fontSize: 12)),
            IconButton(
              icon: const Icon(Icons.zoom_in, size: 18),
              onPressed: () => timelineViewModel.setZoomLevel(timelineViewModel.zoomLevel + 0.1),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(
                timelineViewModel.snapToGrid ? Icons.grid_on : Icons.grid_off,
                color: timelineViewModel.snapToGrid ? Theme.of(context).colorScheme.primary : null,
              ),
              onPressed: () => timelineViewModel.toggleSnapToGrid(),
              tooltip: 'Snap to Grid',
            ),
            const SizedBox(width: 16),
            DropdownButton<Duration>(
              value: timelineViewModel.gridSize,
              isDense: true,
              items: const [
                DropdownMenuItem(
                  value: Duration(milliseconds: 250),
                  child: Text('1/8'),
                ),
                DropdownMenuItem(
                  value: Duration(milliseconds: 500),
                  child: Text('1/4'),
                ),
                DropdownMenuItem(
                  value: Duration(milliseconds: 1000),
                  child: Text('1/2'),
                ),
                DropdownMenuItem(
                  value: Duration(seconds: 1),
                  child: Text('1'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  timelineViewModel.setGridSize(value);
                }
              },
            ),
            const SizedBox(width: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${timelineViewModel.formatCurrentTime()} / ${timelineViewModel.formatDuration(timelineViewModel.totalDuration)}',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ToggleButtons(
              isSelected: [
                timelineViewModel.selectedTool == TimelineTool.select,
                timelineViewModel.selectedTool == TimelineTool.split,
                timelineViewModel.selectedTool == TimelineTool.trim,
              ],
              onPressed: (index) {
                timelineViewModel.setTool(TimelineTool.values[index]);
              },
              children: const [
                Icon(Icons.select_all),
                Icon(Icons.content_cut),
                Icon(Icons.straighten),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimelineRulerPainter extends CustomPainter {
  final double pixelsPerSecond;
  final Duration currentPosition;
  final bool isPlaying;
  final Duration totalDuration;

  TimelineRulerPainter({
    required this.pixelsPerSecond,
    required this.currentPosition,
    required this.isPlaying,
    required this.totalDuration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final bgPaint = Paint()
      ..color = Colors.grey[900]!
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final minorTickInterval = pixelsPerSecond;
    paint.strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += minorTickInterval) {
      canvas.drawLine(
        Offset(x, size.height - 15),
        Offset(x, size.height - 5),
        paint,
      );
    }

    final majorTickInterval = pixelsPerSecond * 5;
    paint.strokeWidth = 2;
    final majorTickPaint = Paint()
      ..color = Colors.blue[300]!
      ..strokeWidth = 2;

    for (double x = 0; x < size.width; x += majorTickInterval) {
      canvas.drawLine(
        Offset(x, size.height - 25),
        Offset(x, size.height - 5),
        majorTickPaint,
      );

      final seconds = (x / pixelsPerSecond).round();
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      final timeText = '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

      textPainter.text = TextSpan(
        text: timeText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 45),
      );
    }

    final playheadX = (currentPosition.inMilliseconds / 1000.0) * pixelsPerSecond;
    final playheadPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.red, Colors.orange],
      ).createShader(Rect.fromLTWH(playheadX - 1, 0, 2, size.height));

    final playheadTopPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(playheadX - 8, 0)
      ..lineTo(playheadX + 8, 0)
      ..lineTo(playheadX, 12)
      ..close();
    canvas.drawPath(path, playheadTopPaint);

    canvas.drawLine(
      Offset(playheadX, 12),
      Offset(playheadX, size.height),
      playheadPaint,
    );

    final glowPaint = Paint()
      ..color = Colors.red.withAlpha(76)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawLine(
      Offset(playheadX, 0),
      Offset(playheadX, size.height),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WaveformPainter extends CustomPainter {
  final bool isSelected;
  final Color color;
  final List<double> waveform;

  WaveformPainter({
    required this.isSelected,
    required this.color,
    required this.waveform,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSelected ? color.withAlpha(204) : color.withAlpha(102)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    if (waveform.isEmpty) {
      return;
    }

    final centerY = size.height / 2;
    final segmentWidth = size.width / waveform.length;

    for (int i = 0; i < waveform.length; i++) {
      final height = waveform[i] * (size.height / 2);
      final startX = i * segmentWidth;
      final endX = startX + segmentWidth;

      canvas.drawLine(
        Offset(startX, centerY - height),
        Offset(endX, centerY - height),
        paint,
      );

      canvas.drawLine(
        Offset(startX, centerY + height),
        Offset(endX, centerY + height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! WaveformPainter) return true;
    final WaveformPainter previous = oldDelegate as WaveformPainter;
    return previous.isSelected != isSelected ||
        previous.color != color ||
        previous.waveform.length != waveform.length;
  }
}

class GridPainter extends CustomPainter {
  final Duration gridSize;
  final double pixelsPerSecond;
  final double trackHeight;

  GridPainter({
    required this.gridSize,
    required this.pixelsPerSecond,
    required this.trackHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 0.5;

    final double gridWidth = (gridSize.inMilliseconds / 1000.0) * pixelsPerSecond;

    for (double x = 0; x < size.width; x += gridWidth) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += trackHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 
