import 'dart:io';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:kidsplay/src/core/settings_manager.dart';
import 'package:kidsplay/src/core/screen_utils.dart';
import 'package:kidsplay/src/screens/level/bloc/level_bloc.dart';
import 'package:kidsplay/src/widgets/progress_indicator/custom_progress_indicator.dart';
import 'package:kidsplay/src/widgets/progress_indicator/jumping_dots_loading_indicator.dart';
import 'package:kidsplay/src/widgets/snackbar/custom_snackbar.dart';

class LevelScreen extends StatefulWidget {
  final String categoryId;
  final String levelId;
  final String userId;
  final String categoryName;

  const LevelScreen({
    super.key,
    required this.categoryId,
    required this.levelId,
    required this.categoryName,
    required this.userId,
  });

  static const path = '/level';

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  late ValueNotifier<String> currentLevelIdNotifier;
  late ValueNotifier<List<String>> selectedLettersNotifier;
  int highestLevelReached = 0;
  late ConfettiController _confettiController;
  LottieComposition? composition;
  late int initialLevelIndex;

  @override
  void initState() {
    super.initState();
    currentLevelIdNotifier = ValueNotifier(widget.levelId);
    selectedLettersNotifier = ValueNotifier([]);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    currentLevelIdNotifier.dispose();
    selectedLettersNotifier.dispose();
    super.dispose();
  }

