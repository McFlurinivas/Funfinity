import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kidsplay/src/core/settings_manager.dart';
import 'package:kidsplay/src/model/user_model.dart';
import 'package:kidsplay/src/repositories/auth_repository.dart';
import 'package:kidsplay/src/repositories/hive_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;
  final HiveRepository hiveRepository;
  LoginBloc(this.authRepository, this.hiveRepository) : super(LoginInitial()) {
    on<GoogleAuthSignInRequested>(_mapGoogleAuthSignInRequestedToState);
  }

  Future<void> _mapGoogleAuthSignInRequestedToState(
      GoogleAuthSignInRequested event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    final user = await authRepository.signInWithGoogle();
    final hiveSettings = hiveRepository.getSettings();
    SettingsManager.isBackgroundMusicPlaying = hiveSettings.isBgMusicPlaying;
    if (user != null) {
      emit(LoginSuccess(user));
    } else {
      emit(const LoginFailure('Login failed'));
    }
  }
}
