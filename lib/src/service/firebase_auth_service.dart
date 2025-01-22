// lib/src/service/firebase_auth_service.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kidsplay/src/service/crashlytics_service.dart';
import 'package:kidsplay/src/service/analytics_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check internet connectivity
  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(
        e,
        stackTrace: stackTrace,
        reason: 'Error during Google sign-in',
      );
      return null;
    }
  }

  // Get current authenticated user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await AnalyticsService.logEvent(name: 'sign_out');
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(
        e,
        stackTrace: stackTrace,
        reason: 'Error signing out',
      );
    }
  }
}
