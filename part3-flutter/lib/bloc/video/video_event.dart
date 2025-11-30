import 'package:equatable/equatable.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

class LoadVideos extends VideoEvent {
  final String? search;
  final String? category;

  const LoadVideos({this.search, this.category});

  @override
  List<Object?> get props => [search, category];
}

class RefreshVideos extends VideoEvent {
  final String? search;
  final String? category;

  const RefreshVideos({this.search, this.category});

  @override
  List<Object?> get props => [search, category];
}

class LoadVideoById extends VideoEvent {
  final int id;

  const LoadVideoById(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteVideo extends VideoEvent {
  final int id;

  const DeleteVideo(this.id);

  @override
  List<Object?> get props => [id];
}

class HideVideo extends VideoEvent {
  final int id;

  const HideVideo(this.id);

  @override
  List<Object?> get props => [id];
}

