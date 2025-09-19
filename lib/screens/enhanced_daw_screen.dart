import 'package:flutter/material.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:studio_wiz/view_models/timeline_view_model.dart';
import 'package:studio_wiz/widgets/timeline_editor.dart';
import 'package:studio_wiz/widgets/advanced_controls_panel.dart';
import 'package:studio_wiz/services/audio_processing_service.dart';
import 'package:studio_wiz/widgets/processing_indicator.dart';
import 'package:studio_wiz/widgets/collapsible_track_widget.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:studio_wiz/widgets/tempo_controls.dart';
import 'package:studio_wiz/widgets/ai_tool_button.dart';

class EnhancedDawScreen extends StatefulWidget {
  const EnhancedDawScreen({super.key});

  @override
  State<EnhancedDawScreen> createState() => _EnhancedDawScreenState();
}

class _EnhancedDawScreenState extends State<EnhancedDawScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late TimelineViewModel _timelineViewModel;
  
  // AI Processing state
  VocalMixPreset _selectedVocalPreset = VocalMixPreset.pop;
  MasteringPreset _selectedMasteringPreset = MasteringPreset.loudAndClear;
  bool _isTransportVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final dawViewModel = Provider.of<DawViewModel>(context, listen: false);
    _timelineViewModel = TimelineViewModel(dawViewModel);
    dawViewModel.addListener(_handleDawViewModelChanges);
  }

  @override
  void dispose() {
    Provider.of<DawViewModel>(context, listen: false).removeListener(_handleDawViewModelChanges);
    _tabController.dispose();
    _timelineViewModel.dispose();
    super.dispose();
  }

  void _handleDawViewModelChanges() {
    final dawViewModel = Provider.of<DawViewModel>(context, listen: false);
    if (dawViewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dawViewModel.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
      dawViewModel.clearErrorMessage();
    }
  }


  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _timelineViewModel),
      ],
      child: Consumer<DawViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              Scaffold(
                appBar: isLandscape ? null : AppBar(
                  title: const Text('ProStudio DAW'),
                  centerTitle: true,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.timeline, size: 20),
                          text: 'Timeline',
                          height: 48,
                        ),
                        Tab(
                          icon: Icon(Icons.equalizer, size: 20),
                          text: 'Mix',
                          height: 48,
                        ),
                        Tab(
                          icon: Icon(Icons.auto_awesome, size: 20),
                          text: 'AI Tools',
                          height: 48,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () {
                        final dawViewModel = Provider.of<DawViewModel>(context, listen: false);
                        dawViewModel.addVocalTrack();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added new vocal track')),
                        );
                      },
                      tooltip: 'Add Track',
                    ),
                    IconButton(
                      icon: const Icon(Icons.audio_file, size: 20),
                      onPressed: () {
                        final dawViewModel = Provider.of<DawViewModel>(context, listen: false);
                        dawViewModel.importAudio(dawViewModel.beatTrack);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Importing audio to beat track...')),
                        );
                      },
                      tooltip: 'Import Audio',
                    ),
                    // Responsive actions based on screen size
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWideScreen = constraints.maxWidth > 600;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Undo/Redo buttons
                            Consumer<TimelineViewModel>(
                              builder: (context, timelineVM, child) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.undo, size: 20),
                                      onPressed: timelineVM.canUndo ? timelineVM.undo : null,
                                      tooltip: 'Undo',
                                      padding: const EdgeInsets.all(8),
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.redo, size: 20),
                                      onPressed: timelineVM.canRedo ? timelineVM.redo : null,
                                      tooltip: 'Redo',
                                      padding: const EdgeInsets.all(8),
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                  ],
                                );
                              },
                            ),
                            // Metronome toggle
                            Consumer<TimelineViewModel>(
                              builder: (context, timelineVM, child) {
                                return IconButton(
                                  icon: Icon(
                                    timelineVM.metronomeEnabled ? Icons.music_note : Icons.music_off,
                                    color: timelineVM.metronomeEnabled ? Colors.red : null,
                                    size: 20,
                                  ),
                                  onPressed: timelineVM.toggleMetronome,
                                  tooltip: 'Metronome',
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Landscape tab bar
                    if (isLandscape) Container(
                      color: const Color(0xFF1A1A1A),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: const Color(0xFF00D4FF),
                        unselectedLabelColor: Colors.grey[600],
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.timeline, size: 18),
                            text: 'Timeline',
                            height: 36,
                          ),
                          Tab(
                            icon: Icon(Icons.equalizer, size: 18),
                            text: 'Mix',
                            height: 36,
                          ),
                          Tab(
                            icon: Icon(Icons.auto_awesome, size: 18),
                            text: 'AI Tools',
                            height: 36,
                          ),
                        ],
                      ),
                    ),
                    // Main content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTimelineTab(),
                          _buildMixTab(),
                          _buildAIToolsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _isTransportVisible ? 100 : 0, // Increased height to accommodate responsive buttons
                  child: _isTransportVisible ? _buildTransportControls() : null,
                ),
                // Floating action button to show transport when hidden
                floatingActionButton: !_isTransportVisible ? FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF00D4FF),
                  onPressed: () => setState(() => _isTransportVisible = true),
                  child: const Icon(Icons.play_arrow, color: Colors.black),
                ) : null,
              ),
              if (viewModel.isProcessing)
                _buildProcessingOverlay(context, viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProcessingOverlay(BuildContext context, DawViewModel viewModel) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: ProcessingDialog(
          operation: viewModel.currentOperation ?? 'Processing...',
          progress: viewModel.processingProgress,
          onCancel: () => viewModel.cancelProcessing(),
        ),
      ),
    );
  }

  

  Widget _buildTimelineTab() {
    return const Column(
      children: [
        // Tempo and time signature controls
        TempoControls(),
        Divider(height: 1),
        // Timeline editor
        Expanded(child: TimelineEditor()),
      ],
    );
  }

  Widget _buildMixTab() {
    return const AdvancedControlsPanel();
  }

  Widget _buildAIToolsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVocalMixSection(),
          const SizedBox(height: 24),
          _buildMasteringSection(),
          const SizedBox(height: 24),
          _buildAdvancedAISection(),
        ],
      ),
    );
  }

  Widget _buildVocalMixSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Vocal Mixing',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose a vocal mixing preset:'),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: VocalMixPreset.values.length,
                itemBuilder: (context, index) {
                  final preset = VocalMixPreset.values[index];
                  final isSelected = _selectedVocalPreset == preset;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        _getPresetDisplayName(preset),
                        style: TextStyle(fontSize: 12),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedVocalPreset = preset);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Consumer<DawViewModel>(
                builder: (context, viewModel, child) {
                  return ElevatedButton.icon(
                    onPressed: viewModel.isProcessing ? null : _applyVocalMixing,
                    icon: viewModel.isProcessing 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                    label: Text(viewModel.isProcessing ? 'Processing...' : 'Apply AI Vocal Mix'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasteringSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Mastering',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose a mastering preset:'),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: MasteringPreset.values.length,
                itemBuilder: (context, index) {
                  final preset = MasteringPreset.values[index];
                  final isSelected = _selectedMasteringPreset == preset;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        _getMasteringPresetDisplayName(preset),
                        style: TextStyle(fontSize: 12),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedMasteringPreset = preset);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Consumer<DawViewModel>(
                builder: (context, viewModel, child) {
                  return ElevatedButton.icon(
                    onPressed: viewModel.isProcessing ? null : _applyMastering,
                    icon: viewModel.isProcessing 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.star),
                    label: Text(viewModel.isProcessing ? 'Processing...' : 'Apply AI Mastering'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      foregroundColor: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedAISection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced AI Tools',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AIToolButton(
              title: 'Vocal Doubling',
              description: 'Create artificial vocal doubles for a thicker sound',
              icon: Icons.people,
              onPressed: () => _applyVocalDoubling(),
            ),
            const SizedBox(height: 12),
            AIToolButton(
              title: 'Harmonizer',
              description: 'Generate vocal harmonies automatically',
              icon: Icons.music_note,
              onPressed: () => _applyHarmonizer(),
            ),
            const SizedBox(height: 12),
            AIToolButton(
              title: 'De-Reverb',
              description: 'Remove unwanted room reverb from vocals',
              icon: Icons.cleaning_services,
              onPressed: () => _applyDeReverb(),
            ),
            const SizedBox(height: 12),
            AIToolButton(
              title: 'Rap Processing',
              description: 'Specialized processing for rap vocals',
              icon: Icons.mic,
              onPressed: () => _applyRapProcessing(),
            ),
            const SizedBox(height: 12),
            AIToolButton(
              title: 'Trap Processing',
              description: 'Aggressive processing for trap vocals',
              icon: Icons.volume_up,
              onPressed: () => _applyTrapProcessing(),
            ),
            const SizedBox(height: 12),
            AIToolButton(
              title: 'Afrobeat Processing',
              description: 'Warm processing for afrobeat vocals',
              icon: Icons.music_note,
              onPressed: () => _applyAfrobeatProcessing(),
            ),
            const SizedBox(height: 12),
            AIToolButton(
              title: 'Drill Processing',
              description: 'Extreme processing for drill vocals',
              icon: Icons.flash_on,
              onPressed: () => _applyDrillProcessing(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
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

  Widget _buildTransportControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey[700]!, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Collapse button
            SizedBox(
              height: 20,
              child: Center(
                child: GestureDetector(
                  onTap: () => setState(() => _isTransportVisible = false),
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
            // Transport buttons
            SizedBox(
              height: 56, // Explicitly set height to fit within 100 (100 - 20 - 12 - 12 = 56)
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Stop
                  _buildTransportButton(
                    icon: Icons.stop,
                    onPressed: () {
                      Provider.of<DawViewModel>(context, listen: false).stop();
                    },
                  ),
                  // Play/Pause
                  Consumer<DawViewModel>(
                    builder: (context, dawVM, child) {
                      return _buildTransportButton(
                        icon: dawVM.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        isPrimary: true,
                        onPressed: dawVM.isPlaying ? dawVM.pause : dawVM.play,
                      );
                    },
                  ),
                  // Record
                  Consumer<DawViewModel>(
                    builder: (context, dawVM, child) {
                      return _buildTransportButton(
                        icon: dawVM.isRecording ? Icons.stop_circle : Icons.mic,
                        color: dawVM.isRecording ? Colors.red : null,
                        onPressed: () {
                          final emptyVocalTrack = dawVM.vocalTracks.firstWhere(
                            (track) => !track.hasAudio,
                            orElse: () => dawVM.vocalTracks.first,
                          );
                          dawVM.toggleRecording(emptyVocalTrack);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
    Color? color,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes based on available space
        final maxWidth = constraints.maxWidth > 0 ? constraints.maxWidth : 300.0;
        
        // Set minimum and maximum sizes with safe fallbacks
        final double primarySize = math.min(math.max(maxWidth * 0.3, 48.0), 56.0); // Max size adjusted to fit
        final double secondarySize = math.min(math.max(maxWidth * 0.25, 40.0), 56.0); // Max size adjusted to fit
        
        final double size = isPrimary ? primarySize : secondarySize;
        final double iconSize = size * 0.6;
        
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color ?? (isPrimary ? Theme.of(context).colorScheme.primary : Colors.grey[800]),
            borderRadius: BorderRadius.circular(size / 2),
            boxShadow: isPrimary ? [
              BoxShadow(
                color: (color ?? Theme.of(context).colorScheme.primary).withAlpha(76),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: IconButton(
            icon: Icon(
              icon,
              size: iconSize,
              color: isPrimary ? Colors.black : Colors.white,
            ),
            onPressed: onPressed,
            padding: EdgeInsets.zero,
          ),
        );
      },
    );
  }

  String _getPresetDisplayName(VocalMixPreset preset) {
    switch (preset) {
      case VocalMixPreset.pop:
        return 'Pop';
      case VocalMixPreset.rnb:
        return 'R&B';
      case VocalMixPreset.aggressive:
        return 'Aggressive';
      case VocalMixPreset.warm:
        return 'Warm';
      case VocalMixPreset.bright:
        return 'Bright';
      case VocalMixPreset.vintage:
        return 'Vintage';
      case VocalMixPreset.rap:
        return 'Rap';
      case VocalMixPreset.trap:
        return 'Trap';
      case VocalMixPreset.afrobeat:
        return 'Afrobeat';
      case VocalMixPreset.drill:
        return 'Drill';
      case VocalMixPreset.melodic:
        return 'Melodic';
      case VocalMixPreset.autotune:
        return 'Autotune';
    }
  }

  String _getMasteringPresetDisplayName(MasteringPreset preset) {
    switch (preset) {
      case MasteringPreset.loudAndClear:
        return 'Loud & Clear';
      case MasteringPreset.warmAndAnalog:
        return 'Warm & Analog';
      case MasteringPreset.punchy:
        return 'Punchy';
      case MasteringPreset.smooth:
        return 'Smooth';
      case MasteringPreset.commercial:
        return 'Commercial';
      case MasteringPreset.streaming:
        return 'Streaming';
      case MasteringPreset.rap:
        return 'Rap';
      case MasteringPreset.trap:
        return 'Trap';
      case MasteringPreset.afrobeat:
        return 'Afrobeat';
      case MasteringPreset.drill:
        return 'Drill';
      case MasteringPreset.club:
        return 'Club';
      case MasteringPreset.radio:
        return 'Radio';
    }
  }

  Future<void> _applyVocalMixing() async {
    final dawVM = Provider.of<DawViewModel>(context, listen: false);
    final vocalPaths = dawVM.vocalTracks
        .where((track) => track.hasAudio)
        .expand((track) => track.clips.map((clip) => clip.path))
        .toList();

    if (vocalPaths.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No vocal tracks to mix')),
        );
      }
      return;
    }

    final mixedPath = await dawVM.applyVocalMixing(vocalPaths, _selectedVocalPreset);

    if (mixedPath != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vocal mixing applied with ${_getPresetDisplayName(_selectedVocalPreset)} preset!')),
        );
      }
    }
  }

  Future<void> _applyMastering() async {
    final dawVM = Provider.of<DawViewModel>(context, listen: false);
    await dawVM.applyMastering(_selectedMasteringPreset);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mastering applied successfully!')),
      );
    }
  }

  Future<void> _applyVocalDoubling() async {
    final dawVM = Provider.of<DawViewModel>(context, listen: false);
    await dawVM.applyVocalDoubling();
  }

  Future<void> _applyHarmonizer() async {
    final dawVM = Provider.of<DawViewModel>(context, listen: false);
    await dawVM.applyHarmonizer();
  }

  Future<void> _applyDeReverb() async {
    final dawVM = Provider.of<DawViewModel>(context, listen: false);
    await dawVM.applyDeReverb();
  }

  Future<void> _applyRapProcessing() async {
    final dawVM = Provider.of<DawViewModel>(context, listen: false);
    await dawVM.applyRapProcessing();
  }

  Future<void> _applyTrapProcessing() async {
    final dawVM = Provider.of<DawViewModel>(context, listen: false);
    await dawVM.applyTrapProcessing();
  }

  Future<void> _applyAfrobeatProcessing() async {
    final dawVM = Provider.of<DawViewModel>(context, listen: false);
    await dawVM.applyAfrobeatProcessing();
  }

  Future<void> _applyDrillProcessing() async {
    final dawVM = Provider.of<DawViewModel>(context, listen: false);
    await dawVM.applyDrillProcessing();
  }
}

class ProcessingSnackbar {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
