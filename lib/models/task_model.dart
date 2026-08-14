import 'package:equatable/equatable.dart';

import '../core/utils/server_date.dart';

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
  final String? numero; // auto-generated — c'est LA « référence » de l'activité
  final DateTime? createdAt; // the task date (real creation time)

  /// Type d'activité terrain (`visite_revendeur`…). Null pour les tâches
  /// enregistrées avant le module « Suivi des commerciaux ».
  final String? typeActivite;
  final String? typeActiviteLabel;

  /// Valeurs saisies pour ce type, clefées par nom de champ du catalogue.
  final Map<String, dynamic> fields;
  final String? heureArrivee;
  final String? heureDepart;
  final int? dureeMinutes;

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
    this.typeActivite,
    this.typeActiviteLabel,
    this.fields = const {},
    this.heureArrivee,
    this.heureDepart,
    this.dureeMinutes,
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
        // UTC sans `Z` côté backend : ServerDate rétablit le fuseau (voir la classe).
        createdAt: ServerDate.tryParse(json['createdAt']),
        typeActivite: json['typeActivite'] as String?,
        typeActiviteLabel: json['typeActiviteLabel'] as String?,
        fields: (json['formData'] as Map?)?.cast<String, dynamic>() ?? const {},
        heureArrivee: json['heureArrivee'] as String?,
        heureDepart: json['heureDepart'] as String?,
        dureeMinutes: (json['dureeMinutes'] as num?)?.toInt(),
      );

  @override
  List<Object?> get props => [id, codeClient, numero];
}
