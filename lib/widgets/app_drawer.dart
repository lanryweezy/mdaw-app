import 'package:flutter/material.dart';
import 'package:studio_wiz/app_constants.dart';
import 'package:studio_wiz/screens/settings_screen.dart';
import 'package:studio_wiz/screens/help_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          // Header
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00D4FF).withAlpha(204),
                  const Color(0xFF7B68EE).withAlpha(204),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.music_note,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppConstants.appTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.professionalMobileDaw,
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: AppConstants.settingsScreenTitle,
                  subtitle: AppConstants.settingsSubtitle,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help,
                  title: AppConstants.helpScreenTitle,
                  subtitle: AppConstants.helpSubtitle,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info,
                  title: 'About',
                  subtitle: AppConstants.aboutSubtitle,
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
                const Divider(color: Colors.grey),
                _buildDrawerItem(
                  icon: Icons.star,
                  title: 'Rate App',
                  subtitle: AppConstants.rateAppSubtitle,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(AppConstants.rateAppComingSoon)),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.share,
                  title: 'Share App',
                  subtitle: AppConstants.shareAppSubtitle,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(AppConstants.shareAppComingSoon)),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  AppConstants.version,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.copyright,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF00D4FF).withAlpha(51),
        child: Icon(
          icon,
          color: const Color(0xFF00D4FF),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 12,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.grey[800],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.aboutDialogTitle,
      applicationVersion: AppConstants.version,
      applicationIcon: const Icon(
        Icons.music_note,
        size: 48,
        color: Color(0xFF00D4FF),
      ),
      children: [
        const Text(
          AppConstants.aboutDialogDescription,
        ),
        const SizedBox(height: 16),
        const Text(
          AppConstants.featuresTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text(AppConstants.feature1),
        const Text(AppConstants.feature2),
        const Text(AppConstants.feature3),
        const Text(AppConstants.feature4),
        const Text(AppConstants.feature5),
        const Text(AppConstants.feature6),
      ],
    );
  }
}
