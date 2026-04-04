// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardModel _$DashboardModelFromJson(Map<String, dynamic> json) =>
    DashboardModel(
      caMensuel: CAData.fromJson(json['caMensuel'] as Map<String, dynamic>),
      caTrimestriel: CAData.fromJson(
        json['caTrimestriel'] as Map<String, dynamic>,
      ),
      statsVisites: StatsVisites.fromJson(
        json['statsVisites'] as Map<String, dynamic>,
      ),
      statsTaches: StatsTaches.fromJson(
        json['statsTaches'] as Map<String, dynamic>,
      ),
      objectifCA: (json['objectifCA'] as num?)?.toDouble(),
      progressionObjectif: (json['progressionObjectif'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$DashboardModelToJson(DashboardModel instance) =>
    <String, dynamic>{
      'caMensuel': instance.caMensuel,
      'caTrimestriel': instance.caTrimestriel,
      'statsVisites': instance.statsVisites,
      'statsTaches': instance.statsTaches,
      'objectifCA': instance.objectifCA,
      'progressionObjectif': instance.progressionObjectif,
    };

CAData _$CADataFromJson(Map<String, dynamic> json) => CAData(
  total: (json['total'] as num).toDouble(),
  intern: (json['intern'] as num).toDouble(),
  extern: (json['extern'] as num).toDouble(),
  olybat: (json['olybat'] as num).toDouble(),
  points:
      (json['points'] as List<dynamic>?)
          ?.map((e) => CAPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CADataToJson(CAData instance) => <String, dynamic>{
  'total': instance.total,
  'intern': instance.intern,
  'extern': instance.extern,
  'olybat': instance.olybat,
  'points': instance.points,
};

CAPoint _$CAPointFromJson(Map<String, dynamic> json) => CAPoint(
  label: json['label'] as String,
  value: (json['value'] as num).toDouble(),
);

Map<String, dynamic> _$CAPointToJson(CAPoint instance) => <String, dynamic>{
  'label': instance.label,
  'value': instance.value,
};

StatsVisites _$StatsVisitesFromJson(Map<String, dynamic> json) => StatsVisites(
  moisEnCours: (json['moisEnCours'] as num).toInt(),
  trimestreEnCours: (json['trimestreEnCours'] as num).toInt(),
);

Map<String, dynamic> _$StatsVisitesToJson(StatsVisites instance) =>
    <String, dynamic>{
      'moisEnCours': instance.moisEnCours,
      'trimestreEnCours': instance.trimestreEnCours,
    };

StatsTaches _$StatsTachesFromJson(Map<String, dynamic> json) => StatsTaches(
  moisEnCours: (json['moisEnCours'] as num).toInt(),
  trimestreEnCours: (json['trimestreEnCours'] as num).toInt(),
  enCoursDeTraitement: (json['enCoursDeTraitement'] as num).toInt(),
);

Map<String, dynamic> _$StatsTachesToJson(StatsTaches instance) =>
    <String, dynamic>{
      'moisEnCours': instance.moisEnCours,
      'trimestreEnCours': instance.trimestreEnCours,
      'enCoursDeTraitement': instance.enCoursDeTraitement,
    };
