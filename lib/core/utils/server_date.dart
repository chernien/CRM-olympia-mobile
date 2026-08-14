/// Parsing des horodatages renvoyés par l'API .NET.
///
/// **Le défaut corrigé ici.** Le backend sérialise ses `DateTime` en UTC mais
/// *sans* suffixe `Z` (`2026-08-04T09:58:38`). `DateTime.parse` considère alors
/// la chaîne comme une heure **locale** : en Tunisie (UTC+1), une notification
/// qui vient d'arriver s'affichait « il y a 1 h ».
///
/// Règle appliquée — la même que le web (`NotificationSheet.jsx`) : si la partie
/// horaire ne porte ni `Z` ni décalage explicite, la chaîne est traitée comme de
/// l'UTC, puis convertie en heure locale de l'appareil.
///
/// Un horodatage sans heure (`2026-08-04`) est laissé tel quel : une date seule
/// ne doit jamais glisser d'un jour à cause d'un fuseau.
///
/// Ne jamais réintroduire `DateTime.parse` / `DateTime.tryParse` directement sur
/// une valeur venant de l'API : passer systématiquement par [ServerDate].
class ServerDate {
  const ServerDate._();

  /// Parse une valeur JSON en `DateTime` **local**, ou `null` si illisible.
  static DateTime? tryParse(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(_withExplicitZone(raw))?.toLocal();
  }

  /// Variante non nullable, pour les champs obligatoires (`dateAction`).
  /// Retombe sur l'instant courant plutôt que de faire échouer toute la réponse.
  static DateTime parse(Object? value) => tryParse(value) ?? DateTime.now();

  /// Sérialisation retour : toujours en ISO 8601 UTC explicite.
  static String? toJson(DateTime? value) => value?.toUtc().toIso8601String();

  /// Variante non nullable, pour les champs obligatoires.
  static String toJsonRequired(DateTime value) =>
      value.toUtc().toIso8601String();

  /// Ajoute le `Z` manquant quand aucun fuseau n'est précisé.
  static String _withExplicitZone(String raw) {
    final separator = raw.indexOf(RegExp('[T ]'));
    if (separator == -1) return raw; // date seule : aucun fuseau à supposer
    final time = raw.substring(separator + 1);
    final hasZone = time.endsWith('Z') ||
        time.endsWith('z') ||
        time.contains('+') ||
        time.contains('-');
    return hasZone ? raw : '${raw}Z';
  }
}
