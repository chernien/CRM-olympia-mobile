import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../core/utils/server_date.dart';
import 'workflow_model.dart';

part 'demande_model.g.dart';

PhaseDef? _phaseFromJson(Map<String, dynamic>? json) =>
    json == null ? null : PhaseDef.fromJson(json);
Map<String, dynamic>? _phaseToJson(PhaseDef? p) => null; // never sent back

// Le backend envoie de l'UTC sans suffixe `Z` : sans ces convertisseurs,
// json_serializable génère un `DateTime.parse` qui décale l'affichage d'une
// heure (voir ServerDate).
DateTime? _dateFromJson(Object? json) => ServerDate.tryParse(json);
Object? _dateToJson(DateTime? date) => ServerDate.toJson(date);
DateTime _requiredDateFromJson(Object? json) => ServerDate.parse(json);
Object _requiredDateToJson(DateTime date) => ServerDate.toJsonRequired(date);

@JsonSerializable()
class DemandeModel extends Equatable {
  final String? id;
  final String? numero; // auto-generated
  final int typeDemande; // 1-8
  final String statut;

  // Workflow progression (null once clôturée).
  final String? phaseActuelle;    // key of the pending phase
  final String? roleAttendu;      // wire role expected to act now
  final String? roleAttenduLabel; // French label of that role
  @JsonKey(fromJson: _phaseFromJson, toJson: _phaseToJson)
  final PhaseDef? phaseCourante;  // schema of the pending phase (detail only)

  final String? commercialId;
  final String? commercialNom;
  final String? nomClient;
  final String? codeClient;
  final Map<String, dynamic> formData; // phase-keyed accumulated data
  final List<String>? piecesJointes;
  final List<DemandeHistorique>? historique;
  final String? commentaire;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? createdAt;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? updatedAt;

  const DemandeModel({
    this.id,
    this.numero,
    required this.typeDemande,
    this.statut = 'nouvelle',
    this.phaseActuelle,
    this.roleAttendu,
    this.roleAttenduLabel,
    this.phaseCourante,
    this.commercialId,
    this.commercialNom,
    this.nomClient,
    this.codeClient,
    this.formData = const {},
    this.piecesJointes,
    this.historique,
    this.commentaire,
    this.createdAt,
    this.updatedAt,
  });

  // Aligned with the backend DemandeType enum (8 types). The API also sends a
  // resolved `typeLabel`; this getter is the offline fallback for display.
  String get typeLabel {
    switch (typeDemande) {
      case 1: return "Demande d'échantillons";
      case 2: return 'Réclamation';
      case 3: return 'Nouveau client';
      case 4: return 'Renouvellement showroom';
      case 5: return 'Nouveau showroom';
      case 6: return 'Formation';
      case 7: return 'Assistance chantier';
      case 8: return 'Support marketing';
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
  @JsonKey(
    name: 'dateAction',
    fromJson: _requiredDateFromJson,
    toJson: _requiredDateToJson,
  )
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
