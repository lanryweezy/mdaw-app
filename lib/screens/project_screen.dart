import 'package:flutter/material.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  List<ProjectInfo> _projects = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final projectsDir = Directory('${dir.path}/projects');
      
      if (!await projectsDir.exists()) {
        await projectsDir.create(recursive: true);
      }
      
      final files = await projectsDir.list().toList();
      final projectFiles = files.where((file) => file.path.endsWith('.json')).toList();
      
      _projects = [];
      for (final file in projectFiles) {
        try {
          final content = await File(file.path).readAsString();
          final projectData = jsonDecode(content);
          _projects.add(ProjectInfo.fromJson(projectData));
        } catch (e) {

        }
      }
      
      _projects.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    } catch (e) {

    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCurrentProject() async {
    final viewModel = Provider.of<DawViewModel>(context, listen: false);
    final projectName = await _showProjectNameDialog();
    if (projectName == null || projectName.isEmpty) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final projectsDir = Directory('${dir.path}/projects');
      if (!await projectsDir.exists()) {
        await projectsDir.create(recursive: true);
      }

      final projectData = {
        'name': projectName,
        'createdAt': DateTime.now().toIso8601String(),
        'lastModified': DateTime.now().toIso8601String(),
        'beatTrack': {
          'clips': viewModel.beatTrack.clips.map((clip) => {
            'path': clip.path,
            'volume': clip.volume,
            'startTime': clip.startTime.inMilliseconds,
            'endTime': clip.endTime.inMilliseconds,
          }).toList(),
        },
        'vocalTracks': viewModel.vocalTracks.map((track) => {
          'id': track.id,
          'name': track.name,
          'isMuted': track.muted,
          'isSolo': track.soloed,
          'clips': track.clips.map((clip) => {
            'path': clip.path,
            'volume': clip.volume,
            'startTime': clip.startTime.inMilliseconds,
            'endTime': clip.endTime.inMilliseconds,
          }).toList(),
        }).toList(),
      };

      final projectFile = File('${projectsDir.path}/${projectName.replaceAll(' ', '_')}.json');
      await projectFile.writeAsString(jsonEncode(projectData));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project "$projectName" saved successfully!')),
      );
      
      _loadProjects();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving project: $e')),
      );
    }
  }

  Future<String?> _showProjectNameDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Project'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Project Name',
            hintText: 'Enter project name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadProject(ProjectInfo project) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final projectFile = File('${dir.path}/projects/${project.name.replaceAll(' ', '_')}.json');
      final content = await projectFile.readAsString();
      final projectData = jsonDecode(content);
      
      final viewModel = Provider.of<DawViewModel>(context, listen: false);
      
      // Clear current project
      viewModel.clearProject();
      
      // Load beat track
      if (projectData['beatTrack'] != null) {
        final beatData = projectData['beatTrack'];
        for (final clipData in beatData['clips']) {
          await viewModel.importAudioFromPath(viewModel.beatTrack, clipData['path']);
        }
      }
      
      // Load vocal tracks
      if (projectData['vocalTracks'] != null) {
        for (final trackData in projectData['vocalTracks']) {
          final track = viewModel.vocalTracks.firstWhere(
            (t) => t.id == trackData['id'],
            orElse: () => viewModel.vocalTracks.first,
          );
          
          track.muted = trackData['isMuted'] ?? false;
          track.soloed = trackData['isSolo'] ?? false;
          
          for (final clipData in trackData['clips']) {
            await viewModel.importAudioFromPath(track, clipData['path']);
          }
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project "${project.name}" loaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading project: $e')),
      );
    }
  }

  Future<void> _deleteProject(ProjectInfo project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final projectFile = File('${dir.path}/projects/${project.name.replaceAll(' ', '_')}.json');
        await projectFile.delete();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project "${project.name}" deleted!')),
        );
        
        _loadProjects();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting project: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No projects found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first project in the Studio',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProjects,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _projects.length,
                    itemBuilder: (context, index) {
                      final project = _projects[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.music_note, color: Colors.white),
                          ),
                          title: Text(
                            project.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Modified: ${_formatDate(project.lastModified)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'load',
                                child: Row(
                                  children: [
                                    Icon(Icons.play_arrow),
                                    SizedBox(width: 8),
                                    Text('Load'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'load') {
                                _loadProject(project);
                              } else if (value == 'delete') {
                                _deleteProject(project);
                              }
                            },
                          ),
                          onTap: () => _loadProject(project),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveCurrentProject,
        icon: const Icon(Icons.save),
        label: const Text('Save Current'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class ProjectInfo {
  final String name;
  final DateTime createdAt;
  final DateTime lastModified;

  ProjectInfo({
    required this.name,
    required this.createdAt,
    required this.lastModified,
  });

  factory ProjectInfo.fromJson(Map<String, dynamic> json) {
    return ProjectInfo(
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: DateTime.parse(json['lastModified']),
    );
  }
}
