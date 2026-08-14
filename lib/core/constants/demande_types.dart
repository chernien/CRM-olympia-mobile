import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Single source of truth for how a demande type is presented on mobile.
///
/// Mirrors the backend `DemandeType` enum (8 types). The list, the detail header
/// the type filter and the creation picker all read from here — they used to
/// carry three divergent maps, so the same type could show a different icon on
/// each screen and the filter sheet listed labels that no longer matched the
/// numbering (filtering "Réclamation" actually filtered "Nouveau client").
class DemandeTypes {
  DemandeTypes._();

  /// French labels, keyed by the wire value. Kept aligned with
  /// `Olympia.Api/Enums/DemandeType.cs`.
  static const Map<int, String> labels = {
    1: 'Demande d\'échantillons',
    2: 'Réclamation',
    3: 'Nouveau client',
    4: 'Renouvellement showroom',
    5: 'Nouveau showroom',
    6: 'Formation',
    7: 'Assistance chantier',
    8: 'Support marketing',
  };

  static const Map<int, IconData> _icons = {
    1: Icons.colorize_outlined,
    2: Icons.report_problem_outlined,
    3: Icons.person_add_outlined,
    4: Icons.store_outlined,
    5: Icons.storefront_outlined,
    6: Icons.school_outlined,
    7: Icons.construction_outlined,
    8: Icons.campaign_outlined,
  };

  static String label(int type) => labels[type] ?? 'Demande';

  static IconData icon(int type) => _icons[type] ?? Icons.article_outlined;

  /// Accent colour, derived from the type itself so a card keeps the same accent
  /// wherever it appears — the picker used to colour by list position instead.
  static Color color(int type) =>
      type.isOdd ? AppColors.primary : AppColors.secondary;

  /// Icon + accent in one call, for the card headers.
  static (Color, IconData) style(int type) => (color(type), icon(type));
}
