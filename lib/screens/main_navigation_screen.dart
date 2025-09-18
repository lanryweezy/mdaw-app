import 'package:flutter/material.dart';
import 'package:studio_wiz/app_constants.dart';
import 'package:studio_wiz/screens/enhanced_daw_screen.dart';
import 'package:studio_wiz/screens/settings_screen.dart';
import 'package:studio_wiz/screens/help_screen.dart';
import 'package:studio_wiz/screens/project_screen.dart';
import 'package:studio_wiz/widgets/app_drawer.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0; // This should default to 0 for Studio screen
  bool _isNavigationVisible = true;
  
  final List<Widget> _screens = [
    const EnhancedDawScreen(), // Index 0 - Studio
    const ProjectScreen(),     // Index 1 - Projects
    const SettingsScreen(),    // Index 2 - Settings
    const HelpScreen(),        // Index 3 - Help
  ];

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    // Ensure the studio screen is visible by default
    if (_currentIndex < 0 || _currentIndex >= _screens.length) {
      _currentIndex = 0;
    }
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: isLandscape ? null : AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _isNavigationVisible ? 80 : 0,
        child: _isNavigationVisible ? Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(76),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Toggle button
              Container(
                height: 24,
                child: Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _isNavigationVisible = false),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              // Navigation bar
              Expanded(
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: const Color(0xFF00D4FF),
                  unselectedItemColor: Colors.grey[600],
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.music_note),
                      label: AppConstants.studioScreenTitle,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.folder),
                      label: AppConstants.projectsScreenTitle,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: AppConstants.settingsScreenTitle,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.help),
                      label: AppConstants.helpScreenTitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ) : null,
      ),
      // Floating action button to show navigation when hidden
      floatingActionButton: isLandscape ? null : (!_isNavigationVisible ? FloatingActionButton(
        mini: true,
        backgroundColor: const Color(0xFF00D4FF),
        onPressed: () => setState(() => _isNavigationVisible = true),
        child: const Icon(Icons.keyboard_arrow_up, color: Colors.black),
      ) : null),
      drawer: isLandscape ? null : const AppDrawer(),
      appBar: isLandscape ? AppBar(
        title: const Text(AppConstants.appTitle),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        actions: [
          // Navigation buttons for landscape mode
          IconButton(
            icon: const Icon(Icons.music_note),
            onPressed: () => setState(() => _currentIndex = 0),
            color: _currentIndex == 0 ? const Color(0xFF00D4FF) : Colors.grey[600],
          ),
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: () => setState(() => _currentIndex = 1),
            color: _currentIndex == 1 ? const Color(0xFF00D4FF) : Colors.grey[600],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => setState(() => _currentIndex = 2),
            color: _currentIndex == 2 ? const Color(0xFF00D4FF) : Colors.grey[600],
          ),
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () => setState(() => _currentIndex = 3),
            color: _currentIndex == 3 ? const Color(0xFF00D4FF) : Colors.grey[600],
          ),
        ],
      ) : null,
    );
  }
}
