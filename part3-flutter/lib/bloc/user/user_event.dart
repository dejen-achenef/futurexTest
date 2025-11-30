import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUser extends UserEvent {
  final int id;

  const LoadUser(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateUser extends UserEvent {
  final int id;
  final String? name;
  final String? email;

  const UpdateUser({
    required this.id,
    this.name,
    this.email,
  });

  @override
  List<Object?> get props => [id, name, email];
}

