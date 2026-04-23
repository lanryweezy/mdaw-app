import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:studio_wiz/services/ai_audio_brain.dart';

class AIToolsPanel extends StatelessWidget {
  final Track track;

  const AIToolsPanel({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('A.I. Producer Mode', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00D4FF))),
        const SizedBox(height: 8),
        Text('Select your vision. The AI Brain will automatically detect pitch, set EQ, and master the mix.',
            style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        const SizedBox(height: 24),
        ...AIAudioBrain.intents.map((intent) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AIToolButton(
            title: _formatIntentName(intent.name),
            description: intent.description,
            icon: Icons.auto_awesome,
            onPressed: () => _applyMode(context, intent.name),
          ),
        )),
        const SizedBox(height: 32),
        const Text('Pro Utility Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        AIToolButton(
          title: 'Extract Stems',
          description: 'Uses Neural Networks to split vocals from instrumentals',
          icon: Icons.call_split,
          onPressed: () => _applyStemSeparation(context),
        ),
      ],
    );
  }

  String _formatIntentName(String name) {
    if (name == 'vocal_polish') return 'Vocal Polish';
    if (name == 'radio_ready') return 'Radio Ready';
    if (name == 'club_mix') return 'Club Mix';
    if (name == 'afrobeat') return 'Afrobeat Vibe';
    if (name == 'drill_uk') return 'UK Drill';
    return name;
  }

  void _applyMode(BuildContext context, String mode) {
    final dawVM = Provider.of<DawViewModel>(context, listen: false);
    dawVM.applyStudioMode(track, mode);
  }

  void _applyStemSeparation(BuildContext context) {
    Provider.of<DawViewModel>(context, listen: false).separateStems();
  }
}

class AIToolButton extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;

  const AIToolButton({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<AIToolButton> createState() => _AIToolButtonState();
}

class _AIToolButtonState extends State<AIToolButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF333333)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                                    color: const Color(0xFF00D4FF).withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: const Color(0xFF00D4FF), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(widget.description, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFF00D4FF), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
