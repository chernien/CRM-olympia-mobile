// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  nom: json['nom'] as String,
  prenom: json['prenom'] as String,
  role: json['role'] as String,
  zone: json['zone'] as String?,
  objectifCA: (json['objectifCA'] as num?)?.toDouble(),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'nom': instance.nom,
  'prenom': instance.prenom,
  'role': instance.role,
  'zone': instance.zone,
  'objectifCA': instance.objectifCA,
  'isActive': instance.isActive,
};
