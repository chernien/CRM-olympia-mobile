import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../models/demande_model.dart';
import '../../models/dashboard_model.dart';
import '../../models/client_model.dart';

/// Centralized fake data for mock mode.
/// Remove this file when switching to real API.
class MockData {
  MockData._();

  // ─── FAKE USERS ────────────────────────────────────────────────
  // Login credentials:
  //   Commercial: taha@olympia.com / password123
  //   Admin:      admin@olympia.com / admin123

  static const commercial = UserModel(
    id: 'usr-001',
    email: 'taha@olympia.com',
    nom: 'Mejdoub',
    prenom: 'Taha',
    role: 'commercial',
    zone: 'Casablanca Nord',
    objectifCA: 500000,
  );

  static const admin = UserModel(
    id: 'usr-002',
    email: 'admin@olympia.com',
    nom: 'Dupont',
    prenom: 'Marie',
    role: 'admin',
    zone: 'National',
    objectifCA: 2000000,
  );

  static const Map<String, (UserModel, String)> users = {
    'taha@olympia.com': (commercial, 'password123'),
    'admin@olympia.com': (admin, 'admin123'),
  };

  // ─── FAKE CLIENTS (Divalto) ────────────────────────────────────
  static const clients = [
    ClientModel(
      code: 'CLI-001',
      nom: 'Brico Déco Casablanca',
      adresse: '123 Bd Zerktouni',
      ville: 'Casablanca',
      telephone: '0522-334455',
      email: 'contact@bricodeco.ma',
    ),
    ClientModel(
      code: 'CLI-002',
      nom: 'Peintures Atlas',
      adresse: '45 Rue Moulay Ismail',
      ville: 'Rabat',
      telephone: '0537-112233',
      email: 'info@peinturesatlas.ma',
    ),
    ClientModel(
      code: 'CLI-003',
      nom: 'Matériaux El Jadida',
      adresse: '78 Avenue Hassan II',
      ville: 'El Jadida',
      telephone: '0523-445566',
      email: 'vente@mat-eljadida.ma',
    ),
    ClientModel(
      code: 'CLI-004',
      nom: 'Décoration Moderne Marrakech',
      adresse: '12 Rue Bab Agnaou',
      ville: 'Marrakech',
      telephone: '0524-667788',
      email: 'contact@decomarrakech.ma',
    ),
    ClientModel(
      code: 'CLI-005',
      nom: 'Quincaillerie Tanger',
      adresse: '56 Bd Mohammed V',
      ville: 'Tanger',
      telephone: '0539-223344',
      email: 'quincaillerie.tanger@gmail.com',
    ),
    ClientModel(
      code: 'CLI-006',
      nom: 'Société Peinture Fès',
      adresse: '90 Avenue des FAR',
      ville: 'Fès',
      telephone: '0535-556677',
      email: 'sp.fes@gmail.com',
    ),
  ];

