import 'package:equatable/equatable.dart';
import '../../models/video.dart';

abstract class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideosLoaded extends VideoState {
  final List<Video> videos;
  final String? currentSearch;
  final String? currentCategory;

  const VideosLoaded(this.videos, {this.currentSearch, this.currentCategory});

  @override
  List<Object?> get props => [videos, currentSearch, currentCategory];
}

class VideoLoaded extends VideoState {
  final Video video;

  const VideoLoaded(this.video);

  @override
  List<Object?> get props => [video];
}

class VideoError extends VideoState {
  final String message;

  const VideoError(this.message);

  @override
  List<Object?> get props => [message];
}

