import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'client_model.g.dart';

@JsonSerializable()
class ClientModel extends Equatable {
  final String code;
  final String nom;
  final String? adresse;
  final String? ville;
  final String? telephone;
  final String? email;

  const ClientModel({
    required this.code,
    required this.nom,
    this.adresse,
    this.ville,
    this.telephone,
    this.email,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) =>
      _$ClientModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClientModelToJson(this);

  @override
  List<Object?> get props => [code, nom];
}
