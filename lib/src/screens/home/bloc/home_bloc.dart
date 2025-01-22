import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsplay/src/core/settings_manager.dart';
import 'package:kidsplay/src/hive/model/category.dart';
import 'package:kidsplay/src/hive/model/level.dart';
import 'package:kidsplay/src/hive/model/settings.dart';
import 'package:kidsplay/src/hive/model/user_status.dart';
import 'package:kidsplay/src/model/category.dart';
import 'package:kidsplay/src/model/level.dart';
import 'package:kidsplay/src/model/user_status.dart';
import 'package:kidsplay/src/repositories/auth_repository.dart';
import 'package:kidsplay/src/repositories/game_repository.dart';
import 'package:kidsplay/src/repositories/hive_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final String userId;
  final GameRepository gameRepository;
  final SettingsManager settingsManager;
  final HiveRepository hiveRepository;
  final AuthRepository authRepository;

  late String? user;
  String? cachedUser;
  StreamSubscription<List<Category>>? _categoriesListener;
  final Map<String, StreamSubscription<List<Level>>> _levelsListeners = {};
  StreamSubscription<Category>? _categoryDeletionListener;

  HomeBloc(this.userId, this.gameRepository, this.settingsManager,
      this.hiveRepository, this.authRepository)
      : super(HomeInitial()) {
    on<PageOpened>(_onPageOpened);
    on<PlayButtonClicked>(_onPlayButtonClicked);
    on<LevelPagePopped>(_onLevelPagePopped);
  }

  Future<void> _onPageOpened(PageOpened event, Emitter<HomeState> emit) async {
    emit(HomeLoading(0.0));
    final userModel = await authRepository.getCurrentUserDetails();
    user = userModel!.name;
    cachedUser = user;
    await _listenToCategories(emit, cachedUser!);

    final categories = await hiveRepository.getCategories();
    for (var category in categories) {
      if (!_levelsListeners.containsKey(category.id)) {
        _listenToLevels(category.id);
      }
    }

    _listenToCategoryDeletions();
  }

  Future<void> _onPlayButtonClicked(
      PlayButtonClicked event, Emitter<HomeState> emit) async {
    settingsManager.playTapSound();
    final categoryCard = (state as HomeSuccess)
        .categoryCards
        .firstWhere((e) => event.categoryId == e.id);

    if (categoryCard.currentLevelIndex == -1) {
      try {
        final firstLevelId =
            await hiveRepository.getLevels(event.categoryId).then((levels) {
          return levels.first.id;
        });

        await hiveRepository.updateUserProgress(HiveUserStatus(
          categoryID: event.categoryId,
          levelID: firstLevelId,
        ));

        emit((state as HomeSuccess).copyWith(
          categoryCards: (state as HomeSuccess).categoryCards.map((card) {
            if (card.id != event.categoryId) return card;
            return card.copyWith(
                isFinalLevelCompleted: false, levelId: firstLevelId);
          }).toList(),
        ));
        emit((state as HomeSuccess).copyWith(openedLevelPage: (
          categoryCard.id,
          categoryCard.levelId,
          categoryCard.name
        )));
        await gameRepository.setOrUpdateUserProgress(
            event.userId, event.categoryId, firstLevelId);
      } catch (e) {
        if (!isClosed) emit(HomeError(e.toString()));
      }
    } else {
      emit((state as HomeSuccess).copyWith(openedLevelPage: (
        categoryCard.id,
        categoryCard.levelId,
        categoryCard.name
      )));
    }
  }

  Future<void> _onLevelPagePopped(
      LevelPagePopped event, Emitter<HomeState> emit) async {
    if (state is HomeSuccess) {
      emit((state as HomeSuccess).copyWith(openedLevelPage: null));
    }

    await _loadCurrentLevelIndexes(emit, cachedUser!);
  }

  Future<void> _listenToCategories(Emitter<HomeState> emit, String user) async {
    emit(HomeLoading(0.05));

    HiveSettings settings = hiveRepository.getSettings();
    if (settings.isBgMusicPlaying) {
      settingsManager.playBackgroundMusic();
    }

    if (await authRepository.isConnected()) {
      emit(HomeLoading(0.1));

      final categoriesFuture = gameRepository.fetchCategories();
      final userProgressFuture =
          gameRepository.fetchUserProgressForAllCategories(userId);
      List<HiveCategory> hiveCategories = await hiveRepository.getCategories();

      emit(HomeLoading(0.15));

      List<HiveCategory> storingHiveCategories = [];
      final categories = await categoriesFuture;
      final userProgress = await userProgressFuture;

      for (var category in categories) {
        if (hiveCategories.contains(HiveCategory(
          id: category.id,
          name: category.name,
          image: category.image,
        ))) {
          continue;
        }
        String image;
        final existingFilePath = await hiveRepository
            .getImageFilePath('${category.id}_${category.name}');

        image = existingFilePath.isEmpty
            ? await hiveRepository.downloadImageFile(
                category.image, '${category.id}_${category.name}')
            : existingFilePath;

        storingHiveCategories.add(HiveCategory(
          id: category.id,
          name: category.name,
          image: image,
        ));

        List<HiveUserStatus> hiveUserStatus =
            await hiveRepository.getUserProgress();
        final userProgressIds = userProgress.map((e) => e.categoryID).toList();
        if (!userProgressIds.contains(category.id)) {
          final firstLevelId =
              await gameRepository.fetchFirstLevelId(category.id);
          await hiveRepository.putSingleUserProgress(HiveUserStatus(
            categoryID: category.id,
            levelID: firstLevelId!,
          ));
          await gameRepository.ensureUserCategoryExists(userId, category.id);

          List<Level> levels =
              await gameRepository.fetchLevelsFromCategory(category.id);
          await hiveRepository.putLevels(
              category.id,
              levels
                  .map((level) => HiveLevel(
                        id: level.id,
                        question: level.question,
                        answer: level.answer,
                        options: level.options,
                        type: level.type,
                      ))
                  .toList());
        } else {
          if (hiveUserStatus.isEmpty) {
            for (var userStatus in userProgress) {
              await hiveRepository.putSingleUserProgress(HiveUserStatus(
                categoryID: userStatus.categoryID,
                levelID: userStatus.levelID,
              ));
            }
          }
        }
      }

      await hiveRepository.putCategory(storingHiveCategories);
      emit(HomeLoading(0.35));
    }
    await _loadAllCategories(emit, cachedUser!);
  }

  void _listenToCategoryDeletions() {
    gameRepository.getCategoryDeletionsStream().listen(
      (category) async {
        await hiveRepository.deleteCategory(category.id);
        await hiveRepository.deleteLevels(category.id);
        await hiveRepository.deleteSingleUserProgress(category.id);
      },
      onError: (e) => add(HomeError(e.toString()) as HomeEvent),
    );
  }

  void _listenToLevels(String categoryId) {
    _levelsListeners[categoryId] =
        gameRepository.getLevelsStream(categoryId).listen(
      (levels) async {
        for (var level in levels) {
          String questionContent = level.question;

          if (level.question.contains('.json')) {
            final filePath = await hiveRepository.downloadLottie(
                level.question, '${categoryId}_${level.id}', 'json');
            questionContent = filePath;
          }

          await hiveRepository.updateLevels(categoryId, [
            HiveLevel(
              id: level.id,
              question:
                  level.type == 'image' ? questionContent : level.question,
              answer: level.answer,
              options: level.options,
              type: level.type,
            )
          ]);
        }
      },
      onError: (e) => add(HomeError(e.toString()) as HomeEvent),
    );
  }

  Future<void> _loadAllCategories(Emitter<HomeState> emit, String user) async {
    await _smoothProgressUpdate(emit, 0.4);

    List<Category> categories = [];
    List<UserStatus> userProgress = [];

    try {
      final hiveUserProgress = await hiveRepository.getUserProgress();
      final hiveCategories = await hiveRepository.getCategories();

      await _smoothProgressUpdate(emit, 0.6);

      categories = hiveCategories
          .map((hiveCategory) => Category(
                id: hiveCategory.id,
                name: hiveCategory.name,
                image: hiveCategory.image,
              ))
          .toList();
      await _smoothProgressUpdate(emit, 0.8);

      userProgress = hiveUserProgress
          .map((hiveStatus) => UserStatus(
                categoryID: hiveStatus.categoryID,
                levelID: hiveStatus.levelID,
              ))
          .toList();

      final categoryCards = await Future.wait(categories.map((category) async {
        final categoryUserProgress = userProgress.firstWhere(
          (e) => e.categoryID == category.id,
          orElse: () => UserStatus(categoryID: category.id, levelID: ''),
        );

        return CategoryCardUiState.initial(
          id: category.id,
          name: category.name,
          isFinalLevelCompleted: categoryUserProgress.levelID == 'completed',
          levelId: categoryUserProgress.levelID,
          backgroundImage: category.image,
          currentLevelIndex: categoryUserProgress.levelID == 'completed'
              ? -1
              : await gameRepository.fetchCurrentLevelIndex(
                  category.id, categoryUserProgress.levelID),
        );
      }));

      emit(HomeLoading(0.9));

      await _smoothProgressUpdate(emit, 1.0);
      emit(HomeSuccess.initial(categoryCards, user));
      await _loadCurrentLevelIndexes(emit, user);
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _smoothProgressUpdate(
      Emitter<HomeState> emit, double target) async {
    double currentProgress =
        (state is HomeLoading) ? (state as HomeLoading).progress : 0;

    while (currentProgress < target) {
      currentProgress += 0.05;
      emit(HomeLoading(currentProgress));
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _loadCurrentLevelIndexes(
      Emitter<HomeState> emit, String user) async {
    List<HiveUserStatus> userProgress;
    List hiveLevels = <HiveLevel>[];
    List<HiveLevel> levelList;

    try {
      userProgress = await hiveRepository.getUserProgress();

      final updatedCategoryCards = await Future.wait(
        (state as HomeSuccess).categoryCards.map((categoryCard) async {
          final categoryUserProgress = userProgress.firstWhere(
            (e) => e.categoryID == categoryCard.id,
            orElse: () =>
                HiveUserStatus(categoryID: categoryCard.id, levelID: ''),
          );

          hiveLevels = await hiveRepository.getLevels(categoryCard.id);

          if (hiveLevels.isEmpty) {
            // Fetch levels from the repository if not found locally
            final levels =
                await gameRepository.fetchLevelsFromCategory(categoryCard.id);
            final hiveLevelsToStore = <HiveLevel>[];

            for (var level in levels) {
              String questionContent = level.question;

              if (level.question.contains('.json')) {
                final filePath = await hiveRepository.downloadLottie(
                    level.question, '${categoryCard.id}_${level.id}', 'json');
                questionContent = filePath;
              }

              hiveLevelsToStore.add(HiveLevel(
                id: level.id,
                question:
                    level.type == 'image' ? questionContent : level.question,
                answer: level.answer,
                options: level.options,
                type: level.type,
              ));
            }
            await hiveRepository.putLevels(categoryCard.id, hiveLevelsToStore);
            levelList = List<HiveLevel>.from(hiveLevelsToStore);
          } else {
            levelList = List<HiveLevel>.from(hiveLevels);
          }

          // If this is a new category, set the currentLevelIndex to 0 and store the first level in user progress
          int currentLevelIndex = categoryUserProgress.levelID == 'completed'
              ? -1
              : levelList.indexWhere(
                  (level) => level.id == categoryUserProgress.levelID);

          return categoryCard.copyWith(currentLevelIndex: currentLevelIndex);
        }),
      );

      emit(HomeSuccess.initial(updatedCategoryCards, user));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _categoriesListener?.cancel();
    for (var listener in _levelsListeners.values) {
      listener.cancel();
    }
    _categoryDeletionListener?.cancel();
    return super.close();
  }
}
