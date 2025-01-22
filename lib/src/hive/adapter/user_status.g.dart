// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/user_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserStatusAdapter extends TypeAdapter<HiveUserStatus> {
  @override
  final int typeId = 2;

  @override
  HiveUserStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveUserStatus(
      categoryID: fields[0] as String,
      levelID: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveUserStatus obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.categoryID)
      ..writeByte(1)
      ..write(obj.levelID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
