import 'package:firebase_auth/firebase_auth.dart';
import 'package:kidsplay/src/model/user_model.dart';
import 'package:kidsplay/src/service/analytics_service.dart';
import 'package:kidsplay/src/service/crashlytics_service.dart';
import 'package:kidsplay/src/service/firebase_auth_service.dart';

class AuthRepository {
  final FirebaseAuthService _authService = FirebaseAuthService();

  Future<bool> isConnected() async {
    try {
      return await _authService.isConnected();
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Error checking connection status');
      rethrow;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      UserCredential? user = await _authService.signInWithGoogle();
      if (user != null) {
        UserModel userModel = UserModel(
          uid: user.user?.uid,
          name: user.user?.displayName,
          email: user.user?.email,
          photoUrl: user.user?.photoURL,
        );

        await AnalyticsService.setUserId(userModel.uid!);
        await AnalyticsService.logEvent(name: 'sign_in_with_google');
        return userModel;
      }
      return null;
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Error signing in with Google');
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUserDetails() async {
    try {
      User? user = _authService.getCurrentUser();
      if (user != null) {
        return UserModel(
          uid: user.uid,
          name: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
        );
      }
      return null;
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Error getting current user details');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      await AnalyticsService.logEvent(name: 'sign_out');
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e,
          stackTrace: stackTrace, reason: 'Error signing out');
      rethrow;
    }
  }
}
