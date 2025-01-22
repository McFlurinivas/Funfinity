// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<HiveSettings> {
  @override
  final int typeId = 3;

  @override
  HiveSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSettings(
        isBgMusicPlaying: fields[0] as bool,
        isSfxMusicPlaying: fields[1] as bool,
        isVibrating: fields[2] as bool);
  }

  @override
  void write(BinaryWriter writer, HiveSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.isBgMusicPlaying)
      ..writeByte(1)
      ..write(obj.isSfxMusicPlaying)
      ..writeByte(2)
      ..write(obj.isVibrating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
