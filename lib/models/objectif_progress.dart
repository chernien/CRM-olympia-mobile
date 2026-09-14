/// An objective (set by the admin) with the current commercial's attainment.
///
/// [valeur] est LA PART DE CE COMMERCIAL dans l'objectif global, jamais la cible
/// de toute l'équipe (réunion client du 11/09/2026 : « Ahmed voit 1 000 000, pas
/// 4 500 000 »). L'API ne transmet d'ailleurs pas la cible globale sur cette
/// route — ce qui n'est pas envoyé ne peut pas être affiché par erreur.
class ObjectifProgress {
  final String id;
  final String type;        // chiffre_affaire | tache
  final String titre;       // e.g. "Visite client"
  final double valeur;      // la PART de ce commercial (TND ou un nombre)
  final String description;
  final String periode;     // mois | trimestre
  final double caRealise;   // realised value for that period (CA or task count)
  final double pct;         // caRealise / valeur * 100

  /// Faux tant que l'admin n'a pas attribué de part à ce commercial. L'écran
  /// affiche alors « en attente de répartition » plutôt qu'un pourcentage
  /// calculé sur une cible qui n'existe pas.
  final bool repartie;
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
    required this.repartie,
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
        // Champ ABSENT = serveur antérieur à la répartition : il renvoie alors
        // la cible GLOBALE de l'équipe dans `valeur`. La présenter comme
        // l'objectif personnel du commercial serait précisément le défaut que
        // la répartition corrige — 4 500 000 affichés à quelqu'un qui en porte
        // 1 000 000. Dans le doute on ne revendique donc RIEN : l'écran dit
        // « en attente », ce qui est vrai tant que ce serveur n'est pas à jour.
        repartie: json['repartie'] as bool? ?? false,
        celebrated: json['celebrated'] as bool? ?? false,
      );
}
