import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Secondary
  static const Color secondary = Color(0xFF7C3AED);

  // Status - Tâches
  static const Color taskEnCours = Color(0xFFF59E0B);       // Jaune
  static const Color taskRealisee = Color(0xFF059669);       // Vert foncé
  static const Color taskAnnulee = Color(0xFF6B7280);        // Gris

  // Status - Demandes
  static const Color demandeNouvelle = Color(0xFF3B82F6);    // Bleu
  static const Color demandeEnValidation = Color(0xFFF97316); // Orange
  static const Color demandeValidee = Color(0xFF4ADE80);     // Vert clair
  static const Color demandeEnTraitement = Color(0xFFF59E0B); // Jaune
  static const Color demandeTraitee = Color(0xFF059669);     // Vert foncé
  static const Color demandeCloturee = Color(0xFF6B7280);    // Gris
  static const Color demandeRefusee = Color(0xFFEF4444);     // Rouge

  // Priorities
  static const Color priorityNormale = Color(0xFF3B82F6);
  static const Color priorityHaute = Color(0xFFF97316);
  static const Color priorityUrgente = Color(0xFFEF4444);

  // CA Segments
  static const Color segmentIntern = Color(0xFF2563EB);
  static const Color segmentExtern = Color(0xFF7C3AED);
  static const Color segmentOlybat = Color(0xFFF59E0B);

  // Neutral
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Feedback
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
