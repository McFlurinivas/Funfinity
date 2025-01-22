import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:kidsplay/src/core/settings_manager.dart';
import 'package:kidsplay/src/core/screen_utils.dart';
import 'package:kidsplay/src/repositories/auth_repository.dart';
import 'package:kidsplay/src/repositories/game_repository.dart';
import 'package:kidsplay/src/repositories/hive_repository.dart';
import 'package:kidsplay/src/screens/drawer/home_drawer.dart';
import 'package:kidsplay/src/screens/home/bloc/home_bloc.dart';
import 'package:kidsplay/src/screens/level/level_screen.dart';
import 'package:kidsplay/src/widgets/progress_indicator/determine_linear_progress_indicator.dart';
import 'package:kidsplay/src/widgets/progress_indicator/jumping_dots_loading_indicator.dart';
import 'package:kidsplay/src/widgets/snackbar/custom_snackbar.dart';

class HomeScreen extends StatefulWidget {
  final String user;

  const HomeScreen({super.key, required this.user});

  static const path = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void requestNotificationPermission() async {
    PermissionStatus permission = await Permission.notification.request();

    if (permission.isDenied) {
      if (mounted) {
        CustomSnackbar.showSnackBar(context,
            'Notification permission denied. Please enable it from settings.',
            color: Colors.red);
      }
    } else if (permission.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    _bloc = HomeBloc(widget.user, GameRepository(), SettingsManager(),
        HiveRepository(), AuthRepository());
    _bloc.add(PageOpened());
    requestNotificationPermission();
  }

  final List<List<Color>> colors = [
    [Colors.blue.shade900, Colors.blue.shade700],
    [
      const Color.fromARGB(255, 153, 45, 10),
      const Color.fromARGB(255, 204, 102, 0)
    ],
    [Colors.green.shade900, Colors.green.shade700]
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) {
          return _bloc..add(PageOpened());
        },
        child: BlocListener<HomeBloc, HomeState>(
            listenWhen: (previous, current) =>
                previous is HomeSuccess &&
                current is HomeSuccess &&
                previous.openedLevelPage != current.openedLevelPage,
            listener: (context, state) async {
              if (state is! HomeSuccess) return;

              if (state.openedLevelPage != null) {
                await context.push(
                    "${LevelScreen.path}/${state.openedLevelPage!.$1}/${state.openedLevelPage!.$2}/${state.openedLevelPage!.$3}/${widget.user}");

                if (mounted) _bloc.add(const LevelPagePopped());
              }
            },
            child: Scaffold(
              body: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage(
                          'assets/images/login/login-background.jpg'),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      scale: constraints.maxWidth > 600 ? 1.0 : 2.0,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(ScreenUtils.x(6)).copyWith(
                            top: kBottomNavigationBarHeight, bottom: 8),
                        child: BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) {
                            if (state is HomeSuccess) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hello ${state.user.split(' ')[0]}!',
                                          style: TextStyle(
                                              color: Colors.brown,
                                              fontWeight: FontWeight.bold,
                                              fontSize: ScreenUtils.isPortrait
                                                  ? ScreenUtils.width * 0.08
                                                  : ScreenUtils.width * 0.05),
                                        ),
                                        Text(
                                            'Unlock a World of Fun and Learning',
                                            style: TextStyle(
                                              color: Colors.brown,
                                              fontSize: ScreenUtils.isPortrait
                                                  ? ScreenUtils.width * 0.05
                                                  : ScreenUtils.width * 0.03,
                                              fontFamily: 'Atma',
                                              fontWeight: FontWeight.w500,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const HomeDrawer(),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      Expanded(
                        child: BlocConsumer<HomeBloc, HomeState>(
                          listener: (context, state) async {
                            if (state is HomeError) {
                              CustomSnackbar.showSnackBar(
                                  context, state.message,
                                  color: Colors.red);
                            }
                          },
                          builder: (context, state) {
                            if (state is HomeLoading) {
                              return DetermineLinearProgressIndicator(
                                  progress: state.progress);
                            } else if (state is HomeSuccess) {
                              return state.categoryCards.isEmpty
                                  ? const Center(child: Text('No data found'))
                                  : LayoutBuilder(
                                      builder: (context, constraints) {
                                      return _buildCategoryList(
                                          state, constraints);
                                    });
                            }
                            return const Center(
                                child: SizedBox(
                              child: Text('Something Went Wrong'),
                            ));
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            )));
  }

  Widget _buildCategoryList(HomeSuccess state, BoxConstraints constraints) {
    return ListView.builder(
      padding: EdgeInsets.only(
        left: ScreenUtils.x(2.5),
        right: ScreenUtils.x(2.5),
      ),
      itemCount: state.categoryCards.length,
      scrollDirection: ScreenUtils.isPortrait ? Axis.vertical : Axis.horizontal,
      itemBuilder: (context, index) {
        return _buildCategoryItem(
            state.categoryCards[index], index, constraints);
      },
    );
  }

  Widget _buildCategoryItem(
      CategoryCardUiState uiState, int index, BoxConstraints constraints) {
    final itemHeight = ScreenUtils.isPortrait
        ? ScreenUtils.height * 0.2
        : ScreenUtils.height * 0.25;
    final itemWidth =
        ScreenUtils.isPortrait ? ScreenUtils.width : ScreenUtils.width * 0.2;
    final itemMargin = ScreenUtils.isPortrait
        ? ScreenUtils.height * 0.01
        : ScreenUtils.height * 0.02;

    final fontSize = ScreenUtils.isPortrait ? ScreenUtils.width * 0.08 : 20.0;

    return Container(
      height: itemHeight,
      width: itemWidth,
      margin: EdgeInsets.all(itemMargin),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: ScreenUtils.x(1.25),
            offset: Offset(0, ScreenUtils.x(1.25)),
          ),
        ],
        gradient: LinearGradient(
          colors: colors[index % colors.length],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(ScreenUtils.x(5))),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ScreenUtils.x(5)),
        child: Stack(
          children: [
            // Image with scaling
            Positioned.fill(
              child: Image.file(
                File(uiState.backgroundImage),
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.2),
                colorBlendMode: BlendMode.dstATop,
              ),
            ),
            // Text and Play Button
            Padding(
              padding: EdgeInsets.only(left: ScreenUtils.x(4)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlayButton(
                    uiState,
                    index,
                  ),
                  SizedBox(height: ScreenUtils.x(3)),
                  Text(uiState.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      )),
                  uiState.currentLevelIndex == -2
                      ? const JumpingDotsLoadingIndicator(
                          numberOfDots: 3,
                          color: Colors.white,
                          dotSize: 4.0,
                        )
                      : Text(
                          uiState.currentLevelIndex == -1
                              ? 'Well Done! All Levels Completed'
                              : 'Level ${uiState.currentLevelIndex + 1}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize * 0.7,
                              fontWeight: FontWeight.w500),
                        )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(CategoryCardUiState state, int index) {
    return InkWell(
      onTap: () async {
        _bloc.add(PlayButtonClicked(userId: widget.user, categoryId: state.id));
      },
      child: Container(
        height: ScreenUtils.isPortrait
            ? ScreenUtils.height * 0.06
            : ScreenUtils.height * 0.12,
        width: ScreenUtils.isPortrait
            ? ScreenUtils.height * 0.06
            : ScreenUtils.height * 0.12,
        margin: EdgeInsets.only(right: ScreenUtils.x(2.5)),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.white, width: ScreenUtils.width * 0.003),
                borderRadius: BorderRadius.all(
                    Radius.circular(ScreenUtils.height * 0.01)),
              ),
            ),
            Center(
              child: state.currentLevelIndex == -1
                  ? Icon(Icons.replay_rounded,
                      color: Colors.white,
                      size: ScreenUtils.isPortrait
                          ? ScreenUtils.height * 0.04
                          : ScreenUtils.height * 0.08)
                  : Icon(Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: ScreenUtils.isPortrait
                          ? ScreenUtils.height * 0.05
                          : ScreenUtils.height * 0.09),
            ),
          ],
        ),
      ),
    );
  }

  late final HomeBloc _bloc;
}
