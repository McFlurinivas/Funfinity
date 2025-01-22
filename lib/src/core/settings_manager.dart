import 'package:flame_audio/flame_audio.dart';
import 'package:kidsplay/src/hive/model/settings.dart';
import 'package:kidsplay/src/repositories/hive_repository.dart';

class SettingsManager {
  static HiveSettings settings = HiveRepository().getSettings();

  static bool isBackgroundMusicPlaying = settings.isBgMusicPlaying;
  static bool isSfxPlaying = settings.isSfxMusicPlaying;
  static bool isVibrating = settings.isVibrating;

  Future<void> playBackgroundMusic() async {
    await FlameAudio.bgm.play('bg_music.mp3', volume: 0.1);
  }

  void initializeBackgroundMusic() {
    FlameAudio.bgm.initialize();
  }

  void resumeBackgroundMusic() {
    FlameAudio.bgm.resume();
  }

  void pauseBackgroundMusic() {
    FlameAudio.bgm.pause();
  }

  void stopBackgroundMusic() {
    FlameAudio.bgm.stop();
  }

  double get defaultVolume => isSfxPlaying ? 0.3 : 0.0;
  // Sound Effects
  void playTapSound() {
    FlameAudio.play('tap_sound.mp3', volume: defaultVolume);
  }

  void playLevelCompleted() {
    FlameAudio.play('level_complete.mp3', volume: defaultVolume);
  }

  void playAllLevelsCompleted() {
    FlameAudio.play('all_levels_complete.mp3', volume: defaultVolume);
  }

  void playLevelFailed() {
    FlameAudio.play('level_fail.mp3', volume: defaultVolume);
  }

  void playEraseSound() {
    FlameAudio.play('erase.mp3', volume: defaultVolume);
  }

  void dispose() {
    FlameAudio.bgm.dispose();
  }
}
