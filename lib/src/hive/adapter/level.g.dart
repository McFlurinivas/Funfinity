// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/level.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LevelAdapter extends TypeAdapter<HiveLevel> {
  @override
  final int typeId = 1;

  @override
  HiveLevel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveLevel(
      id: fields[0] as String,
      question: fields[1] as String,
      answer: fields[2] as String,
      options: (fields[3] as List).cast<String>(),
      type: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveLevel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.answer)
      ..writeByte(3)
      ..write(obj.options)
      ..writeByte(4)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
