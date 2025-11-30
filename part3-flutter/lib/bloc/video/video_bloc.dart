import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import 'video_event.dart';
import 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final ApiService apiService;

  VideoBloc(this.apiService) : super(VideoInitial()) {
    on<LoadVideos>(_onLoadVideos);
    on<RefreshVideos>(_onRefreshVideos);
    on<LoadVideoById>(_onLoadVideoById);
    on<DeleteVideo>(_onDeleteVideo);
    on<HideVideo>(_onHideVideo);
  }

  Future<void> _onLoadVideos(
    LoadVideos event,
    Emitter<VideoState> emit,
  ) async {
    emit(VideoLoading());
    try {
      final videos = await apiService.getVideos(
        search: event.search,
        category: event.category,
      );
      emit(VideosLoaded(videos, currentSearch: event.search, currentCategory: event.category));
    } catch (e) {
      emit(VideoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRefreshVideos(
    RefreshVideos event,
    Emitter<VideoState> emit,
  ) async {
    try {
      final videos = await apiService.getVideos(
        search: event.search,
        category: event.category,
      );
      emit(VideosLoaded(videos, currentSearch: event.search, currentCategory: event.category));
    } catch (e) {
      emit(VideoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadVideoById(
    LoadVideoById event,
    Emitter<VideoState> emit,
  ) async {
    emit(VideoLoading());
    try {
      final video = await apiService.getVideoById(event.id);
      emit(VideoLoaded(video));
    } catch (e) {
      emit(VideoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteVideo(
    DeleteVideo event,
    Emitter<VideoState> emit,
  ) async {
    try {
      await apiService.deleteVideo(event.id);
      // Reload videos after deletion with current filters preserved
      final currentState = state;
      String? search;
      String? category;
      if (currentState is VideosLoaded) {
        search = currentState.currentSearch;
        category = currentState.currentCategory;
      }
      final videos = await apiService.getVideos(
        search: search,
        category: category,
      );
      emit(VideosLoaded(videos, currentSearch: search, currentCategory: category));
    } catch (e) {
      emit(VideoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onHideVideo(
    HideVideo event,
    Emitter<VideoState> emit,
  ) async {
    try {
      await apiService.hideVideo(event.id);
      // Reload videos after hiding with current filters preserved
      final currentState = state;
      String? search;
      String? category;
      if (currentState is VideosLoaded) {
        search = currentState.currentSearch;
        category = currentState.currentCategory;
      }
      final videos = await apiService.getVideos(
        search: search,
        category: category,
      );
      emit(VideosLoaded(videos, currentSearch: search, currentCategory: category));
    } catch (e) {
      emit(VideoError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

