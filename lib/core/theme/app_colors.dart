import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors from Logo (OLYMPIA Peinture)
  static const Color primary = Color(0xFF4278A1); // Steel Blue from logo outline and text
  static const Color secondary = Color(0xFF5A9692); // Teal from logo fill
  /// Bleu du LOGO — identique au `--color-primary` du back-office web (#003690).
  ///
  /// Ajouté, jamais substitué à [primary] : celui-ci (#4278A1) habille toute
  /// l'interface mobile et n'a pas à changer. Mais l'anneau du logo est dessiné
  /// en #003690 ; écrire « OlyHub » à côté dans un autre bleu ferait jurer le
  /// mot avec la marque qu'il accompagne. Ce jeton ne sert QUE au nom de marque.
  static const Color brand = Color(0xFF003690);

  static const Color primaryLight = Color(0xFF8FB4FF);
  static const Color primaryDark = Color(0xFF3B6BDB);

  // Status - Tâches (Restored)
  static const Color taskEnCours = Color(0xFFF59E0B);       // Jaune
  static const Color taskRealisee = Color(0xFF059669);      // Vert foncé
  static const Color taskAnnulee = Color(0xFF6B7280);       // Gris

  // Status - Demandes (Restored)
  static const Color demandeNouvelle = Color(0xFF3B82F6);    // Bleu
  static const Color demandeEnValidation = Color(0xFFF97316); // Orange
  static const Color demandeValidee = Color(0xFF4ADE80);     // Vert clair
  static const Color demandeEnTraitement = Color(0xFFF59E0B); // Jaune
  static const Color demandeEnProduction = Color(0xFF06B6D4); // Cyan (rôle Prod)
  static const Color demandeTraitee = Color(0xFF059669);     // Vert foncé
  static const Color demandeCloturee = Color(0xFF6B7280);    // Gris
  static const Color demandeRefusee = Color(0xFFEF4444);     // Rouge

  // Priorities (Restored)
  static const Color priorityNormale = Color(0xFF3B82F6);
  static const Color priorityHaute = Color(0xFFF97316);
  static const Color priorityUrgente = Color(0xFFEF4444);

  // CA Segments
  static const Color segmentIntern = Color(0xFF4278A1); // Primary Logo Color
  static const Color segmentExtern = Color(0xFF5A9692); // Secondary Logo Color
  static const Color segmentOlybat = Color(0xFFF59E0B);

  // Neutral (Crucial for the soft UI look)
  static const Color background = Color(0xFFFAFBFD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFF1F5F9);

  /// Neutral fill for text inputs and inert surfaces (was hardcoded per-screen).
  static const Color inputFill = Color(0xFFF4F7FC);

  /// Stronger neutral outline for unselected controls that need to read as
  /// interactive — [border] is too faint at 1–2 px against [surface].
  static const Color borderStrong = Color(0xFFCBD5E1);

  /// Readable muted text on light surfaces. [textSecondary] sits at ~2.4:1 on
  /// white and fails WCAG AA for body copy; use this for anything readers must
  /// actually read, and keep [textSecondary] for decorative glyphs.
  static const Color textMuted = Color(0xFF64748B);

  /// Very light wash of [hue], for illustration and header backdrops.
  /// Derived rather than hand-picked so decorative tints follow the brand.
  static Color tint(Color hue) => Color.lerp(hue, Colors.white, 0.90)!;

  /// Deepened [hue], for small accents that need contrast over [tint].
  static Color deepen(Color hue) => Color.lerp(hue, Colors.black, 0.35)!;

  // Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Pre-computed alpha variants (avoid withValues per-frame)
  static final Color primarySoft   = primary.withValues(alpha: 0.95);
  static final Color primaryGhost  = primary.withValues(alpha: 0.08);
  static final Color primaryShadow = primary.withValues(alpha: 0.35);
  static final Color secondarySoft = secondary.withValues(alpha: 0.95);
  static final Color whiteSoft     = Colors.white.withValues(alpha: 0.9);
  static final Color whiteGhost    = Colors.white.withValues(alpha: 0.2);
  static final Color blackShadow   = Colors.black.withValues(alpha: 0.05);
  static final Color primaryGradientStart = primary.withValues(alpha: 0.95);
  static final Color secondaryGradientStart = secondary.withValues(alpha: 0.95);
  // Named white-opacity variants — use these instead of calling withValues per frame.
  static final Color white20 = Colors.white.withValues(alpha: 0.2);
  static final Color white90 = Colors.white.withValues(alpha: 0.9);
}