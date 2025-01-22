import 'package:flutter/material.dart';
import 'package:kidsplay/src/core/settings_manager.dart';

import 'package:kidsplay/src/core/routes.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SettingsManager().dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      SettingsManager().pauseBackgroundMusic();
    } else if (state == AppLifecycleState.resumed &&
        SettingsManager.isBackgroundMusicPlaying) {
      SettingsManager().resumeBackgroundMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KidsPlay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Atma',
      ),
      routerConfig: AppRoute.routes,
    );
  }
}
