import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsplay/src/hive/model/level.dart';
import 'package:kidsplay/src/hive/model/user_status.dart';
import 'package:kidsplay/src/model/level.dart';
import 'package:kidsplay/src/repositories/game_repository.dart';
import 'package:kidsplay/src/repositories/hive_repository.dart';

part 'level_event.dart';
part 'level_state.dart';

class LevelBloc extends Bloc<LevelEvent, LevelState> {
  final GameRepository gameRepository;
  final HiveRepository hiveRepository;

  LevelBloc(this.gameRepository, this.hiveRepository) : super(LevelInitial()) {
    on<LoadLevel>(_onLoadLevel);
    on<UpdateUserStatus>(_onUpdateUserStatus);
    on<NavigateToLevel>(_onNavigateToLevel);
    on<FinalLevelReached>(_onFinalLevelReached);
  }

  Future<void> _onLoadLevel(LoadLevel event, Emitter<LevelState> emit) async {
    emit(LevelLoading());
    try {
      // 1. Attempt to load levels from Hive storage
      List hiveLevels = await hiveRepository.getLevels(event.categoryId);
      List<HiveLevel> levelList = List<HiveLevel>.from(hiveLevels);
      List<Level> levels = [];

      for (var level in levelList) {
        String questionContent = level.question;

        if (level.type == 'image') {
          final existingFilePath = await hiveRepository.getLottieFilePath(
              '${event.categoryId}_${level.id}', 'json');

          // Download Lottie file only if not already downloaded
          if (existingFilePath.isEmpty) {
            final filePath = await hiveRepository.downloadLottie(
                questionContent, '${event.categoryId}_${level.id}', 'json');
            questionContent = filePath;
          } else {
            questionContent = existingFilePath;
          }
        }

        levels.add(Level(
          id: level.id,
          question: questionContent,
          answer: level.answer,
          options: level.options,
          type: level.type,
        ));
      }

      // Emit the updated levels
      await _emitCurrentLevel(levels, event.userID, event.categoryId, emit);
    } catch (e) {
      emit(LevelError('Failed to load levels: ${e.toString()}'));
    }
  }

  Future<void> _emitCurrentLevel(List<Level> levels, String userID,
      String categoryId, Emitter<LevelState> emit) async {
    try {
      final userProgress =
          await gameRepository.fetchUserProgress(userID, categoryId);

      // Check if the user has completed all levels
      if (userProgress?.levelID == 'completed') {
        emit(FinalLevelCompleted());
      } else {
        // Find the current level index or set it to the first level if none found
        final currentLevelIndex =
            levels.indexWhere((level) => level.id == userProgress?.levelID);
        emit(LevelLoaded(
          levels: levels,
          highestLevelIndex: currentLevelIndex,
          currentLevelIndex: currentLevelIndex != -1 ? currentLevelIndex : 0,
        ));
      }
    } catch (e) {
      emit(LevelError('Failed to load current level: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUserStatus(
      UpdateUserStatus event, Emitter<LevelState> emit) async {
    try {
      // Load the user progress from Hive
      final userProgressList = await hiveRepository.getUserProgress();
      final userProgress = userProgressList.firstWhere(
        (progress) => progress.categoryID == event.categoryId,
        orElse: () => HiveUserStatus(categoryID: event.categoryId, levelID: ''),
      );

      final updatedUserProgress = userProgress.copyWith(levelID: event.levelId);

      await hiveRepository.updateUserProgress(updatedUserProgress);

      await gameRepository.setOrUpdateUserProgress(
        event.userId,
        event.categoryId,
        event.levelId,
      );
    } catch (e) {
      emit(LevelError('Failed to update user status: ${e.toString()}'));
    }
  }

  Future<void> _onNavigateToLevel(
      NavigateToLevel event, Emitter<LevelState> emit) async {
    if (state is! LevelLoaded) return;
    final currentState = state as LevelLoaded;

    final currentLevelIndex =
        currentState.levels.indexWhere((level) => level.id == event.levelId);

    emit(LevelLoaded(
      levels: currentState.levels,
      highestLevelIndex: currentState.highestLevelIndex,
      currentLevelIndex: currentLevelIndex,
    ));
  }

  Future<void> _onFinalLevelReached(
      FinalLevelReached event, Emitter<LevelState> emit) async {
    emit(FinalLevelCompleted());
  }
}
