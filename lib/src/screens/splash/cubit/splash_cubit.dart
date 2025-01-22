import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsplay/src/core/settings_manager.dart';
import 'package:kidsplay/src/model/user_model.dart';
import 'package:kidsplay/src/repositories/auth_repository.dart';
part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final AuthRepository authRepository;
  final SettingsManager settingsManager;

  SplashCubit(this.authRepository, this.settingsManager)
      : super(SplashInitial());

  Future<void> checkInternetAndAuth() async {
    try {
      settingsManager.initializeBackgroundMusic();
      await Future.delayed(const Duration(seconds: 2));
      final UserModel? user = await authRepository.getCurrentUserDetails();
      if (user == null) {
        emit(SplashUnauthenticated());
      } else {
        String? userId = user.uid;
        emit(SplashAuthenticated(userId!));
      }
    } catch (e) {
      emit(SplashError(e.toString()));
    }
  }
}
