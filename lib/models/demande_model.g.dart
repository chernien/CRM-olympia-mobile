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
  phaseActuelle: json['phaseActuelle'] as String?,
  roleAttendu: json['roleAttendu'] as String?,
  roleAttenduLabel: json['roleAttenduLabel'] as String?,
  phaseCourante: _phaseFromJson(json['phaseCourante'] as Map<String, dynamic>?),
  commercialId: json['commercialId'] as String?,
  commercialNom: json['commercialNom'] as String?,
  nomClient: json['nomClient'] as String?,
  codeClient: json['codeClient'] as String?,
  formData: json['formData'] as Map<String, dynamic>? ?? const {},
  piecesJointes: (json['piecesJointes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  historique: (json['historique'] as List<dynamic>?)
      ?.map((e) => DemandeHistorique.fromJson(e as Map<String, dynamic>))
      .toList(),
  commentaire: json['commentaire'] as String?,
  createdAt: _dateFromJson(json['createdAt']),
  updatedAt: _dateFromJson(json['updatedAt']),
);

Map<String, dynamic> _$DemandeModelToJson(DemandeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'numero': instance.numero,
      'typeDemande': instance.typeDemande,
      'statut': instance.statut,
      'phaseActuelle': instance.phaseActuelle,
      'roleAttendu': instance.roleAttendu,
      'roleAttenduLabel': instance.roleAttenduLabel,
      'phaseCourante': _phaseToJson(instance.phaseCourante),
      'commercialId': instance.commercialId,
      'commercialNom': instance.commercialNom,
      'nomClient': instance.nomClient,
      'codeClient': instance.codeClient,
      'formData': instance.formData,
      'piecesJointes': instance.piecesJointes,
      'historique': instance.historique,
      'commentaire': instance.commentaire,
      'createdAt': _dateToJson(instance.createdAt),
      'updatedAt': _dateToJson(instance.updatedAt),
    };

DemandeHistorique _$DemandeHistoriqueFromJson(Map<String, dynamic> json) =>
    DemandeHistorique(
      action: json['action'] as String,
      auteur: json['auteur'] as String?,
      date: _requiredDateFromJson(json['dateAction']),
      commentaire: json['commentaire'] as String?,
    );

Map<String, dynamic> _$DemandeHistoriqueToJson(DemandeHistorique instance) =>
    <String, dynamic>{
      'action': instance.action,
      'auteur': instance.auteur,
      'dateAction': _requiredDateToJson(instance.date),
      'commentaire': instance.commentaire,
    };
