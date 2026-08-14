import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String statut;

  const StatusBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _getStatusInfo(statut);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// French label for a status. Exposed so the demande detail header can reuse
  /// it instead of keeping a second mapping that drifted out of sync.
  static String labelFor(String statut) => _getStatusInfo(statut).$2;

  static (Color, String) _getStatusInfo(String statut) {
    return switch (statut) {
      AppConstants.taskStatusEnCours => (AppColors.taskEnCours, 'En cours'),
      AppConstants.taskStatusRealisee => (AppColors.taskRealisee, 'Réalisée'),
      AppConstants.taskStatusAnnulee => (AppColors.taskAnnulee, 'Annulée'),
      AppConstants.demandeStatusNouvelle => (AppColors.demandeNouvelle, 'Nouvelle'),
      AppConstants.demandeStatusEnValidation => (AppColors.demandeEnValidation, 'En validation'),
      AppConstants.demandeStatusValidee => (AppColors.demandeValidee, 'Validée'),
      AppConstants.demandeStatusEnProduction => (AppColors.demandeEnProduction, 'En production'),
      AppConstants.demandeStatusTraitee => (AppColors.demandeTraitee, 'Traitée'),
      AppConstants.demandeStatusCloturee => (AppColors.demandeCloturee, 'Clôturée'),
      AppConstants.demandeStatusRefusee => (AppColors.demandeRefusee, 'Refusée'),
      _ => (Colors.grey, statut),
    };
  }
}
