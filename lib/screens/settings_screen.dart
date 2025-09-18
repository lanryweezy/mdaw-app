import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _isLoading = true;
  
  // Audio Settings
  double _masterVolume = 1.0;
  int _bitDepth = 16;
  String _audioQuality = 'High (48kHz)';
  
  // Export Settings
  String _defaultExportFormat = 'WAV';
  int _exportBitrate = 320;
  bool _normalizeAudio = true;
  
  // UI Settings
  bool _darkMode = true;
  double _waveformHeight = 70.0;
  bool _showWaveforms = true;
  
  // Advanced Settings
  bool _enableLowLatency = false;
  int _bufferSize = 1024;
  bool _enableCloudSync = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _masterVolume = _prefs.getDouble('master_volume') ?? 1.0;
      _bitDepth = _prefs.getInt('bit_depth') ?? 16;
      _audioQuality = _prefs.getString('audio_quality') ?? 'High (48kHz)';
      _defaultExportFormat = _prefs.getString('export_format') ?? 'WAV';
      _exportBitrate = _prefs.getInt('export_bitrate') ?? 320;
      _normalizeAudio = _prefs.getBool('normalize_audio') ?? true;
      _darkMode = _prefs.getBool('dark_mode') ?? true;
      _waveformHeight = _prefs.getDouble('waveform_height') ?? 70.0;
      _showWaveforms = _prefs.getBool('show_waveforms') ?? true;
      _enableLowLatency = _prefs.getBool('enable_low_latency') ?? false;
      _bufferSize = _prefs.getInt('buffer_size') ?? 1024;
      _enableCloudSync = _prefs.getBool('enable_cloud_sync') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetToDefaults,
            tooltip: 'Reset to Defaults',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Audio Settings'),
          _buildSliderSetting(
            'Master Volume',
            _masterVolume,
            (value) {
              setState(() => _masterVolume = value);
              _saveSetting('master_volume', value);
            },
            min: 0.0,
            max: 1.0,
            divisions: 100,
            format: (value) => '${(value * 100).round()}%',
          ),
          _buildDropdownSetting(
            'Audio Quality',
            _audioQuality,
            ['Low (22kHz)', 'Medium (44.1kHz)', 'High (48kHz)', 'Professional (96kHz)'],
            (value) {
              setState(() => _audioQuality = value);
              _saveSetting('audio_quality', value);
            },
          ),
          _buildDropdownSetting(
            'Bit Depth',
            '$_bitDepth-bit',
            ['16-bit', '24-bit', '32-bit'],
            (value) {
              final bitDepth = int.parse(value.split('-')[0]);
              setState(() => _bitDepth = bitDepth);
              _saveSetting('bit_depth', bitDepth);
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Export Settings'),
          _buildDropdownSetting(
            'Default Export Format',
            _defaultExportFormat,
            ['WAV', 'MP3', 'AAC', 'FLAC'],
            (value) {
              setState(() => _defaultExportFormat = value);
              _saveSetting('export_format', value);
            },
          ),
          if (_defaultExportFormat == 'MP3' || _defaultExportFormat == 'AAC')
            _buildSliderSetting(
              'Export Bitrate (kbps)',
              _exportBitrate.toDouble(),
              (value) {
                setState(() => _exportBitrate = value.round());
                _saveSetting('export_bitrate', value.round());
              },
              min: 128,
              max: 320,
              divisions: 8,
              format: (value) => '${value.round()} kbps',
            ),
          _buildSwitchSetting(
            'Normalize Audio',
            _normalizeAudio,
            (value) {
              setState(() => _normalizeAudio = value);
              _saveSetting('normalize_audio', value);
            },
            subtitle: 'Automatically adjust volume levels',
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Interface Settings'),
          _buildSwitchSetting(
            'Dark Mode',
            _darkMode,
            (value) {
              setState(() => _darkMode = value);
              _saveSetting('dark_mode', value);
            },
            subtitle: 'Use dark theme (requires app restart)',
          ),
          _buildSliderSetting(
            'Waveform Height',
            _waveformHeight,
            (value) {
              setState(() => _waveformHeight = value);
              _saveSetting('waveform_height', value);
            },
            min: 40.0,
            max: 120.0,
            divisions: 8,
            format: (value) => '${value.round()}px',
          ),
          _buildSwitchSetting(
            'Show Waveforms',
            _showWaveforms,
            (value) {
              setState(() => _showWaveforms = value);
              _saveSetting('show_waveforms', value);
            },
            subtitle: 'Display audio waveforms in tracks',
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Advanced Settings'),
          _buildSwitchSetting(
            'Low Latency Mode',
            _enableLowLatency,
            (value) {
              setState(() => _enableLowLatency = value);
              _saveSetting('enable_low_latency', value);
            },
            subtitle: 'Reduce audio delay (may affect stability)',
          ),
          _buildDropdownSetting(
            'Buffer Size',
            '$_bufferSize samples',
            ['512 samples', '1024 samples', '2048 samples', '4096 samples'],
            (value) {
              final bufferSize = int.parse(value.split(' ')[0]);
              setState(() => _bufferSize = bufferSize);
              _saveSetting('buffer_size', bufferSize);
            },
          ),
          _buildSwitchSetting(
            'Cloud Sync',
            _enableCloudSync,
            (value) {
              setState(() => _enableCloudSync = value);
              _saveSetting('enable_cloud_sync', value);
            },
            subtitle: 'Sync projects to cloud (Premium feature)',
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          _buildInfoCard(),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    double value,
    ValueChanged<double> onChanged, {
    required double min,
    required double max,
    required int divisions,
    required String Function(double) format,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(format(value), style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            Slider(
              value: value,
              onChanged: onChanged,
              min: min,
              max: max,
              divisions: divisions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSetting(
    String title,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            DropdownButton<String>(
              value: value,
              onChanged: (newValue) => onChanged(newValue!),
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    String? subtitle,
  }) {
    return Card(
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey[600])) : null,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ProStudio DAW',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Professional Digital Audio Workstation for mobile devices. Create, mix, and master your music with AI-powered tools.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Implement rate app functionality
                    _rateApp();
                  },
                  icon: const Icon(Icons.star),
                  label: const Text('Rate App'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Implement feedback functionality
                    _provideFeedback();
                  },
                  icon: const Icon(Icons.feedback),
                  label: const Text('Feedback'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _prefs.clear();
      _loadSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings reset to defaults')),
      );
    }
  }

  Future<void> _rateApp() async {
    // Try to open the app store rating page
    // For now, we'll use a generic approach that works on multiple platforms
    try {
      // Attempt to open the app's store page
      // Note: In a real app, you would use your actual app ID
      final Uri appStoreUri;
      
      if (Platform.isAndroid) {
        // For Android, use Google Play Store
        appStoreUri = Uri.parse('https://play.google.com/store/apps/details?id=com.example.mdaw');
      } else if (Platform.isIOS) {
        // For iOS, use App Store
        appStoreUri = Uri.parse('https://apps.apple.com/app/idYOUR_APP_ID');
      } else {
        // For other platforms, use a generic feedback page
        appStoreUri = Uri.parse('https://example.com');
      }
      
      if (await canLaunchUrl(appStoreUri)) {
        await launchUrl(appStoreUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open app store')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening app store')),
        );
      }

    }
  }

  Future<void> _provideFeedback() async {
    // Open email client with pre-filled feedback email
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'feedback@prostudio.app',
        queryParameters: {
          'subject': 'ProStudio DAW Feedback',
          'body': 'Please share your feedback, suggestions, or report any issues:\n\n\n\nApp Version: 1.0.0\nPlatform: ${Platform.operatingSystem}\n',
        },
      );
      
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Fallback to opening a generic feedback page
        final Uri feedbackUri = Uri.parse('https://example.com/feedback');
        if (await canLaunchUrl(feedbackUri)) {
          await launchUrl(feedbackUri);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open feedback form')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening feedback form')),
        );
      }

    }
  }
}