  void saveUserProgress(String levelID) {
    context.read<LevelBloc>().add(
          UpdateUserStatus(
            userId: widget.userId,
            categoryId: widget.categoryId,
            levelId: levelID,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: context.watch<LevelBloc>().state is FinalLevelCompleted
          ? null
          : AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              title: BlocBuilder<LevelBloc, LevelState>(
                buildWhen: (previous, current) => current is LevelLoaded,
                builder: (context, state) {
                  if (state is LevelLoaded) {
                    return _navigateThroughLevels(state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            padding: EdgeInsets.only(
              top: ScreenUtils.isPortrait
                  ? 44 + ScreenUtils.statusBarHeight * 0.1
                  : 44 + ScreenUtils.statusBarHeight * 1.5,
              left: ScreenUtils.x(2.5),
              right: ScreenUtils.x(2.5),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(
                    'assets/images/login/login-background.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                scale: ScreenUtils.width > 600 ? 1.0 : 2.0,
              ),
            ),
            child: OrientationBuilder(
              builder: (context, orientation) {
                return BlocConsumer<LevelBloc, LevelState>(
                  listener: _levelBlocListener,
                  listenWhen: (previous, current) =>
                      current is FinalLevelCompleted || current is LevelError,
                  buildWhen: (previous, current) =>
                      current is LevelLoading ||
                      current is LevelLoaded ||
                      current is FinalLevelCompleted ||
                      current is LevelError,
                  builder: (context, state) {
                    if (state is LevelLoading) {
                      return const CustomProgressIndicator();
                    } else if (state is LevelLoaded) {
                      initialLevelIndex = state.highestLevelIndex;
                      return _buildLevelUI(state, orientation);
                    } else if (state is FinalLevelCompleted) {
                      SettingsManager().playAllLevelsCompleted();
                      return _buildFinalLevelCompleted();
                    } else if (state is LevelError) {
                      return Center(child: Text(state.message));
                    }

                    return const Center(child: Text('Error loading level'));
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _levelBlocListener(BuildContext context, LevelState state) {
    if (state is FinalLevelCompleted) {
      _confettiController.play();
      Future.delayed(const Duration(seconds: 5), () {
        if (!context.mounted) return;
        context.pop();
      });
    } else if (state is LevelError) {
      CustomSnackbar.showSnackBar(context, state.message, color: Colors.red);
    }
  }

  Widget _navigateThroughLevels(LevelLoaded state) {
    int currentLevelIndex = state.currentLevelIndex;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: currentLevelIndex != 0
              ? const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.brown, size: 25)
              : const Icon(Icons.home, color: Colors.brown),
          onPressed: () {
            SettingsManager().playTapSound();
            currentLevelIndex != 0
                ? _handlePreviousLevel(state, currentLevelIndex)
                : context.pop();
          },
        ),
        Expanded(
          child: Center(
            child: Column(
              children: [
                Text(
                  widget.categoryName,
                  style: TextStyle(
                      fontSize: ScreenUtils.x(6),
                      color: Colors.brown,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Level ${currentLevelIndex + 1}",
                  style: TextStyle(
                      fontSize: ScreenUtils.x(6),
                      color: Colors.brown,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        if (state.levels[currentLevelIndex].type == 'image')
          _buildEraseButton(),
      ],
    );
  }

  Widget _buildEraseButton() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: selectedLettersNotifier,
      builder: (context, selectedLetters, child) {
        return TextButton(
          onPressed: selectedLetters.isEmpty
              ? null
              : () {
                  SettingsManager().playEraseSound();
                  selectedLettersNotifier.value = [];
                },
          style: ButtonStyle(
            elevation: WidgetStateProperty.all(2),
            backgroundColor: WidgetStateProperty.all(selectedLetters.isEmpty
                ? Colors.red.withOpacity(0.5)
                : Colors.red),
          ),
          child: const Text(
            'Erase',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildLevelUI(LevelLoaded state, Orientation orientation) {
    int currentLevelIndex = state.currentLevelIndex;

    return orientation == Orientation.portrait
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              state.levels[currentLevelIndex].type == 'text'
                  ? Text(
                      state.levels[currentLevelIndex].question,
                      style: TextStyle(
                          fontSize: ScreenUtils.height * 0.08,
                          fontWeight: FontWeight.bold),
                    )
                  : Expanded(
                      child: Column(
                        children: [
                          composition != null
                              ? Container(
                                  padding: EdgeInsets.zero,
                                  height: ScreenUtils.height * 0.3,
                                  width: ScreenUtils.x(75),
                                  child: Center(
                                    child: Lottie(
                                      composition: composition!,
                                      repeat: false,
                                    ),
                                  ),
                                )
                              : FutureBuilder<LottieComposition>(
                                  future: FileLottie(File(state
                                          .levels[currentLevelIndex].question))
                                      .load(),
                                  builder: (context, snapshot) {
                                    composition = snapshot.data;
                                    return Container(
                                        padding: EdgeInsets.zero,
                                        height: ScreenUtils.height * 0.3,
                                        width: ScreenUtils.x(75),
                                        child: snapshot.connectionState ==
                                                ConnectionState.waiting
                                            ? const Center(
                                                child:
                                                    JumpingDotsLoadingIndicator(
                                                numberOfDots: 3,
                                                color: Colors.brown,
                                                dotSize: 8.0,
                                              ))
                                            : snapshot.hasError
                                                ? const Text(
                                                    'Error loading animation',
                                                    textAlign: TextAlign.center,
                                                  )
                                                : Center(
                                                    child: Lottie(
                                                      composition: composition!,
                                                      repeat: false,
                                                    ),
                                                  ));
                                  },
                                ),
                          SizedBox(height: ScreenUtils.x(5)),
                          _buildBlanks(state.levels[currentLevelIndex].answer),
                        ],
                      ),
                    ),
              _buildOptions(state, currentLevelIndex),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: state.levels[currentLevelIndex].type == 'text'
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.levels[currentLevelIndex].question,
                            style: TextStyle(
                                fontSize: ScreenUtils.height * 0.2,
                                fontWeight: FontWeight.bold),
                          ),
                          _buildOptions(state, currentLevelIndex),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: composition != null
                                ? Container(
                                    padding: EdgeInsets.zero,
                                    height: ScreenUtils.height,
                                    width: ScreenUtils.x(75),
                                    child: Center(
                                      child: Lottie(
                                        composition: composition!,
                                        repeat: false,
                                      ),
                                    ),
                                  )
                                : FutureBuilder<LottieComposition>(
                                    future: FileLottie(File(state
                                            .levels[currentLevelIndex]
                                            .question))
                                        .load(),
                                    builder: (context, snapshot) {
                                      composition = snapshot.data;
                                      return Container(
                                          padding: EdgeInsets.zero,
                                          height: ScreenUtils.height,
                                          width: ScreenUtils.x(75),
                                          child: snapshot.connectionState ==
                                                  ConnectionState.waiting
                                              ? const Center(
                                                  child:
                                                      JumpingDotsLoadingIndicator(
                                                  numberOfDots: 3,
                                                  color: Colors.brown,
                                                  dotSize: 8.0,
                                                ))
                                              : snapshot.hasError
                                                  ? const Text(
                                                      'Error loading animation',
                                                      textAlign:
                                                          TextAlign.center,
                                                    )
                                                  : Center(
                                                      child: Lottie(
                                                        composition:
                                                            composition!,
                                                        repeat: false,
                                                      ),
                                                    ));
                                    },
                                  ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildBlanks(
                                    state.levels[currentLevelIndex].answer),
                                _buildOptions(state, currentLevelIndex),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
  }

  Widget _buildBlanks(String answer) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: selectedLettersNotifier,
      builder: (context, selectedLetters, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: ScreenUtils.x(2),
              runSpacing: ScreenUtils.x(2),
              children: List.generate(answer.length, (index) {
                return Container(
                  width: ScreenUtils.isPortrait
                      ? ScreenUtils.width * 0.13
                      : ScreenUtils.width * 0.08,
                  height: ScreenUtils.height * 0.1,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(ScreenUtils.x(1)),
                  ),
                  child: Text(
                    selectedLetters.length > index
                        ? selectedLetters[index].toUpperCase()
                        : "_",
                    style: TextStyle(fontSize: ScreenUtils.height * 0.07),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptions(LevelLoaded state, int currentLevelIndex) {
    return Flexible(
      fit: FlexFit.loose,
      child: Container(
        margin: EdgeInsets.all(ScreenUtils.x(4)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(ScreenUtils.x(2.5))),
          color: Colors.white38,
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: List.generate(
                  state.levels[currentLevelIndex].options.length, (index) {
                List<String> options =
                    List.from(state.levels[currentLevelIndex].options);
                return SizedBox(
                  width: (ScreenUtils.width - ScreenUtils.x(16)) /
                      (ScreenUtils.isPortrait ? 3 : 8),
                  child: GestureDetector(
                    onTap: () {
                      _onOptionTap(state.levels[currentLevelIndex].answer,
                          options[index], currentLevelIndex, state);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.primaries[index % Colors.primaries.length]
                            .shade400,
                      ),
                      margin: EdgeInsets.all(ScreenUtils.x(2)),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            options[index].toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtils.isPortrait
                                  ? ScreenUtils.height * 0.06
                                  : ScreenUtils.height * 0.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _onOptionTap(String answer, String selectedOption, int currentLevelIndex,
      LevelLoaded state) {
    SettingsManager().playTapSound();
    if (selectedLettersNotifier.value.length < answer.length &&
        state.levels[currentLevelIndex].type == 'image') {
      selectedLettersNotifier.value = [
        ...selectedLettersNotifier.value,
        selectedOption
      ];

      if (selectedLettersNotifier.value.length == answer.length) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _validateAnswer(answer, currentLevelIndex, state);
        });
      }
    } else {
      if (selectedOption == state.levels[currentLevelIndex].answer) {
        _validateAnswer(selectedOption, currentLevelIndex, state);
      } else {
        if (SettingsManager.isVibrating) HapticFeedback.lightImpact();
        SettingsManager().playLevelFailed();
        CustomSnackbar.showSnackBar(context, "Wrong Answer", color: Colors.red);
      }
    }
  }

  void _validateAnswer(
      String answer, int currentLevelIndex, LevelLoaded state) {
    // Determine user's answer based on level type (image or text)
    String userAnswer = state.levels[currentLevelIndex].type == 'image'
        ? selectedLettersNotifier.value.join('')
        : answer;

    // Check if the user's answer matches the correct answer
    if (userAnswer.toLowerCase() == answer.toLowerCase()) {
      CustomSnackbar.showSnackBar(context, "Correct Answer",
          color: Colors.green);
      SettingsManager().playLevelCompleted();

      if (currentLevelIndex < state.levels.length - 1) {
        // Move to the next level if it's not the last one
        _handleNextLevel(state, currentLevelIndex);
      } else {
        // Reached the last level, mark progress as completed
        saveUserProgress('completed');
        if (SettingsManager.isVibrating) HapticFeedback.heavyImpact();
        context.read<LevelBloc>().add(const FinalLevelReached());
      }
    } else {
      // Feedback for incorrect answer
      if (SettingsManager.isVibrating) HapticFeedback.lightImpact();
      SettingsManager().playLevelFailed();
      CustomSnackbar.showSnackBar(context, "Wrong Answer", color: Colors.red);
    }

    // Reset selected letters for the next attempt or level
    selectedLettersNotifier.value = [];
  }

  void _handlePreviousLevel(LevelLoaded state, int currentLevelIndex) {
    if (currentLevelIndex > 0) {
      currentLevelIdNotifier.value = state.levels[currentLevelIndex - 1].id;
      context
          .read<LevelBloc>()
          .add(NavigateToLevel(levelId: currentLevelIdNotifier.value));
      selectedLettersNotifier.value = [];
      setState(() {
        composition = null;
      });
    }
  }

  void _handleNextLevel(LevelLoaded state, int currentLevelIndex) {
    if (currentLevelIndex < state.levels.length - 1) {
      currentLevelIdNotifier.value = state.levels[currentLevelIndex + 1].id;

      context
          .read<LevelBloc>()
          .add(NavigateToLevel(levelId: currentLevelIdNotifier.value));

      if (currentLevelIndex + 1 > initialLevelIndex) {
        initialLevelIndex = currentLevelIndex + 1;
        saveUserProgress(currentLevelIdNotifier.value);
      }

      setState(() {
        composition = null;
      });
    }
  }

  Widget _buildFinalLevelCompleted() {
    return Center(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: true,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow
              ],
            ),
          ),
          Center(
            child: Text(
              "🎉 YaY! You Did It! 🎉",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: ScreenUtils.isPortrait
                      ? ScreenUtils.width * 0.08
                      : ScreenUtils.width * 0.05,
                  fontFamily: 'Atma',
                  color: Colors.brown,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
