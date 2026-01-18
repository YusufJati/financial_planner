// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiaryEntryModelAdapter extends TypeAdapter<DiaryEntryModel> {
  @override
  final int typeId = 6;

  @override
  DiaryEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiaryEntryModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      title: fields[2] as String,
      content: fields[3] as String,
      mood: fields[4] as String?,
      tags: (fields[5] as List).cast<String>(),
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DiaryEntryModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.mood)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
