import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.play_circle), text: 'Getting Started'),
            Tab(icon: Icon(Icons.help), text: 'FAQ'),
            Tab(icon: Icon(Icons.video_library), text: 'Tutorials'),
            Tab(icon: Icon(Icons.contact_support), text: 'Contact'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGettingStartedTab(),
          _buildFAQTab(),
          _buildTutorialsTab(),
          _buildContactTab(),
        ],
      ),
    );
  }

  Widget _buildGettingStartedTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionCard(
          'Welcome to ProStudio DAW',
          'ProStudio DAW is a professional digital audio workstation designed for mobile devices. Create, record, mix, and master your music with AI-powered tools.',
          Icons.music_note,
        ),
        const SizedBox(height: 16),
        _buildStepCard(
          'Step 1: Import Your Beat',
          'Start by importing your instrumental beat into the Beat Track. Tap the "Import" button and select your audio file.',
          '1',
        ),
        _buildStepCard(
          'Step 2: Record Vocals',
          'Record your vocals on any of the 7 vocal tracks. Tap the "Record" button and start singing. Tap again to stop.',
          '2',
        ),
        _buildStepCard(
          'Step 3: Mix Your Vocals',
          'Use the "Magic Mix Vocals" button to automatically apply professional vocal effects and mix all your vocal tracks together.',
          '3',
        ),
        _buildStepCard(
          'Step 4: Master Your Song',
          'Click "AI Master Song" to automatically master your final track, combining vocals and beat with professional mastering effects.',
          '4',
        ),
        _buildStepCard(
          'Step 5: Export Your Music',
          'Save your project and export your final mastered song in various formats (WAV, MP3, AAC, FLAC).',
          '5',
        ),
        const SizedBox(height: 16),
        _buildTipCard(
          'Pro Tip',
          'Use the Mute (M) and Solo (S) buttons to focus on specific tracks while mixing. Adjust volume levels with the sliders for perfect balance.',
        ),
      ],
    );
  }

  Widget _buildFAQTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFAQItem(
          'How do I import audio files?',
          'Tap the "Import" button on any track, then select your audio file from your device. Supported formats include WAV, MP3, AAC, and M4A.',
        ),
        _buildFAQItem(
          'What audio formats are supported?',
          'ProStudio supports WAV, MP3, AAC, M4A, and FLAC files for import. For export, you can choose between WAV, MP3, AAC, and FLAC formats.',
        ),
        _buildFAQItem(
          'How does the AI mixing work?',
          'The AI automatically applies professional vocal effects including EQ, compression, reverb, and echo. It intelligently balances levels and enhances your vocals.',
        ),
        _buildFAQItem(
          'Can I adjust individual track volumes?',
          'Yes! Each track has a volume slider. You can also mute or solo tracks using the M and S buttons for better control during mixing.',
        ),
        _buildFAQItem(
          'How do I save my projects?',
          'Go to the Projects tab and tap "Save Current" to save your work. You can load saved projects anytime from the Projects screen.',
        ),
        _buildFAQItem(
          'What is the difference between mixing and mastering?',
          'Mixing combines and balances all your vocal tracks with effects. Mastering takes the mixed vocals and beat, then applies final processing for a professional sound.',
        ),
        _buildFAQItem(
          'Can I record multiple takes?',
          'Yes! You can record on multiple vocal tracks to create harmonies, ad-libs, or different vocal parts. Each track can have its own volume and effects.',
        ),
        _buildFAQItem(
          'How do I export my final song?',
          'After mastering, your final song will appear in the "Mastered Song" track. You can then export it in your preferred format from the export options.',
        ),
      ],
    );
  }

  Widget _buildTutorialsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTutorialCard(
          'Basic Recording Workflow',
          'Learn the fundamentals of recording vocals in ProStudio DAW',
          Icons.play_circle_filled,
          '5:30',
          () => _showComingSoon(),
        ),
        _buildTutorialCard(
          'Advanced Mixing Techniques',
          'Master the art of vocal mixing with AI-powered tools',
          Icons.equalizer,
          '8:15',
          () => _showComingSoon(),
        ),
        _buildTutorialCard(
          'Mastering Your Final Track',
          'Complete guide to mastering your songs for professional quality',
          Icons.star,
          '6:45',
          () => _showComingSoon(),
        ),
        _buildTutorialCard(
          'Project Management',
          'How to organize and manage your music projects effectively',
          Icons.folder,
          '4:20',
          () => _showComingSoon(),
        ),
        _buildTutorialCard(
          'Export Settings Guide',
          'Choose the right export format and quality for your needs',
          Icons.download,
          '3:10',
          () => _showComingSoon(),
        ),
        _buildTutorialCard(
          'Troubleshooting Audio Issues',
          'Common problems and solutions for audio recording and playback',
          Icons.build,
          '7:00',
          () => _showComingSoon(),
        ),
      ],
    );
  }

  Widget _buildContactTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildContactCard(
          'Email Support',
          'Get help from our support team',
          'support@prostudiodaw.com',
          Icons.email,
          () => _showComingSoon(),
        ),
        _buildContactCard(
          'Community Forum',
          'Connect with other users and share tips',
          'Join our community',
          Icons.forum,
          () => _showComingSoon(),
        ),
        _buildContactCard(
          'Feature Requests',
          'Suggest new features and improvements',
          'Submit your ideas',
          Icons.lightbulb,
          () => _showComingSoon(),
        ),
        _buildContactCard(
          'Bug Reports',
          'Report issues and help us improve',
          'Report a bug',
          Icons.bug_report,
          () => _showComingSoon(),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Follow Us',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSocialButton('Twitter', Icons.alternate_email, () => _showComingSoon()),
                    const SizedBox(width: 12),
                    _buildSocialButton('Instagram', Icons.camera_alt, () => _showComingSoon()),
                    const SizedBox(width: 12),
                    _buildSocialButton('YouTube', Icons.play_circle, () => _showComingSoon()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, String content, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(String title, String content, String stepNumber) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(
                stepNumber,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String content) {
    return Card(
      color: Theme.of(context).colorScheme.primary.withAlpha(25),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialCard(String title, String description, IconData icon, String duration, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Text(
              duration,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.play_arrow),
        onTap: onTap,
      ),
    );
  }

  Widget _buildContactCard(String title, String description, String action, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description),
        trailing: Text(
          action,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This feature is coming soon!')),
    );
  }
}
