import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsplay/src/core/global.dart';
import 'package:kidsplay/src/repositories/auth_repository.dart';
import 'package:kidsplay/src/repositories/game_repository.dart';
import 'package:kidsplay/src/repositories/hive_repository.dart';
import 'package:kidsplay/src/screens/home/home_screen.dart';
import 'package:kidsplay/src/screens/level/bloc/level_bloc.dart';
import 'package:kidsplay/src/screens/level/level_screen.dart';
import 'package:kidsplay/src/screens/login/bloc/login_bloc.dart';
import 'package:kidsplay/src/screens/login/login_screen.dart';
import 'package:kidsplay/src/screens/splash/splash_screen.dart';
import 'package:kidsplay/src/service/analytics_service.dart';

class AppRoute {
  static final GoRouter routes = GoRouter(
    navigatorKey: Global.navKey,
    initialLocation: SplashScreen.path,
    routes: _buildRoutes(),
    errorBuilder: (context, state) => _errorPage(),
    observers: [AnalyticsService.observer],
  );

  static List<GoRoute> _buildRoutes() {
    return [
      GoRoute(
        path: SplashScreen.path,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '${LoginScreen.path}/:bgImage/:abcImage',
        builder: (context, state) => BlocProvider(
          create: (context) => LoginBloc(AuthRepository(), HiveRepository()),
          child: _buildLoginScreen(state),
        ),
      ),
      GoRoute(
          path: '${HomeScreen.path}/:userId',
          builder: (context, state) {
            String? userId = state.pathParameters['userId'];
            return HomeScreen(user: userId!);
          }),
      GoRoute(
          path:
              '${LevelScreen.path}/:categoryId/:levelId/:categoryName/:userId',
          builder: (context, state) => BlocProvider(
                create: (context) =>
                    LevelBloc(GameRepository(), HiveRepository())
                      ..add(LoadLevel(
                          categoryId: state.pathParameters['categoryId']!,
                          userID: state.pathParameters['userId']!)),
                child: _buildLevelScreen(state),
              )),
    ];
  }

  static Widget _buildLoginScreen(GoRouterState state) {
    final String? encodedBgImage = state.pathParameters['bgImage'];
    final String? encodedAbcImage = state.pathParameters['abcImage'];
    final String bgImage = Uri.decodeComponent(encodedBgImage!);
    final String abcImage = Uri.decodeComponent(encodedAbcImage!);
    return LoginScreen(bgImage: bgImage, abcImage: abcImage);
  }

  static Widget _buildLevelScreen(GoRouterState state) {
    final String? categoryId = state.pathParameters['categoryId'];
    final String? levelId = state.pathParameters['levelId'];
    final String? userId = state.pathParameters['userId'];
    final String? categoryName = state.pathParameters['categoryName'];
    return LevelScreen(
        categoryId: categoryId!,
        levelId: levelId!,
        categoryName: categoryName!,
        userId: userId!);
  }

  static Widget _errorPage() {
    return const Scaffold(
      body: Center(child: Text("404 page not found!")),
    );
  }
}
