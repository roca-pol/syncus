// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Juncture _$JunctureFromJson(Map<String, dynamic> json) => Juncture(
      id: json['id'] as String,
      trackURI: json['trackURI'] as String,
      microsecondTimestamp: json['microsecondTimestamp'] as int,
    );

Map<String, dynamic> _$JunctureToJson(Juncture instance) => <String, dynamic>{
      'id': instance.id,
      'trackURI': instance.trackURI,
      'microsecondTimestamp': instance.microsecondTimestamp,
    };
