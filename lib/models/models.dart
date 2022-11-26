import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'models.g.dart';

abstract class Identifiable {
  final String id;

  Identifiable({required this.id});
}

@immutable
@JsonSerializable()
class Juncture extends Equatable implements Identifiable {
  @override
  final String id;
  final String trackURI;
  final int microsecondTimestamp;

  const Juncture({
    required this.id,
    required this.trackURI,
    required this.microsecondTimestamp,
  });

  Juncture copyWith({
    String? trackURI,
    int? microsecondTimestamp,
  }) {
    return Juncture(
      id: id,
      trackURI: trackURI ?? this.trackURI,
      microsecondTimestamp: microsecondTimestamp ?? this.microsecondTimestamp,
    );
  }

  /// Deserializes the given `Map<String, dynamic>` into a [Juncture].
  static Juncture fromJson(Map<String, dynamic> json) =>
      _$JunctureFromJson(json);

  /// Converts this [Juncture] into a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() => _$JunctureToJson(this);

  @override
  List<Object?> get props => [id, trackURI, microsecondTimestamp];
}
