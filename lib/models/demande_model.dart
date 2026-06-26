import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'demande_model.g.dart';

@JsonSerializable()
class DemandeModel extends Equatable {
  final String? id;
  final String? numero; // auto-generated
  final int typeDemande; // 1-9
  final String statut;
  final String? commercialId;
  final String? commercialNom;
  final Map<String, dynamic> formData; // Dynamic fields per type
  final List<String>? piecesJointes;
  final List<DemandeHistorique>? historique;
  final String? commentaire;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DemandeModel({
    this.id,
    this.numero,
    required this.typeDemande,
    this.statut = 'nouvelle',
    this.commercialId,
    this.commercialNom,
    this.formData = const {},
    this.piecesJointes,
    this.historique,
    this.commentaire,
    this.createdAt,
    this.updatedAt,
  });

  String get typeLabel {
    switch (typeDemande) {
      case 1: return "Demande d'échantillons";
      case 2: return "Échantillons avec application";
      case 3: return 'Réclamation';
      case 4: return 'Création nouveau client';
      case 5: return 'Renouvellement showroom';
      case 6: return 'Demande de formation';
      case 7: return 'Assistance chantier';
      case 8: return 'Machine à teinter';
      case 9: return 'Accessoires marketing';
      default: return 'Demande inconnue';
    }
  }

  factory DemandeModel.fromJson(Map<String, dynamic> json) =>
      _$DemandeModelFromJson(json);

  Map<String, dynamic> toJson() => _$DemandeModelToJson(this);

  @override
  List<Object?> get props => [id, numero, typeDemande];
}

@JsonSerializable()
class DemandeHistorique extends Equatable {
  final String action;
  final String? auteur;
  // Backend serializes this field as "dateAction" (DemandeHistoriqueDto).
  @JsonKey(name: 'dateAction')
  final DateTime date;
  final String? commentaire;

  const DemandeHistorique({
    required this.action,
    this.auteur,
    required this.date,
    this.commentaire,
  });

  factory DemandeHistorique.fromJson(Map<String, dynamic> json) =>
      _$DemandeHistoriqueFromJson(json);

  Map<String, dynamic> toJson() => _$DemandeHistoriqueToJson(this);

  @override
  List<Object?> get props => [action, date];
}
