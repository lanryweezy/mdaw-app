import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:studio_wiz/services/ai_audio_brain.dart';

class AIChatInterface extends StatefulWidget {
  const AIChatInterface({super.key});

  @override
  State<AIChatInterface> createState() => _AIChatInterfaceState();
}

class _AIChatInterfaceState extends State<AIChatInterface> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool _isTyping = false;

  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    final text = _controller.text;
    setState(() {
      _messages.add('You: $text');
      _controller.clear();
      _isTyping = true;
    });

    _processIntent(text);
  }

  void _processIntent(String text) async {
    final lowerText = text.toLowerCase();
    String intentId = 'vocal_polish';
    String responseText = '';

    if (lowerText.contains('radio') ||
        lowerText.contains('pop') ||
        lowerText.contains('mainstream')) {
      intentId = 'radio_ready';
      responseText = 'Applying "Radio Ready" preset to your vocals...';
    } else if (lowerText.contains('club') ||
        lowerText.contains('bass') ||
        lowerText.contains('punch')) {
      intentId = 'club_mix';
      responseText = 'Applying "Club Mix" preset to give it more punch...';
    } else if (lowerText.contains('afrobeat') ||
        lowerText.contains('warm') ||
        lowerText.contains('groovy')) {
      intentId = 'afrobeat';
      responseText = 'Applying "Afrobeat Vibe" to your vocals...';
    } else if (lowerText.contains('drill') ||
        lowerText.contains('dark') ||
        lowerText.contains('aggressive')) {
      intentId = 'drill_uk';
      responseText = 'Applying "UK Drill" preset...';
    } else if (lowerText.contains('beat') ||
        lowerText.contains('generate') ||
        lowerText.contains('instrumental')) {
      // AI Beat Generation
      setState(() {
        _messages.add('AI: Generating a custom beat based on "$text"...');
        _isTyping = false;
      });
      Provider.of<DawViewModel>(context, listen: false).generateAIAudio(text);
      return;
    } else {
      responseText =
          'I will clean and tune your vocals with the "Vocal Polish" preset.';
    }

    setState(() {
      _messages.add('AI: $responseText');
      _isTyping = false;
    });

    final dawVM = Provider.of<DawViewModel>(context, listen: false);
    if (dawVM.selectedTrack != null && dawVM.selectedTrack!.clips.isNotEmpty) {
      dawVM.applyStudioMode(dawVM.selectedTrack!, intentId);
    } else if (dawVM.vocalTracks.isNotEmpty &&
        dawVM.vocalTracks.first.clips.isNotEmpty) {
      dawVM.applyStudioMode(dawVM.vocalTracks.first, intentId);
    } else {
      setState(() {
        _messages.add(
          'AI: I could not find an active vocal track to process. Please select a track first.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'AI Assistant',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D4FF),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isUser = _messages[index].startsWith('You:');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF00D4FF).withAlpha(40)
                            : Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUser
                              ? const Color(0xFF00D4FF).withAlpha(128)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        _messages[index].replaceFirst(
                          isUser ? 'You: ' : 'AI: ',
                          '',
                        ),
                        style: TextStyle(
                          color: isUser
                              ? const Color(0xFF00D4FF)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (_isTyping)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'AI is thinking...',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Ask me to "Make the vocals sound Radio Ready"...',
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF00D4FF)),
              onPressed: _sendMessage,
              tooltip: 'Send message',
            ),
          ],
        ),
      ],
    );
  }
}
