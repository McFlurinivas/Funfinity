part of 'level_bloc.dart';

abstract class LevelState extends Equatable {
  const LevelState();

  @override
  List<Object?> get props => [];
}

class LevelInitial extends LevelState {}

class LevelLoading extends LevelState {}

class LevelLoaded extends LevelState {
  final List<Level> levels;
  final int currentLevelIndex;
  final int highestLevelIndex;

  const LevelLoaded({
    required this.levels,
    required this.currentLevelIndex,
    required this.highestLevelIndex,
  });

  @override
  List<Object?> get props => [levels, currentLevelIndex, highestLevelIndex];
}

class FinalLevelCompleted extends LevelState {}

class LevelError extends LevelState {
  final String message;

  const LevelError(this.message);

  @override
  List<Object?> get props => [message];
}

class LevelUiState extends LevelState {
  const LevelUiState({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.answer,
    required this.isCorrect,
    required this.currentLevelIndex,
  });

  const LevelUiState.initial(
      {required this.id,
      required this.type,
      required this.question,
      required this.options,
      required this.answer,
      required this.isCorrect,
      required this.currentLevelIndex});

  LevelUiState copyWith(
      {String? id,
      String? type,
      String? question,
      List<String>? options,
      String? answer,
      bool? isCorrect,
      int? currentLevelIndex}) {
    return LevelUiState(
      id: id ?? this.id,
      type: type ?? this.type,
      question: question ?? this.question,
      options: options ?? this.options,
      answer: answer ?? this.answer,
      isCorrect: isCorrect ?? this.isCorrect,
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
    );
  }

  final String id;
  final String type;
  final String question;
  final List<String> options;
  final String answer;
  final bool isCorrect;
  final int currentLevelIndex;
}
