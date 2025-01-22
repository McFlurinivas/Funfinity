import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:kidsplay/src/app.dart';
import 'package:kidsplay/src/core/configuration.dart';

import 'package:kidsplay/src/hive/box/category_box.dart';
import 'package:kidsplay/src/hive/box/level_box.dart';
import 'package:kidsplay/src/hive/box/settings_box.dart';
import 'package:kidsplay/src/hive/box/user_status_box.dart';
import 'package:kidsplay/src/hive/model/category.dart';
import 'package:kidsplay/src/hive/model/level.dart';
import 'package:kidsplay/src/hive/model/settings.dart';
import 'package:kidsplay/src/hive/model/user_status.dart';

import 'package:kidsplay/src/service/analytics_service.dart';
import 'package:kidsplay/src/service/crashlytics_service.dart';
import 'package:kidsplay/src/service/performance_service.dart';

FutureOr<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(LevelAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(UserStatusAdapter());
  Hive.registerAdapter(SettingsAdapter());

  levelBox = await Hive.openBox<List>('levelBox');
  categoryBox = await Hive.openBox<HiveCategory>('categoryBox');
  userStatusBox = await Hive.openBox<HiveUserStatus>('userStatusBox');
  settingsBox = await Hive.openBox<HiveSettings>('musicBox');

  await Configuration.initializeConfigurations();
  await Firebase.initializeApp(
    options: Configuration.firebaseOptions,
  );

  await Future.wait([
    CrashlyticsService.initialize(),
    PerformanceService.initialize(),
    AnalyticsService.initialize(),
  ]);
  runApp(const MyApp());
}