  // ─── FAKE TASKS ────────────────────────────────────────────────
  static final tasks = [
    TaskModel(
      id: 'tsk-001',
      numero: 'T-2026-0001',
      codeClient: 'CLI-001',
      nomClient: 'Brico Déco Casablanca',
      adresse: '123 Bd Zerktouni, Casablanca',
      description:
          'Visite commerciale — présentation nouvelle gamme peinture extérieure',
      datePrevue: DateTime(2026, 4, 7),
      priorite: 'haute',
      statut: 'en_cours_traitement',
      commercialId: 'usr-001',
      commercialNom: 'Taha Mejdoub',
      createdAt: DateTime(2026, 4, 1),
    ),
    TaskModel(
      id: 'tsk-002',
      numero: 'T-2026-0002',
      codeClient: 'CLI-002',
      nomClient: 'Peintures Atlas',
      adresse: '45 Rue Moulay Ismail, Rabat',
      description: 'Récupérer bon de commande signé + vérifier stock showroom',
      datePrevue: DateTime(2026, 4, 5),
      priorite: 'normale',
      statut: 'realisee',
      commercialId: 'usr-001',
      commercialNom: 'Taha Mejdoub',
      createdAt: DateTime(2026, 3, 28),
    ),
    TaskModel(
      id: 'tsk-003',
      numero: 'T-2026-0003',
      codeClient: 'CLI-003',
      nomClient: 'Matériaux El Jadida',
      adresse: '78 Avenue Hassan II, El Jadida',
      description:
          'Livraison échantillons peinture murale + catalogue produits',
      datePrevue: DateTime(2026, 4, 10),
      priorite: 'urgente',
      statut: 'en_cours_traitement',
      commercialId: 'usr-001',
      commercialNom: 'Taha Mejdoub',
      createdAt: DateTime(2026, 4, 2),
    ),
    TaskModel(
      id: 'tsk-004',
      numero: 'T-2026-0004',
      codeClient: 'CLI-004',
      nomClient: 'Décoration Moderne Marrakech',
      adresse: '12 Rue Bab Agnaou, Marrakech',
      description: 'Formation équipe vente sur nouvelle machine à teinter',
      datePrevue: DateTime(2026, 4, 15),
      priorite: 'normale',
      statut: 'en_cours_traitement',
      commercialId: 'usr-001',
      commercialNom: 'Taha Mejdoub',
      createdAt: DateTime(2026, 4, 3),
    ),
    TaskModel(
      id: 'tsk-005',
      numero: 'T-2026-0005',
      codeClient: 'CLI-005',
      nomClient: 'Quincaillerie Tanger',
      adresse: '56 Bd Mohammed V, Tanger',
      description: 'Suivi réclamation peinture défectueuse lot #4521',
      datePrevue: DateTime(2026, 3, 25),
      priorite: 'haute',
      statut: 'annulee',
      commercialId: 'usr-001',
      commercialNom: 'Taha Mejdoub',
      createdAt: DateTime(2026, 3, 20),
    ),
  ];

