import 'package:equatable/equatable.dart';

/// One suggestion from an ERP lookup (Divalto client or article).
///
/// [label] is both what the user sees AND what gets stored in the demande field —
/// the client NOM, or "REF DES" for an article. Keeping the stored value a plain
/// string is what lets demandes captured before the autocomplete existed keep
/// rendering in the list, detail and history screens.
///
/// [code] is the ERP identity (TIERS / REF), shown as a secondary line for clients
/// so two similar names can be told apart.
///
/// Hand-parsed (no build_runner): read-only, two fields, no round trip to JSON.
class ErpRef extends Equatable {
  final String label;
  final String? code;

  const ErpRef({required this.label, this.code});

  /// `{ tiers, nom }` — a client is always displayed by its name.
  factory ErpRef.fromClientJson(Map<String, dynamic> json) => ErpRef(
        label: json['nom'] as String? ?? '',
        code: json['tiers'] as String?,
      );

  /// `{ ref, designation, libelle }` — an article is always displayed as "REF DES".
  factory ErpRef.fromArticleJson(Map<String, dynamic> json) => ErpRef(
        label: json['libelle'] as String? ?? '',
        code: null, // the reference is already inside the label
      );

  /// `{ id, nom }` — a technician is displayed AND stored by name, like the ERP
  /// refs above, so the demande field keeps holding a plain string. The id is kept
  /// as the option key only; it never reaches the stored form data.
  factory ErpRef.fromTechnicienJson(Map<String, dynamic> json) => ErpRef(
        label: json['nom'] as String? ?? '',
        code: json['id'] as String?,
      );

  @override
  List<Object?> get props => [label, code];
}
