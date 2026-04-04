// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demande_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DemandeModel _$DemandeModelFromJson(Map<String, dynamic> json) => DemandeModel(
  id: json['id'] as String?,
  numero: json['numero'] as String?,
  typeDemande: (json['typeDemande'] as num).toInt(),
  statut: json['statut'] as String? ?? 'nouvelle',
  commercialId: json['commercialId'] as String?,
  commercialNom: json['commercialNom'] as String?,
  formData: json['formData'] as Map<String, dynamic>? ?? const {},
  piecesJointes: (json['piecesJointes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  historique: (json['historique'] as List<dynamic>?)
      ?.map((e) => DemandeHistorique.fromJson(e as Map<String, dynamic>))
      .toList(),
  commentaire: json['commentaire'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$DemandeModelToJson(DemandeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'numero': instance.numero,
      'typeDemande': instance.typeDemande,
      'statut': instance.statut,
      'commercialId': instance.commercialId,
      'commercialNom': instance.commercialNom,
      'formData': instance.formData,
      'piecesJointes': instance.piecesJointes,
      'historique': instance.historique,
      'commentaire': instance.commentaire,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

DemandeHistorique _$DemandeHistoriqueFromJson(Map<String, dynamic> json) =>
    DemandeHistorique(
      action: json['action'] as String,
      auteur: json['auteur'] as String?,
      date: DateTime.parse(json['date'] as String),
      commentaire: json['commentaire'] as String?,
    );

Map<String, dynamic> _$DemandeHistoriqueToJson(DemandeHistorique instance) =>
    <String, dynamic>{
      'action': instance.action,
      'auteur': instance.auteur,
      'date': instance.date.toIso8601String(),
      'commentaire': instance.commentaire,
    };
