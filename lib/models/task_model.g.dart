// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  id: json['id'] as String?,
  codeClient: json['codeClient'] as String,
  nomClient: json['nomClient'] as String,
  adresse: json['adresse'] as String?,
  description: json['description'] as String,
  datePrevue: DateTime.parse(json['datePrevue'] as String),
  priorite: json['priorite'] as String? ?? 'normale',
  statut: json['statut'] as String? ?? 'en_cours_traitement',
  pieceJointeUrl: json['pieceJointeUrl'] as String?,
  commercialId: json['commercialId'] as String?,
  commercialNom: json['commercialNom'] as String?,
  numero: json['numero'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'id': instance.id,
  'codeClient': instance.codeClient,
  'nomClient': instance.nomClient,
  'adresse': instance.adresse,
  'description': instance.description,
  'datePrevue': instance.datePrevue.toIso8601String(),
  'priorite': instance.priorite,
  'statut': instance.statut,
  'pieceJointeUrl': instance.pieceJointeUrl,
  'commercialId': instance.commercialId,
  'commercialNom': instance.commercialNom,
  'numero': instance.numero,
  'createdAt': instance.createdAt?.toIso8601String(),
};
