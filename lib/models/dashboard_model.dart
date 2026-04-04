import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_model.g.dart';

@JsonSerializable()
class DashboardModel extends Equatable {
  final CAData caMensuel;
  final CAData caTrimestriel;
  final StatsVisites statsVisites;
  final StatsTaches statsTaches;
  final double? objectifCA;
  final double? progressionObjectif;

  const DashboardModel({
    required this.caMensuel,
    required this.caTrimestriel,
    required this.statsVisites,
    required this.statsTaches,
    this.objectifCA,
    this.progressionObjectif,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardModelToJson(this);

  @override
  List<Object?> get props => [caMensuel, caTrimestriel];
}

@JsonSerializable()
class CAData extends Equatable {
  final double total;
  final double intern;
  final double extern;
  final double olybat;
  final List<CAPoint> points;

  const CAData({
    required this.total,
    required this.intern,
    required this.extern,
    required this.olybat,
    this.points = const [],
  });

  factory CAData.fromJson(Map<String, dynamic> json) =>
      _$CADataFromJson(json);

  Map<String, dynamic> toJson() => _$CADataToJson(this);

  @override
  List<Object?> get props => [total, intern, extern, olybat];
}

@JsonSerializable()
class CAPoint extends Equatable {
  final String label; // "Jan", "T1", etc.
  final double value;

  const CAPoint({required this.label, required this.value});

  factory CAPoint.fromJson(Map<String, dynamic> json) =>
      _$CAPointFromJson(json);

  Map<String, dynamic> toJson() => _$CAPointToJson(this);

  @override
  List<Object?> get props => [label, value];
}

@JsonSerializable()
class StatsVisites extends Equatable {
  final int moisEnCours;
  final int trimestreEnCours;

  const StatsVisites({
    required this.moisEnCours,
    required this.trimestreEnCours,
  });

  factory StatsVisites.fromJson(Map<String, dynamic> json) =>
      _$StatsVisitesFromJson(json);

  Map<String, dynamic> toJson() => _$StatsVisitesToJson(this);

  @override
  List<Object?> get props => [moisEnCours, trimestreEnCours];
}

@JsonSerializable()
class StatsTaches extends Equatable {
  final int moisEnCours;
  final int trimestreEnCours;
  final int enCoursDeTraitement;

  const StatsTaches({
    required this.moisEnCours,
    required this.trimestreEnCours,
    required this.enCoursDeTraitement,
  });

  factory StatsTaches.fromJson(Map<String, dynamic> json) =>
      _$StatsTachesFromJson(json);

  Map<String, dynamic> toJson() => _$StatsTachesToJson(this);

  @override
  List<Object?> get props => [moisEnCours, trimestreEnCours];
}
