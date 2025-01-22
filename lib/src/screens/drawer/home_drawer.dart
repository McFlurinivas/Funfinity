import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kidsplay/src/core/settings_manager.dart';
import 'package:kidsplay/src/core/screen_utils.dart';
import 'package:kidsplay/src/repositories/auth_repository.dart';
import 'package:kidsplay/src/repositories/hive_repository.dart';
import 'package:kidsplay/src/screens/drawer/bloc/drawer_bloc.dart';
import 'package:kidsplay/src/screens/login/login_screen.dart';
import 'package:kidsplay/src/widgets/progress_indicator/custom_progress_indicator.dart';
import 'package:kidsplay/src/widgets/snackbar/custom_snackbar.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final String bgImage = 'assets/images/login/login-background.jpg';

  final String abcImage = 'assets/images/login/login-abc.png';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DrawerBloc(AuthRepository(), SettingsManager(), HiveRepository())
            ..add(LoadUser()),
      child: BlocConsumer<DrawerBloc, DrawerState>(
        listener: (context, state) {
          _handleStateChanges(context, state);
        },
        builder: (context, state) {
          return _buildIconButton(context, state);
        },
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, DrawerState state) {
    if (state is DrawerLoaded) {
      return InkWell(
        onTap: () => _showUserDetailsDialog(context, state),
        child: _buildUserImage(state.users.photoUrl!, context, 24),
      );
    }
    return const Icon(Icons.account_circle, size: 24);
  }

  void _showUserDetailsDialog(BuildContext context, DrawerState state) {
    SettingsManager().playTapSound();
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildDialogContent(context, state, setState),
                  ),
                  Transform.translate(
                    offset: const Offset(8, -8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      width: 32,
                      height: 32,
                      child: GestureDetector(
                        onTap: () {
                          SettingsManager().playTapSound();
                          Navigator.of(context).pop();
                        },
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogContent(
      BuildContext context, DrawerState state, StateSetter setState) {
    if (state is DrawerLoading) {
      return const CustomProgressIndicator();
    }

    if (state is DrawerLoaded) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _buildUserImage(state.users.photoUrl!, context, 36),
            title: Text(
              state.users.name!.split(' ')[0],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle:
                Text(state.users.email!, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(height: 10),
          const Divider(height: 0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Background Music Switch
              _buildSwitchRow(
                label: 'Music',
                switchKey:
                    ValueKey<bool>(SettingsManager.isBackgroundMusicPlaying),
                switchValue: SettingsManager.isBackgroundMusicPlaying,
                onChanged: (value) {
                  setState(() {
                    SettingsManager.isBackgroundMusicPlaying = value;
                  });
                  BlocProvider.of<DrawerBloc>(context).add(
                    SwitchToggled(
                      switchType: SwitchType.bgMusic,
                      value: SettingsManager.isBackgroundMusicPlaying,
                    ),
                  );
                },
              ),
              const Divider(
                color: Colors.black12,
                height: 0,
              ),
              // SFX Switch
              _buildSwitchRow(
                label: 'SFX',
                switchKey: ValueKey<bool>(SettingsManager.isSfxPlaying),
                switchValue: SettingsManager.isSfxPlaying,
                onChanged: (value) {
                  setState(() {
                    SettingsManager.isSfxPlaying = value;
                  });
                  BlocProvider.of<DrawerBloc>(context).add(
                    SwitchToggled(
                      switchType: SwitchType.sfxMusic,
                      value: SettingsManager.isSfxPlaying,
                    ),
                  );
                },
              ),
              const Divider(
                color: Colors.black12,
                height: 0,
              ),
              // Vibration Switch
              _buildSwitchRow(
                label: 'Vibration',
                switchKey: ValueKey<bool>(SettingsManager.isVibrating),
                switchValue: SettingsManager.isVibrating,
                onChanged: (value) {
                  setState(() {
                    SettingsManager.isVibrating = value;
                  });
                  BlocProvider.of<DrawerBloc>(context).add(
                    SwitchToggled(
                      switchType: SwitchType.vibration,
                      value: SettingsManager.isVibrating,
                    ),
                  );
                  if (value) HapticFeedback.heavyImpact();
                },
              ),
            ],
          ),
          const Divider(height: 0),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ButtonStyle(
              elevation: WidgetStateProperty.all(2),
              backgroundColor: WidgetStateProperty.all(Colors.brown),
              minimumSize: WidgetStateProperty.all(
                Size(double.infinity, ScreenUtils.height * 0.06),
              ),
            ),
            icon: Icon(
              Icons.logout,
              color: Colors.white,
              size: ScreenUtils.isPortrait
                  ? ScreenUtils.width * 0.05
                  : ScreenUtils.width * 0.03,
            ),
            label: Text(
              "Log Out",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtils.isPortrait
                      ? ScreenUtils.width * 0.05
                      : ScreenUtils.width * 0.03),
            ),
            onPressed: () {
              setState(() {
                BlocProvider.of<DrawerBloc>(context).add(SignOut());
                Navigator.pop(context);
              });
            },
          ),
        ],
      );
    }

    return const Center(
      child: Text('Unable to load user details'),
    );
  }

  Widget _buildUserImage(String imageUrl, BuildContext context, double radius) {
    return Container(
      height: radius * 2,
      width: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.brown, width: 2),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        color: Colors.brown.withOpacity(0.5),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  void _handleStateChanges(BuildContext context, DrawerState state) async {
    if (state is DrawerSignOut) {
      context.go(
          '${LoginScreen.path}/${Uri.encodeComponent(bgImage)}/${Uri.encodeComponent(abcImage)}');
      CustomSnackbar.showSnackBar(
        context,
        'Signed out successfully',
        color: Colors.green,
      );
    } else if (state is DrawerError) {
      CustomSnackbar.showSnackBar(
        context,
        state.errorMessage,
        color: Colors.red,
      );
    }
  }

  Widget _buildSwitchRow({
    required String label,
    required Key switchKey,
    required bool switchValue,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Transform.scale(
            scale: 1,
            child: Switch(
              key: switchKey,
              value: switchValue,
              onChanged: onChanged,
              activeColor: Colors.grey,
              activeTrackColor: Colors.brown,
              inactiveThumbColor: Colors.brown,
              inactiveTrackColor: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
