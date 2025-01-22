part of 'level_bloc.dart';

abstract class LevelEvent extends Equatable {
  const LevelEvent();

  @override
  List<Object?> get props => [];
}

class LoadLevel extends LevelEvent {
  final String categoryId;
  final String userID;

  const LoadLevel({required this.categoryId, required this.userID});

  @override
  List<Object?> get props => [categoryId, userID];
}

class NavigateToLevel extends LevelEvent {
  final String levelId;

  const NavigateToLevel({required this.levelId});

  @override
  List<Object?> get props => [levelId];
}

class UpdateUserStatus extends LevelEvent {
  final String userId;
  final String categoryId;
  final String levelId;

  const UpdateUserStatus({
    required this.userId,
    required this.categoryId,
    required this.levelId,
  });

  @override
  List<Object?> get props => [userId, categoryId, levelId];
}

class FinalLevelReached extends LevelEvent {
  const FinalLevelReached();
}
