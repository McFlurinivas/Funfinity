import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsplay/src/core/settings_manager.dart';
import 'package:kidsplay/src/core/screen_utils.dart';
import 'package:kidsplay/src/repositories/auth_repository.dart';

import 'package:kidsplay/src/screens/home/home_screen.dart';
import 'package:kidsplay/src/screens/login/login_screen.dart';
import 'package:kidsplay/src/screens/splash/cubit/splash_cubit.dart';
import 'package:kidsplay/src/widgets/snackbar/custom_snackbar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const path = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final String bgImage = 'assets/images/login/login-background.jpg';
  final String abcImage = 'assets/images/login/login-abc.png';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheImages();
  }

  void _precacheImages() {
    precacheImage(AssetImage(bgImage), context);
    precacheImage(AssetImage(abcImage), context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit(AuthRepository(), SettingsManager())
        ..checkInternetAndAuth(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: _handleStateChanges,
        child: Scaffold(
          backgroundColor: const Color.fromRGBO(122, 34, 161, 1),
          body: _buildBody(),
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, SplashState state) async {
    if (state is SplashNoInternet) {
      CustomSnackbar.showSnackBar(context, state.message, color: Colors.red);
    } else if (state is SplashAuthenticated) {
      context.go('${HomeScreen.path}/${state.user}');
    } else if (state is SplashUnauthenticated) {
      await _precacheLoginImages(context);
      if (!context.mounted) return;
      context.go(
          '${LoginScreen.path}/${Uri.encodeComponent(bgImage)}/${Uri.encodeComponent(abcImage)}');
    } else if (state is SplashError) {
      CustomSnackbar.showSnackBar(context, state.message, color: Colors.red);
    }
  }

  Future<void> _precacheLoginImages(BuildContext context) async {
    await precacheImage(AssetImage(bgImage), context);
    if (!context.mounted) return;
    await precacheImage(AssetImage(abcImage), context);
  }

  Widget _buildBody() {
    return Center(
      child: Column(
        children: [
          const Spacer(flex: 2),
          Image.asset(
            'assets/images/splash/splash-screen-image.png',
            fit: BoxFit.contain,
            scale: ScreenUtils.isPortrait ? 1.0 : 6.0,
          ),
          const Spacer(),
          Text(
            'Welcome to Learn & Play!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: ScreenUtils.isPortrait
                  ? ScreenUtils.width * 0.07
                  : ScreenUtils.width * 0.05,
            ),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Text(
              'Dive into a colorful adventure where kids can explore letters, numbers, shapes, and more!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: ScreenUtils.isPortrait
                    ? ScreenUtils.width * 0.05
                    : ScreenUtils.width * 0.03,
              ),
            ),
          ),
          const Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }
}
