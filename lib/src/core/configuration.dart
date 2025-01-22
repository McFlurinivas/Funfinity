import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Configuration {
  static late FirebaseOptions firebaseOptions;

  static Future<void> initializeConfigurations() async {
    await dotenv.load(fileName: "assets/env/.env");
    firebaseOptions = FirebaseOptions(
        apiKey: Platform.isAndroid
            ? dotenv.get('API_KEY_ANDROID')
            : dotenv.get('API_KEY_IOS'),
        appId: Platform.isAndroid
            ? dotenv.get('APP_ID_ANDROID')
            : dotenv.get('APP_ID_IOS'),
        messagingSenderId: dotenv.get('MESSAGING_SENDER_ID'),
        projectId: dotenv.get('PROJECT_ID'),
        iosBundleId: dotenv.get('IOS_BUNDLE_ID'),
        storageBucket: dotenv.get('STORAGE_BUCKET'),
        androidClientId: dotenv.get('ANDROID_CLIENT_ID'),
        iosClientId: dotenv.get('IOS_CLIENT_ID'));
  }
}