  // ─── FAKE DEMANDES ─────────────────────────────────────────────
  static final demandes = [
    DemandeModel(
      id: 'dem-001',
      numero: 'D-2026-0001',
      typeDemande: 1,
      statut: 'nouvelle',
      commercialId: 'usr-001',
      commercialNom: 'Taha Mejdoub',
      formData: {
        'codeClient': 'CLI-001',
        'description':
            "Demande 3 échantillons peinture satinée (blanc, ivoire, gris perle)",
        'references': ['REF-SAT-001', 'REF-SAT-002', 'REF-SAT-003'],
      },
      createdAt: DateTime(2026, 4, 1),
      historique: [
        DemandeHistorique(
          action: 'Création',
          auteur: 'Taha Mejdoub',
          date: DateTime(2026, 4, 1),
        ),
      ],
    ),
    DemandeModel(
      id: 'dem-002',
      numero: 'D-2026-0002',
      typeDemande: 3,
      statut: 'en_cours_validation',
      commercialId: 'usr-001',
      commercialNom: 'Taha Mejdoub',
      formData: {
        'codeClient': 'CLI-005',
        'description':
            'Réclamation: peinture écaillée après 2 mois — lot #4521',
        'gravite': 'haute',
      },
      commentaire: 'Client mécontent, demande remplacement urgent',
      createdAt: DateTime(2026, 3, 28),
      historique: [
        DemandeHistorique(
          action: 'Création',
          auteur: 'Taha Mejdoub',
          date: DateTime(2026, 3, 28),
        ),
        DemandeHistorique(
          action: 'Envoyée en validation',
          auteur: 'Système',
          date: DateTime(2026, 3, 29),
          commentaire: 'Transmise au responsable qualité',
        ),
      ],
    ),
    DemandeModel(
      id: 'dem-003',
      numero: 'D-2026-0003',
      typeDemande: 4,
      statut: 'validee',
      commercialId: 'usr-001',
      commercialNom: 'Taha Mejdoub',
      formData: {
        'raisonSociale': 'Peintures Oasis SARL',
        'adresse': '22 Rue Ibn Batouta, Agadir',
        'ice': '002345678000012',
        'telephone': '0528-334455',
        'email': 'contact@peintures-oasis.ma',
        'description':
            'Nouveau distributeur zone Souss — recommandé par CLI-002',
      },
      createdAt: DateTime(2026, 3, 20),
      historique: [
        DemandeHistorique(
          action: 'Création',
          auteur: 'Taha Mejdoub',
          date: DateTime(2026, 3, 20),
        ),
        DemandeHistorique(
          action: 'Validée',
          auteur: 'Marie Dupont',
          date: DateTime(2026, 3, 22),
          commentaire: 'Profil vérifié, créer dans Divalto',
        ),
      ],
    ),
    DemandeModel(
      id: 'dem-004',
      numero: 'D-2026-0004',
      typeDemande: 6,
      statut: 'en_cours_traitement',
      commercialId: 'usr-001',
      commercialNom: 'Taha Mejdoub',
      formData: {
        'codeClient': 'CLI-004',
        'description': "Formation technique application peinture décorative",
        'nombreParticipants': 8,
        'datesSouhaitees': '15-16 Avril 2026',
      },
      createdAt: DateTime(2026, 3, 25),
      historique: [
        DemandeHistorique(
          action: 'Création',
          auteur: 'Taha Mejdoub',
          date: DateTime(2026, 3, 25),
        ),
        DemandeHistorique(
          action: 'Validée',
          auteur: 'Marie Dupont',
          date: DateTime(2026, 3, 26),
        ),
        DemandeHistorique(
          action: 'En cours de traitement',
          auteur: 'Système',
          date: DateTime(2026, 3, 27),
          commentaire: 'Formateur assigné: Ahmed Bennani',
        ),
      ],
    ),
    DemandeModel(
      id: 'dem-005',
      numero: 'D-2026-0005',
      typeDemande: 8,
      statut: 'traitee',
      commercialId: 'usr-001',
      commercialNom: 'Taha Mejdoub',
      formData: {
        'codeClient': 'CLI-003',
        'description': 'Installation machine à teinter modèle MT-500',
        'emplacement': 'Magasin principal',
      },
      createdAt: DateTime(2026, 3, 10),
      historique: [
        DemandeHistorique(
          action: 'Création',
          auteur: 'Taha Mejdoub',
          date: DateTime(2026, 3, 10),
        ),
        DemandeHistorique(
          action: 'Validée',
          auteur: 'Marie Dupont',
          date: DateTime(2026, 3, 11),
        ),
        DemandeHistorique(
          action: 'Traitée',
          auteur: 'Technicien Karim',
          date: DateTime(2026, 3, 18),
          commentaire: 'Machine installée et calibrée',
        ),
      ],
    ),
    DemandeModel(
      id: 'dem-006',
      numero: 'D-2026-0006',
      typeDemande: 9,
      statut: 'refusee',
      commercialId: 'usr-001',
      commercialNom: 'Taha Mejdoub',
      formData: {
        'codeClient': 'CLI-006',
        'description': 'PLV + kakémonos + présentoir comptoir',
        'quantite': 50,
      },
      commentaire: 'Budget marketing Q2 épuisé',
      createdAt: DateTime(2026, 3, 15),
      historique: [
        DemandeHistorique(
          action: 'Création',
          auteur: 'Taha Mejdoub',
          date: DateTime(2026, 3, 15),
        ),
        DemandeHistorique(
          action: 'Refusée',
          auteur: 'Marie Dupont',
          date: DateTime(2026, 3, 17),
          commentaire: 'Budget marketing Q2 déjà alloué, reporter en Q3',
        ),
      ],
    ),
  ];

  // ─── FAKE DASHBOARD DATA ───────────────────────────────────────
  static const caMensuel = CAData(
    total: 125000,
    intern: 45000,
    extern: 55000,
    olybat: 25000,
    points: [
      CAPoint(label: 'Jan', value: 95000),
      CAPoint(label: 'Fév', value: 110000),
      CAPoint(label: 'Mar', value: 125000),
      CAPoint(label: 'Avr', value: 80000),
    ],
  );

  static const caTrimestriel = CAData(
    total: 330000,
    intern: 120000,
    extern: 145000,
    olybat: 65000,
    points: [
      CAPoint(label: 'T1', value: 330000),
      CAPoint(label: 'T2', value: 0),
      CAPoint(label: 'T3', value: 0),
      CAPoint(label: 'T4', value: 0),
    ],
  );

  static const statsVisites = StatsVisites(
    moisEnCours: 12,
    trimestreEnCours: 34,
  );

  static const statsTaches = StatsTaches(
    moisEnCours: 8,
    trimestreEnCours: 22,
    enCoursDeTraitement: 3,
  );
}
