import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsplay/src/core/settings_manager.dart';

import 'package:kidsplay/src/screens/home/home_screen.dart';
import 'package:kidsplay/src/screens/login/bloc/login_bloc.dart';
import 'package:kidsplay/src/widgets/snackbar/custom_snackbar.dart';
import 'package:kidsplay/src/core/screen_utils.dart';

class LoginScreen extends StatefulWidget {
  final String bgImage;
  final String abcImage;

  const LoginScreen({
    super.key,
    required this.bgImage,
    required this.abcImage,
  });

  static const path = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.bgImage),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                scale: constraints.maxWidth > 600 ? 1.0 : 2.0,
              ),
            ),
            child: OrientationBuilder(
              builder: (context, orientation) {
                return ScreenUtils.isPortrait
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: _buildLogo(constraints)),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtils.x(5),
                                vertical: ScreenUtils.x(10)),
                            decoration: BoxDecoration(
                              borderRadius: orientation == Orientation.portrait
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(24),
                                      topRight: Radius.circular(24))
                                  : const BorderRadius.only(
                                      topLeft: Radius.circular(24),
                                      bottomLeft: Radius.circular(24)),
                              color: Colors.white.withOpacity(0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildDescription(constraints),
                                const SizedBox(height: 30),
                                _buildGoogleSignInButton(context, constraints),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: _buildLogo(constraints)),
                          Flexible(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtils.x(5),
                                  vertical: ScreenUtils.x(10)),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24)),
                                color: Colors.white.withOpacity(0.9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildDescription(constraints),
                                  _buildGoogleSignInButton(
                                      context, constraints),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo(BoxConstraints constraints) {
    return Image.asset(widget.abcImage,
        scale: ScreenUtils.isPortrait
            ? ScreenUtils.height * 0.00005
            : ScreenUtils.width * 0.0001);
  }

  Widget _buildDescription(BoxConstraints constraints) {
    return Column(
      children: [
        Text(
          "Let's Make Learning Exciting!",
          style: TextStyle(
            fontSize: ScreenUtils.width > 600
                ? ScreenUtils.width * 0.04
                : ScreenUtils.width * 0.08,
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          "Join us for interactive games, delightful stories, and creative drawing, all designed to spark curiosity and inspire young minds.",
          style: TextStyle(
            fontSize: constraints.maxWidth > 600
                ? constraints.maxWidth * 0.03
                : constraints.maxWidth * 0.06,
            color: Colors.brown,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(
      BuildContext context, BoxConstraints constraints) {
    return GestureDetector(
      onTap: () {
        SettingsManager().playTapSound();
        context.read<LoginBloc>().add(GoogleAuthSignInRequested());
      },
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          width: 268,
          height: 50,
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginFailure) {
                CustomSnackbar.showSnackBar(
                  context,
                  state.message,
                  color: Colors.red,
                );
              } else if (state is LoginSuccess) {
                CustomSnackbar.showSnackBar(
                  context,
                  "Success",
                  color: Colors.green,
                );
                context.pushReplacement('${HomeScreen.path}/${state.user.uid}');
              }
            },
            builder: (context, state) {
              if (state is LoginLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildGoogleSignInContent();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInContent() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage('assets/images/login/google.png'),
        ),
        SizedBox(width: 10),
        Text(
          'Sign up with Google',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 16),
      ],
    );
  }
}
