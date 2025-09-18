
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:studio_wiz/models/audio_clip.dart';

class AudioClipWidget extends StatelessWidget {
  final AudioClip clip;
  final Color waveformColor;

  const AudioClipWidget({
    super.key,
    required this.clip,
    required this.waveformColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(51),
        borderRadius: BorderRadius.circular(8),
      ),
      child: clip.controller.playerState != PlayerState.stopped
          ? AudioFileWaveforms(
              size: const Size(double.infinity, 70.0),
              playerController: clip.controller,
              enableSeekGesture: true,
              playerWaveStyle: PlayerWaveStyle(
                fixedWaveColor: Colors.grey[600]!,
                liveWaveColor: waveformColor,
                spacing: 10,
                showSeekLine: true,
                seekLineColor: Colors.redAccent,
              ),
            )
          : Center(
              child: Text(
                clip.path.split('/').last,
                style: TextStyle(color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
    );
  }
}
