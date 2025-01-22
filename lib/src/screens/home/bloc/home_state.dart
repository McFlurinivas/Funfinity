part of 'home_bloc.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {
  double progress;
  HomeLoading(this.progress);
}

class HomeSuccess extends HomeState {
  final String user;
  final List<CategoryCardUiState> categoryCards;
  final (String, String, String)? openedLevelPage;

  const HomeSuccess(this.user, this.categoryCards, this.openedLevelPage);

  HomeSuccess.initial(this.categoryCards, this.user) : openedLevelPage = null;

  HomeSuccess copyWith(
      {List<CategoryCardUiState>? categoryCards,
      (String, String, String)? openedLevelPage,
      String? user}) {
    return HomeSuccess(
      user ?? this.user,
      categoryCards ?? this.categoryCards,
      openedLevelPage ?? this.openedLevelPage,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);
}

class CategoryCardUiState extends HomeState {
  const CategoryCardUiState({
    required this.id,
    required this.name,
    required this.isFinalLevelCompleted,
    required this.levelId,
    required this.backgroundImage,
    required this.currentLevelIndex,
  });

  const CategoryCardUiState.initial(
      {required this.id,
      required this.name,
      required this.isFinalLevelCompleted,
      required this.levelId,
      required this.backgroundImage,
      required this.currentLevelIndex});

  CategoryCardUiState copyWith(
      {String? id,
      String? name,
      bool? isFinalLevelCompleted,
      String? levelId,
      String? backgroundImage,
      int? currentLevelIndex}) {
    return CategoryCardUiState(
      id: id ?? this.id,
      name: name ?? this.name,
      isFinalLevelCompleted:
          isFinalLevelCompleted ?? this.isFinalLevelCompleted,
      levelId: levelId ?? this.levelId,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
    );
  }

  final String id;
  final String name;
  final bool isFinalLevelCompleted;
  final String levelId;
  final String backgroundImage;
  final int currentLevelIndex;
}
