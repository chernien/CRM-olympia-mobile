import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  final String? id;
  final String codeClient;
  final String nomClient;
  final String? adresse;
  final String description;
  final String statut; // 'realisee' (auto) | 'annulee'
  final String? objectifId; // task objective this task fulfils
  final String? objectifTitre; // e.g. "Visite client"
  final String? pieceJointeUrl;
  final String? commercialId;
  final String? commercialNom;
  final String? numero; // auto-generated
  final DateTime? createdAt; // the task date (real creation time)

  const TaskModel({
    this.id,
    required this.codeClient,
    required this.nomClient,
    this.adresse,
    this.description = '',
    this.statut = 'realisee',
    this.objectifId,
    this.objectifTitre,
    this.pieceJointeUrl,
    this.commercialId,
    this.commercialNom,
    this.numero,
    this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id']?.toString(),
        codeClient: json['codeClient'] as String? ?? '',
        nomClient: json['nomClient'] as String? ?? '',
        adresse: json['adresse'] as String?,
        description: json['description'] as String? ?? '',
        statut: json['statut'] as String? ?? 'realisee',
        objectifId: json['objectifId']?.toString(),
        objectifTitre: json['objectifTitre'] as String?,
        pieceJointeUrl: json['pieceJointeUrl'] as String?,
        commercialId: json['commercialId']?.toString(),
        commercialNom: json['commercialNom'] as String?,
        numero: json['numero'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
      );

  @override
  List<Object?> get props => [id, codeClient, numero];
}
