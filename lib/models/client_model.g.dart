// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientModel _$ClientModelFromJson(Map<String, dynamic> json) => ClientModel(
  code: json['code'] as String,
  nom: json['nom'] as String,
  adresse: json['adresse'] as String?,
  ville: json['ville'] as String?,
  telephone: json['telephone'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$ClientModelToJson(ClientModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'nom': instance.nom,
      'adresse': instance.adresse,
      'ville': instance.ville,
      'telephone': instance.telephone,
      'email': instance.email,
    };
