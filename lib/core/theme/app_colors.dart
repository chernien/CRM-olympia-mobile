import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary (Adjusted to match the softer blue in the screenshot)
  static const Color primary = Color(0xFF5A8CFF);
  static const Color primaryLight = Color(0xFF8FB4FF);
  static const Color primaryDark = Color(0xFF3B6BDB);

  // Secondary
  static const Color secondary = Color(0xFFE470E0); // Pinkish/Purple from screenshot
  
  // Pink accent
  static const Color accentPink = Color(0xFFF472B6);

  // Status - Tâches (Restored)
  static const Color taskEnCours = Color(0xFFF59E0B);       // Jaune
  static const Color taskRealisee = Color(0xFF059669);      // Vert foncé
  static const Color taskAnnulee = Color(0xFF6B7280);       // Gris

  // Status - Demandes (Restored)
  static const Color demandeNouvelle = Color(0xFF3B82F6);    // Bleu
  static const Color demandeEnValidation = Color(0xFFF97316); // Orange
  static const Color demandeValidee = Color(0xFF4ADE80);     // Vert clair
  static const Color demandeEnTraitement = Color(0xFFF59E0B); // Jaune
  static const Color demandeTraitee = Color(0xFF059669);     // Vert foncé
  static const Color demandeCloturee = Color(0xFF6B7280);    // Gris
  static const Color demandeRefusee = Color(0xFFEF4444);     // Rouge

  // Priorities (Restored)
  static const Color priorityNormale = Color(0xFF3B82F6);
  static const Color priorityHaute = Color(0xFFF97316);
  static const Color priorityUrgente = Color(0xFFEF4444);

  // CA Segments
  static const Color segmentIntern = Color(0xFF5A8CFF);
  static const Color segmentExtern = Color(0xFFE470E0);
  static const Color segmentOlybat = Color(0xFFF59E0B);

  // Neutral (Crucial for the soft UI look)
  static const Color background = Color(0xFFF3F6FA); // Soft grayish blue
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFF1F5F9);
  
  // Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}