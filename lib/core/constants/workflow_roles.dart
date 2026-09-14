/// Mobile is field-only for the demandes workflow: only the Commercial and the
/// Technicien treat demandes on the phone. The back-office roles below use the
/// web back-office instead and are shown a redirect message on mobile.
const Set<String> kOfficeRoles = {
  'directioncommerciale',
  'responsabletechnique',
  'servicerecouvrement',
  'prod',
  // ADV confirme la commande ERP depuis le back-office, comme la production :
  // sa phase affiche un numéro que Divalto écrit en base, et elle se traite
  // devant un poste, pas sur le terrain (réunion client du 11/09/2026).
  'adv',
};

/// True if [role] (wire value, any case) is a back-office role → web-only on mobile.
bool isOfficeRole(String? role) => kOfficeRoles.contains((role ?? '').toLowerCase());
