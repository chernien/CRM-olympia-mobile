/// An objective (set by the admin) with the current commercial's attainment.
class ObjectifProgress {
  final String id;
  final String type;        // chiffre_affaire | tache
  final String titre;       // e.g. "Visite client"
  final double valeur;      // target (TND amount or a count)
  final String description;
  final String periode;     // mois | trimestre
  final double caRealise;   // realised value for that period (CA or task count)
  final double pct;         // caRealise / valeur * 100
  final bool celebrated;    // congrats already shown (server-side, once for ever)

  const ObjectifProgress({
    required this.id,
    required this.type,
    required this.titre,
    required this.valeur,
    required this.description,
    required this.periode,
    required this.caRealise,
    required this.pct,
    required this.celebrated,
  });

  bool get isMensuel => periode == 'mois';

  factory ObjectifProgress.fromJson(Map<String, dynamic> json) => ObjectifProgress(
        id: json['id']?.toString() ?? '',
        type: json['type'] as String? ?? '',
        titre: json['titre'] as String? ?? '',
        valeur: (json['valeur'] as num?)?.toDouble() ?? 0,
        description: json['description'] as String? ?? '',
        periode: json['periode'] as String? ?? 'mois',
        caRealise: (json['caRealise'] as num?)?.toDouble() ?? 0,
        pct: (json['pct'] as num?)?.toDouble() ?? 0,
        celebrated: json['celebrated'] as bool? ?? false,
      );
}
