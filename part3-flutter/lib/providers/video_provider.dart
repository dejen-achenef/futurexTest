import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video.dart';
import '../services/api_service.dart';
import 'services_provider.dart';

// Video State
class VideoState {
  final List<Video> videos;
  final Video? currentVideo;
  final bool isLoading;
  final String? error;
  final String? currentSearch;
  final String? currentCategory;

  const VideoState({
    this.videos = const [],
    this.currentVideo,
    this.isLoading = false,
    this.error,
    this.currentSearch,
    this.currentCategory,
  });

  VideoState copyWith({
    List<Video>? videos,
    Video? currentVideo,
    bool? isLoading,
    String? error,
    String? currentSearch,
    String? currentCategory,
  }) {
    return VideoState(
      videos: videos ?? this.videos,
      currentVideo: currentVideo ?? this.currentVideo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentSearch: currentSearch ?? this.currentSearch,
      currentCategory: currentCategory ?? this.currentCategory,
    );
  }
}

// Video Notifier
class VideoNotifier extends StateNotifier<VideoState> {
  final ApiService _apiService;

  VideoNotifier(this._apiService) : super(const VideoState());

  Future<void> loadVideos({String? search, String? category}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final videos = await _apiService.getVideos(
        search: search,
        category: category,
      );
      state = state.copyWith(
        videos: videos,
        isLoading: false,
        currentSearch: search,
        currentCategory: category,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refreshVideos({String? search, String? category}) async {
    try {
      final videos = await _apiService.getVideos(
        search: search,
        category: category,
      );
      state = state.copyWith(
        videos: videos,
        currentSearch: search,
        currentCategory: category,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadVideoById(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final video = await _apiService.getVideoById(id);
      state = state.copyWith(
        currentVideo: video,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> deleteVideo(int id) async {
    try {
      await _apiService.deleteVideo(id);
      // Reload videos with current filters
      await loadVideos(
        search: state.currentSearch,
        category: state.currentCategory,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> hideVideo(int id) async {
    try {
      await _apiService.hideVideo(id);
      // Reload videos with current filters
      await loadVideos(
        search: state.currentSearch,
        category: state.currentCategory,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> unhideVideo(int id) async {
    try {
      await _apiService.unhideVideo(id);
      // Reload videos with current filters
      await loadVideos(
        search: state.currentSearch,
        category: state.currentCategory,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

// Video Provider
final videoProvider = StateNotifierProvider<VideoNotifier, VideoState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return VideoNotifier(apiService);
});

