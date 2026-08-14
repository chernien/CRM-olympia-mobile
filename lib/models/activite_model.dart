import 'package:equatable/equatable.dart';
import 'workflow_model.dart';

/// Schéma d'une activité terrain — miroir de `ActiviteDefDto`.
///
/// Réutilise [FieldDef] du modèle des demandes plutôt que d'en redéfinir un
/// jumeau : c'est le même contrat côté serveur, et c'est ce qui permet au
/// `DynamicForm` déjà écrit d'afficher ces formulaires sans modification.
/// Une activité est plate — pas de phases : elle est saisie d'un bloc.
class ActiviteDef extends Equatable {
  /// Clé métier, ex. `visite_revendeur`.
  final String type;
  final String typeLabel;

  /// Champ portant le client / revendeur / prospect, ou null.
  final String? clientField;
  final List<FieldDef> champs;

  const ActiviteDef({
    required this.type,
    required this.typeLabel,
    this.clientField,
    this.champs = const [],
  });

  factory ActiviteDef.fromJson(Map<String, dynamic> json) => ActiviteDef(
        type: json['type'] as String? ?? '',
        typeLabel: json['typeLabel'] as String? ?? '',
        clientField: json['clientField'] as String?,
        champs: (json['champs'] as List? ?? [])
            .map((e) => FieldDef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [type];
}
