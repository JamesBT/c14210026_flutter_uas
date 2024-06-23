// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PinAdapter extends TypeAdapter<Pin> {
  @override
  final int typeId = 1;

  @override
  Pin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pin(
      fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Pin obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.pin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PinAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
