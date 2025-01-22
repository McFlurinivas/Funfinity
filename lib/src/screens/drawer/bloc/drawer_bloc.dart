import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsplay/src/core/settings_manager.dart';
import 'package:kidsplay/src/hive/model/settings.dart';
import 'package:kidsplay/src/model/user_model.dart';
import 'package:kidsplay/src/repositories/auth_repository.dart';
import 'package:kidsplay/src/repositories/hive_repository.dart';

part 'drawer_event.dart';
part 'drawer_state.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  final AuthRepository authRepository;
  UserModel? _cachedUser;
  final SettingsManager settingsManager;
  final HiveRepository hiveRepository;
  DrawerBloc(this.authRepository, this.settingsManager, this.hiveRepository)
      : super(DrawerInitial()) {
    on<LoadUser>(_onLoadUsers);
    on<SignOut>(_onSignOut);
    on<SwitchToggled>(_onSwitchToggled);
  }

  Future<void> _onLoadUsers(LoadUser event, Emitter<DrawerState> emit) async {
    if (_cachedUser != null) {
      emit(DrawerLoaded(_cachedUser!));
      return;
    }
    try {
      emit(DrawerLoading());
      final user = await authRepository.getCurrentUserDetails();
      _cachedUser = user;
      emit(DrawerLoaded(user!));
    } catch (e) {
      emit(DrawerError('Failed to load users'));
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<DrawerState> emit) async {
    try {
      emit(DrawerLoading());
      settingsManager.playTapSound();
      hiveRepository.deleteMusic();
      settingsManager.stopBackgroundMusic();
      await authRepository.signOut();
      await hiveRepository.deleteUserProgress();
      emit(DrawerSignOut());
    } catch (e) {
      emit(DrawerError('Failed to sign out'));
    }
  }

  bool isBgMusicSwitched = true;
  bool isSfxMusicSwitched = true;
  bool isVibratingSwitched = true;

  // Toggle Background Music
  void toggleBgMusic(bool value) {
    isBgMusicSwitched = value;
    hiveRepository.putSettings(HiveSettings(
      isBgMusicPlaying: isBgMusicSwitched,
      isSfxMusicPlaying: isSfxMusicSwitched,
      isVibrating: isVibratingSwitched,
    ));

    if (isBgMusicSwitched) {
      settingsManager.playBackgroundMusic();
    } else {
      settingsManager.pauseBackgroundMusic();
    }
  }

  // Toggle Sound Effects (SFX)
  void toggleSfxMusic(bool value) {
    isSfxMusicSwitched = value;
    hiveRepository.putSettings(HiveSettings(
      isBgMusicPlaying: isBgMusicSwitched,
      isSfxMusicPlaying: isSfxMusicSwitched,
      isVibrating: isVibratingSwitched,
    ));
  }

  // Toggle Vibration
  void toggleVibration(bool value) {
    isVibratingSwitched = value;
    hiveRepository.putSettings(HiveSettings(
      isBgMusicPlaying: isBgMusicSwitched,
      isSfxMusicPlaying: isSfxMusicSwitched,
      isVibrating: isVibratingSwitched,
    ));
  }

  // Handle switch toggling
  void _onSwitchToggled(SwitchToggled event, Emitter<DrawerState> emit) {
    settingsManager.playTapSound();

    // Toggle based on switch type
    switch (event.switchType) {
      case SwitchType.bgMusic:
        toggleBgMusic(event.value);
        break;
      case SwitchType.sfxMusic:
        toggleSfxMusic(event.value);
        break;
      case SwitchType.vibration:
        toggleVibration(event.value);
        break;
    }

    emit(DrawerSwitchToggled(
      isBgMusicSwitched,
      isSfxMusicSwitched,
      isVibratingSwitched,
    ));
    add(LoadUser());
  }
}
