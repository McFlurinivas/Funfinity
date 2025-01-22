import 'package:hive/hive.dart';

part '../adapter/settings.g.dart';

@HiveType(typeId: 3)
class HiveSettings extends HiveObject {
  @HiveField(0)
  final bool isBgMusicPlaying;

  @HiveField(1)
  final bool isSfxMusicPlaying;

  @HiveField(2)
  final bool isVibrating;

  HiveSettings(
      {required this.isBgMusicPlaying,
      required this.isSfxMusicPlaying,
      required this.isVibrating});
}
