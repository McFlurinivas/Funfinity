part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class PageOpened extends HomeEvent {
  @override
  List<Object> get props => [];
}

class PlayButtonClicked extends HomeEvent {
  final String userId;
  final String categoryId;

  const PlayButtonClicked({required this.userId, required this.categoryId});

  @override
  List<Object> get props => [userId, categoryId];
}

class LevelPagePopped extends HomeEvent {
  const LevelPagePopped();
}

class CategoryAdded extends HomeEvent {
  final Category category;

  const CategoryAdded(this.category);

  @override
  List<Object> get props => [category];
}
