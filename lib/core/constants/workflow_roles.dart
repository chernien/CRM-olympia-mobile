/// Mobile is field-only for the demandes workflow: only the Commercial and the
/// Technicien treat demandes on the phone. The three back-office roles below
/// use the web back-office instead and are shown a redirect message on mobile.
const Set<String> kOfficeRoles = {
  'directioncommerciale',
  'responsabletechnique',
  'servicerecouvrement',
  'prod',
};

/// True if [role] (wire value, any case) is a back-office role → web-only on mobile.
bool isOfficeRole(String? role) => kOfficeRoles.contains((role ?? '').toLowerCase());
