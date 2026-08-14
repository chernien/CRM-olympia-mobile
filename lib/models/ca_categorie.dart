/// Revenue for one article category (Intérieur / Extérieur / Olybat), resolved
/// server-side through Divalto: ENT → MOUV → ART → T012.
class CaCategorie {
  final String categorie; // raw ERP key ("" = uncategorised)
  final String libelle; // display label
  final double montant; // TND (HT)
  final int lignes; // number of article lines
  final double pct; // share of the total

  const CaCategorie({
    required this.categorie,
    required this.libelle,
    required this.montant,
    required this.lignes,
    required this.pct,
  });

  factory CaCategorie.fromJson(Map<String, dynamic> json) => CaCategorie(
        categorie: json['categorie'] as String? ?? '',
        libelle: json['libelle'] as String? ?? '',
        montant: (json['montant'] as num?)?.toDouble() ?? 0,
        lignes: (json['lignes'] as num?)?.toInt() ?? 0,
        pct: (json['pct'] as num?)?.toDouble() ?? 0,
      );
}

/// Revenue split by article category over a period.
class CaCategories {
  final double total;
  final List<CaCategorie> categories;

  const CaCategories({required this.total, required this.categories});

  factory CaCategories.fromJson(Map<String, dynamic> json) => CaCategories(
        total: (json['total'] as num?)?.toDouble() ?? 0,
        categories: ((json['categories'] as List?) ?? const [])
            .map((e) => CaCategorie.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
