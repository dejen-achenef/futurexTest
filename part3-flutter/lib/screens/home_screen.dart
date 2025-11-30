import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/video/video_bloc.dart';
import '../bloc/video/video_event.dart';
import '../bloc/video/video_state.dart';
import '../models/video.dart';
import 'video_details_screen.dart';
import 'profile_screen.dart';
import '../widgets/retry_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    // Load videos - categories will be extracted from the loaded videos
    context.read<VideoBloc>().add(const LoadVideos());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadVideos() {
    context.read<VideoBloc>().add(
          LoadVideos(
            search: _searchController.text.isEmpty
                ? null
                : _searchController.text,
            category: _selectedCategory,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: user.id),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search videos',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadVideos();
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _loadVideos(),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('All', null),
                      const SizedBox(width: 8),
                      ..._categories.map((cat) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _buildCategoryChip(cat, cat),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<VideoBloc, VideoState>(
              builder: (context, state) {
                if (state is VideoLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is VideoError) {
                  return RetryWidget(
                    message: state.message,
                    onRetry: _loadVideos,
                  );
                } else if (state is VideosLoaded) {
                  if (state.videos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_library_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No videos found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  // Always update categories from ALL videos, not just filtered ones
                  // We'll merge categories from current videos with existing ones
                  final newCategories = state.videos
                      .map((v) => v.category)
                      .toSet();
                  
                  // Merge with existing categories to keep all categories visible
                  final allCategories = {..._categories, ...newCategories}.toList()..sort();
                  
                  if (allCategories.length != _categories.length || 
                      !allCategories.every((cat) => _categories.contains(cat))) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _categories.clear();
                        _categories.addAll(allCategories);
                      });
                    });
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<VideoBloc>().add(
                            RefreshVideos(
                              search: _searchController.text.isEmpty
                                  ? null
                                  : _searchController.text,
                              category: _selectedCategory,
                            ),
                          );
                    },
                    child: ListView.builder(
                      itemCount: state.videos.length,
                      itemBuilder: (context, index) {
                        final video = state.videos[index];
                        return _VideoCard(
                          video: video,
                          onVideoTapped: () => _loadVideos(),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadVideos,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
        _loadVideos();
      },
    );
  }
}

class _VideoCard extends StatelessWidget {
  final Video video;
  final VoidCallback onVideoTapped;

  const _VideoCard({required this.video, required this.onVideoTapped});

  void _handleDelete(BuildContext context, int currentUserId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Video'),
        content: Text('Are you sure you want to permanently delete "${video.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<VideoBloc>().add(DeleteVideo(video.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video deleted successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleHide(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hide Video'),
        content: Text('Hide "${video.title}" from your feed? Other users will still be able to see it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<VideoBloc>().add(HideVideo(video.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video hidden from your feed')),
              );
            },
            child: const Text('Hide'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    
    // Debug: Print ownership check
    if (currentUser != null) {
      print('[VideoCard] Current User ID: ${currentUser.id}, Video User ID: ${video.userId}, Is Owner: ${currentUser.id == video.userId}');
    }
    
    final isOwner = currentUser != null && currentUser.id == video.userId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () async {
          // Navigate to video details and reload videos when returning
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoDetailsScreen(videoId: video.id),
            ),
          );
          // Reload videos with current filters when returning
          onVideoTapped();
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: video.thumbnailUrl,
                  width: 120,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 120,
                    height: 90,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 120,
                    height: 90,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    if (video.duration != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Duration: ${video.durationFormatted}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Hide button - available for all videos
              IconButton(
                icon: const Icon(Icons.visibility_off, color: Colors.orange, size: 22),
                onPressed: () => _handleHide(context),
                tooltip: 'Hide video',
              ),
              // Delete button - only for own videos
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                  onPressed: () => _handleDelete(context, currentUser.id),
                  tooltip: 'Delete video permanently',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

