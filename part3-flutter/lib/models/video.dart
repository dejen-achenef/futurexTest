import 'user.dart';

class Video {
  final int id;
  final String title;
  final String? description;
  final String youtubeVideoId;
  final String category;
  final int? duration;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  Video({
    required this.id,
    required this.title,
    this.description,
    required this.youtubeVideoId,
    required this.category,
    this.duration,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    // Handle userId in both camelCase and snake_case
    int? parsedUserId;
    if (json['userId'] != null) {
      parsedUserId = json['userId'] is int ? json['userId'] as int : int.tryParse(json['userId'].toString());
    } else if (json['user_id'] != null) {
      parsedUserId = json['user_id'] is int ? json['user_id'] as int : int.tryParse(json['user_id'].toString());
    }
    
    if (parsedUserId == null) {
      print('[Video.fromJson] Warning: userId not found in JSON: $json');
    }
    
    return Video(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      youtubeVideoId: json['youtubeVideoId'] ?? json['youtube_video_id'] as String,
      category: json['category'] as String,
      duration: json['duration'] as int?,
      userId: parsedUserId ?? 0, // Fallback to 0 if not found (shouldn't happen)
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'youtubeVideoId': youtubeVideoId,
      'category': category,
      'duration': duration,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get thumbnailUrl {
    return 'https://img.youtube.com/vi/$youtubeVideoId/mqdefault.jpg';
  }

  String get durationFormatted {
    if (duration == null) return 'N/A';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

