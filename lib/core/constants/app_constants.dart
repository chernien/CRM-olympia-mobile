class AppConstants {
  AppConstants._();

  static const String appName = 'OlyHub';
  static const String appVersion = '1.0.0';

  // JWT
  static const String tokenKey = 'jwt_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  // Pagination
  static const int defaultPageSize = 20;

  // Demande Types
  static const int demandeEchantillons = 1;
  static const int demandeEchantillonsApplication = 2;
  static const int demandeReclamation = 3;
  static const int demandeNouveauClient = 4;
  static const int demandeShowroom = 5;
  static const int demandeFormation = 6;
  static const int demandeAssistanceChantier = 7;
  static const int demandeMachineTeinter = 8;
  static const int demandeAccessoiresMarketing = 9;

  // Task Statuses
  static const String taskStatusEnCours = 'en_cours_traitement';
  static const String taskStatusRealisee = 'realisee';
  static const String taskStatusAnnulee = 'annulee';

  // Demande Statuses
  static const String demandeStatusNouvelle = 'nouvelle';
  static const String demandeStatusEnValidation = 'en_cours_validation';
  static const String demandeStatusValidee = 'validee';
  static const String demandeStatusEnTraitement = 'en_cours_traitement';
  // Phases tenues par le rôle Prod : « en production », pas « en traitement ».
  static const String demandeStatusEnProduction = 'en_production';
  static const String demandeStatusTraitee = 'traitee';
  static const String demandeStatusCloturee = 'cloturee';
  static const String demandeStatusRefusee = 'refusee';

  // Task Priorities
  static const String priorityNormale = 'normale';
  static const String priorityHaute = 'haute';
  static const String priorityUrgente = 'urgente';

  // CA Segments
  static const String segmentIntern = 'intern';
  static const String segmentExtern = 'extern';
  static const String segmentOlybat = 'olybat';
}
