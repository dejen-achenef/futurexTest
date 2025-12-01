import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/video_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/retry_widget.dart';

class VideoDetailsScreen extends ConsumerStatefulWidget {
  final int videoId;

  const VideoDetailsScreen({super.key, required this.videoId});

  @override
  ConsumerState<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends ConsumerState<VideoDetailsScreen> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    // Always load the video when screen initializes
    // Use postFrameCallback to ensure the widget is built first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear any previous video and load the new one
      ref.read(videoProvider.notifier).loadVideoById(widget.videoId);
    });
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  void _initializePlayer(String videoId) {
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  void _handleDelete(BuildContext context, int videoId, int currentUserId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Video', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to permanently delete this video? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(videoProvider.notifier).deleteVideo(videoId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Video deleted successfully'),
                    ],
                  ),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleHide(BuildContext context, int videoId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hide Video', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Hide this video from your feed? Other users will still be able to see it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(videoProvider.notifier).hideVideo(videoId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.visibility_off, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Video hidden from your feed'),
                    ],
                  ),
                  backgroundColor: Colors.orange[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Hide', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.user;
    final videoState = ref.watch(videoProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.9 * 255).round()),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              actions: [
                if (videoState.currentVideo != null)
                  Builder(
                    builder: (context) {
                      final video = videoState.currentVideo!;
                      final isOwner = currentUser != null && currentUser.id == video.userId;
                      
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha((0.9 * 255).round()),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.visibility_off, color: Colors.orange.shade700),
                              onPressed: () => _handleHide(context, video.id),
                              tooltip: 'Hide video',
                            ),
                          ),
                          if (isOwner)
                            Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha((0.9 * 255).round()),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red.shade700),
                                onPressed: () => _handleDelete(context, video.id, currentUser.id),
                                tooltip: 'Delete video',
                              ),
                            ),
                        ],
                      );
                    },
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: videoState.currentVideo != null
                    ? Hero(
                        tag: 'video_${videoState.currentVideo!.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.blue.shade600,
                                Colors.purple.shade600,
                              ],
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            // Content
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  // Show loading if currently loading
                  if (videoState.isLoading) {
                    return const SizedBox(
                      height: 400,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  // Show error if there's an error and no video loaded
                  if (videoState.error != null && videoState.currentVideo == null) {
                    return SizedBox(
                      height: 400,
                      child: RetryWidget(
                        message: videoState.error!,
                        onRetry: () {
                          ref.read(videoProvider.notifier).loadVideoById(widget.videoId);
                        },
                      ),
                    );
                  } else if (videoState.currentVideo != null) {
                    // Verify we have the correct video
                    if (videoState.currentVideo!.id != widget.videoId) {
                      // Video ID mismatch, reload
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref.read(videoProvider.notifier).loadVideoById(widget.videoId);
                      });
                      return const SizedBox(
                        height: 400,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  final video = videoState.currentVideo!;

                  if (_youtubeController == null ||
                      _youtubeController!.initialVideoId != video.youtubeVideoId) {
                    _initializePlayer(video.youtubeVideoId);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Player
                      Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.2 * 255).round()),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: kIsWeb
                              ? AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.network(
                                        video.thumbnailUrl,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withAlpha((0.5 * 255).round()),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.play_circle_filled,
                                            size: 64,
                                            color: Colors.white,
                                          ),
                                          onPressed: () async {
                                            final url = Uri.parse('https://www.youtube.com/watch?v=${video.youtubeVideoId}');
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url, mode: LaunchMode.externalApplication);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: YoutubePlayer(
                                    controller: _youtubeController!,
                                    showVideoProgressIndicator: true,
                                    progressIndicatorColor: Colors.blue.shade600,
                                  ),
                                ),
                        ),
                      ),
                      // Video Info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade400,
                                        Colors.purple.shade400,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    video.category,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (video.duration != null) ...[
                                  const SizedBox(width: 12),
                                  Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    video.durationFormatted,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (video.description != null && video.description!.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha((0.05 * 255).round()),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  video.description!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                            if (video.user != null) ...[
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha((0.05 * 255).round()),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage: video.user!.avatar != null
                                          ? NetworkImage(video.user!.avatar!)
                                          : null,
                                      child: video.user!.avatar == null
                                          ? Icon(Icons.person, color: Colors.grey[600])
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Uploaded by',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            video.user!.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
