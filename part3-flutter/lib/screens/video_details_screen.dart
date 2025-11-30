import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/video/video_bloc.dart';
import '../bloc/video/video_event.dart';
import '../bloc/video/video_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../widgets/retry_widget.dart';

class VideoDetailsScreen extends StatefulWidget {
  final int videoId;

  const VideoDetailsScreen({super.key, required this.videoId});

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    context.read<VideoBloc>().add(LoadVideoById(widget.videoId));
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
        title: const Text('Delete Video'),
        content: const Text('Are you sure you want to permanently delete this video? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<VideoBloc>().add(DeleteVideo(videoId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video deleted successfully')),
              );
              Navigator.pop(context); // Go back to home screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleHide(BuildContext context, int videoId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hide Video'),
        content: const Text('Hide this video from your feed? Other users will still be able to see it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<VideoBloc>().add(HideVideo(videoId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video hidden from your feed')),
              );
              Navigator.pop(context); // Go back to home screen
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Details'),
        actions: [
          BlocBuilder<VideoBloc, VideoState>(
            builder: (context, videoState) {
              if (videoState is VideoLoaded) {
                final video = videoState.video;
                final isOwner = currentUser != null && currentUser.id == video.userId;
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hide button - available for all videos
                    IconButton(
                      icon: const Icon(Icons.visibility_off, color: Colors.orange, size: 22),
                      onPressed: () => _handleHide(context, video.id),
                      tooltip: 'Hide video',
                    ),
                    // Delete button - only for own videos
                    if (isOwner)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                        onPressed: () => _handleDelete(context, video.id, currentUser.id),
                        tooltip: 'Delete video permanently',
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          if (state is VideoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VideoError) {
            return RetryWidget(
              message: state.message,
              onRetry: () {
                context.read<VideoBloc>().add(LoadVideoById(widget.videoId));
              },
            );
          } else if (state is VideoLoaded) {
            final video = state.video;

            // Initialize player if not already initialized
            if (_youtubeController == null ||
                _youtubeController!.initialVideoId != video.youtubeVideoId) {
              _initializePlayer(video.youtubeVideoId);
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // YouTube Player - Use thumbnail with link for web, native player for mobile
                  if (kIsWeb)
                    // Web: Show thumbnail with play button
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            video.thumbnailUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.video_library, size: 64),
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
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
                  else
                    // Mobile: Use native YouTube player
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: YoutubePlayer(
                        controller: _youtubeController!,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  // Video Info
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                video.category,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (video.duration != null) ...[
                              const SizedBox(width: 12),
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
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
                        if (video.description != null &&
                            video.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            video.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                        if (video.user != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey[300],
                                child: video.user!.avatar != null
                                    ? ClipOval(
                                        child: Image.network(
                                          video.user!.avatar!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              color: Colors.grey[600],
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        color: Colors.grey[600],
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                video.user!.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

