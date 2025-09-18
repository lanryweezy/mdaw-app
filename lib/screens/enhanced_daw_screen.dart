import 'package:flutter/material.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:studio_wiz/view_models/timeline_view_model.dart';
import 'package:studio_wiz/widgets/timeline_editor.dart';
import 'package:studio_wiz/widgets/advanced_controls_panel.dart';
import 'package:studio_wiz/services/audio_processing_service.dart';
import 'package:studio_wiz/widgets/processing_indicator.dart';
import 'package:studio_wiz/widgets/enhanced_daw_ui.dart';
import 'package:studio_wiz/widgets/collapsible_track_widget.dart';
import 'package:studio_wiz/models/track.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

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
    _timelineViewModel = TimelineViewModel(Provider.of<DawViewModel>(context, listen: false));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timelineViewModel.dispose();
    super.dispose();
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
    return Column(
      children: [
        // Tempo and time signature controls
        _buildTempoControls(),
        const Divider(height: 1),
        // Timeline editor
        const Expanded(child: TimelineEditor()),
      ],
    );
  }

  Widget _buildTempoControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey[700]!, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Added to shrink-wrap vertically
        children: [
          // Main tempo and time signature row - Fixed layout
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min, // Added to shrink-wrap horizontally
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
                          final currentBpm = _timelineViewModel.bpm;
                          _timelineViewModel.setBpm(currentBpm - 1);
                        },
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                      Consumer<TimelineViewModel>(
                        builder: (context, timelineVM, child) {
                          return Container(
                            width: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[600]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${timelineVM.bpm}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () {
                          final currentBpm = _timelineViewModel.bpm;
                          _timelineViewModel.setBpm(currentBpm + 1);
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
                  Consumer<TimelineViewModel>(
                    builder: (context, timelineVM, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<int>(
                            value: timelineVM.timeSignatureNumerator,
                            items: [4, 3, 2].map((num) {
                              return DropdownMenuItem(
                                value: num,
                                child: Text('$num', style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                timelineVM.setTimeSignature(value, timelineVM.timeSignatureDenominator);
                              }
                            },
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Text('/', style: TextStyle(fontSize: 12)),
                          DropdownButton<int>(
                            value: timelineVM.timeSignatureDenominator,
                            items: [4, 8].map((den) {
                              return DropdownMenuItem(
                                value: den,
                                child: Text('$den', style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                timelineVM.setTimeSignature(timelineVM.timeSignatureNumerator, value);
                              }
                            },
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Snap to grid toggle
              Consumer<TimelineViewModel>(
                builder: (context, timelineVM, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Snap', style: TextStyle(fontSize: 12)),
                      Switch(
                        value: timelineVM.snapToGrid,
                        onChanged: (value) => timelineVM.toggleSnapToGrid(),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          ),
      // Professional editing controls - Icon only for better UI
      Spacer(), // Replaced SizedBox with Spacer
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(
            icon: Icons.zoom_in,
            tooltip: 'Zoom In',
            onPressed: () {
              // Zoom in timeline
              final timelineVM = Provider.of<TimelineViewModel>(context, listen: false);
              timelineVM.zoomIn();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Zoomed in')),
              );
            },
          ),
          _buildIconButton(
            icon: Icons.zoom_out,
            tooltip: 'Zoom Out',
            onPressed: () {
              // Zoom out timeline
              final timelineVM = Provider.of<TimelineViewModel>(context, listen: false);
              timelineVM.zoomOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Zoomed out')),
              );
            },
          ),
          _buildIconButton(
            icon: Icons.center_focus_strong,
            tooltip: 'Fit to Screen',
            onPressed: () {
              // Fit timeline to screen
              final timelineVM = Provider.of<TimelineViewModel>(context, listen: false);
              timelineVM.fitToScreen();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fit to screen')),
              );
            },
          ),
          _buildIconButton(
            icon: Icons.content_copy,
            tooltip: 'Duplicate',
            onPressed: () {
              // Duplicate selected clip
              final timelineVM = Provider.of<TimelineViewModel>(context, listen: false);
              timelineVM.duplicateSelectedClip();
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
            _buildAdvancedAITool(
              'Vocal Doubling',
              'Create artificial vocal doubles for a thicker sound',
              Icons.people,
              () => _applyVocalDoubling(),
            ),
            const SizedBox(height: 12),
            _buildAdvancedAITool(
              'Harmonizer',
              'Generate vocal harmonies automatically',
              Icons.music_note,
              () => _applyHarmonizer(),
            ),
            const SizedBox(height: 12),
            _buildAdvancedAITool(
              'De-Reverb',
              'Remove unwanted room reverb from vocals',
              Icons.cleaning_services,
              () => _applyDeReverb(),
            ),

            const SizedBox(height: 12),
            _buildAdvancedAITool(
              'Rap Processing',
              'Specialized processing for rap vocals',
              Icons.mic,
              () => _applyRapProcessing(),
            ),
            const SizedBox(height: 12),
            _buildAdvancedAITool(
              'Trap Processing',
              'Aggressive processing for trap vocals',
              Icons.volume_up,
              () => _applyTrapProcessing(),
            ),
            const SizedBox(height: 12),
            _buildAdvancedAITool(
              'Afrobeat Processing',
              'Warm processing for afrobeat vocals',
              Icons.music_note,
              () => _applyAfrobeatProcessing(),
            ),
            const SizedBox(height: 12),
            _buildAdvancedAITool(
              'Drill Processing',
              'Extreme processing for drill vocals',
              Icons.flash_on,
              () => _applyDrillProcessing(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedAITool(String title, String description, IconData icon, VoidCallback onPressed) {
    return Consumer<DawViewModel>(
      builder: (context, viewModel, child) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(description),
          trailing: ElevatedButton(
            onPressed: viewModel.isProcessing ? null : onPressed,
            child: viewModel.isProcessing 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Apply'),
          ),
        );
      },
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
    final audioService = AudioProcessingService();
    
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
    
    final mixedPath = await audioService.applyVocalEffects(vocalPaths, preset: _selectedVocalPreset);
    
    if (mixedPath != null) {
      // Add to mixed vocal track
      await dawVM.importAudioFromPath(
        dawVM.mixedVocalTrack ?? (dawVM.mixedVocalTrack = Track(
          id: 'mixed_vocals', 
          name: 'Mixed Vocals',
          type: TrackType.mixed,
        )),
        mixedPath,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vocal mixing applied with ${_getPresetDisplayName(_selectedVocalPreset)} preset!')),
        );
      }
    }
  }

  Future<void> _applyMastering() async {
    final dawVM = Provider.of<DawViewModel>(context, listen: false);
    await dawVM.aiMasterSong();
    
    if (mounted) {
      ProcessingSnackbar.show(
        context,
        'Mastering applied successfully!',
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
