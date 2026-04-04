import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel extends Equatable {
  final String? id;
  final String codeClient;
  final String nomClient;
  final String? adresse;
  final String description;
  final DateTime datePrevue;
  final String priorite; // 'normale' | 'haute' | 'urgente'
  final String statut; // 'en_cours_traitement' | 'realisee' | 'annulee'
  final String? pieceJointeUrl;
  final String? commercialId;
  final String? commercialNom;
  final String? numero; // auto-generated
  final DateTime? createdAt;

  const TaskModel({
    this.id,
    required this.codeClient,
    required this.nomClient,
    this.adresse,
    required this.description,
    required this.datePrevue,
    this.priorite = 'normale',
    this.statut = 'en_cours_traitement',
    this.pieceJointeUrl,
    this.commercialId,
    this.commercialNom,
    this.numero,
    this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  @override
  List<Object?> get props => [id, codeClient, numero];
}
