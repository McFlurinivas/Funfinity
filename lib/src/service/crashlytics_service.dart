import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  static Future<void> initialize() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      logFlutterError(details);
    };
    if (!_crashlytics.isCrashlyticsCollectionEnabled) {
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
    }
  }

  static Future<void> logError(
    dynamic error, {
    dynamic stackTrace,
    String? reason,
    String? endpoint,
    String? requestBody,
    String? responseBody,
    String? callingPage,
  }) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: false,
      information: [
        if (endpoint != null) 'Endpoint: $endpoint',
        if (requestBody != null) 'Request Body: $requestBody',
        if (responseBody != null) 'Response Body: $responseBody',
        if (callingPage != null) 'Calling Page: $callingPage',
      ],
    );
  }

  static Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  static Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  static Future<void> setUserIdentifier(String identifier) async {
    await _crashlytics.setUserIdentifier(identifier);
  }

  static Future<void> logFlutterError(
      FlutterErrorDetails flutterErrorDetails) async {
    await _crashlytics.recordFlutterError(flutterErrorDetails);
  }
}
