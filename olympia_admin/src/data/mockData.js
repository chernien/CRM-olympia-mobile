// Centralized fake data — mirrors lib/services/mock/mock_data.dart exactly.
// Login credentials:
//   Commercial: taha@olympia.com / password123
//   Admin:      admin@olympia.com / admin123

export const MOCK_USERS = {
  'taha@olympia.com': {
    user: {
      id: 'usr-001',
      email: 'taha@olympia.com',
      nom: 'Mejdoub',
      prenom: 'Taha',
      role: 'commercial',
      zone: 'Casablanca Nord',
      objectifCA: 500000,
    },
    password: 'password123',
  },
  'admin@olympia.com': {
    user: {
      id: 'usr-002',
      email: 'admin@olympia.com',
      nom: 'Dupont',
      prenom: 'Marie',
      role: 'admin',
      zone: 'National',
      objectifCA: 2000000,
    },
    password: 'admin123',
  },
};

export const MOCK_CLIENTS = [
  { code: 'CLI-001', nom: 'Brico Déco Casablanca',         adresse: '123 Bd Zerktouni',       ville: 'Casablanca', telephone: '0522-334455', email: 'contact@bricodeco.ma' },
  { code: 'CLI-002', nom: 'Peintures Atlas',               adresse: '45 Rue Moulay Ismail',   ville: 'Rabat',      telephone: '0537-112233', email: 'info@peinturesatlas.ma' },
  { code: 'CLI-003', nom: 'Matériaux El Jadida',           adresse: '78 Avenue Hassan II',    ville: 'El Jadida',  telephone: '0523-445566', email: 'vente@mat-eljadida.ma' },
  { code: 'CLI-004', nom: 'Décoration Moderne Marrakech',  adresse: '12 Rue Bab Agnaou',      ville: 'Marrakech',  telephone: '0524-667788', email: 'contact@decomarrakech.ma' },
  { code: 'CLI-005', nom: 'Quincaillerie Tanger',          adresse: '56 Bd Mohammed V',       ville: 'Tanger',     telephone: '0539-223344', email: 'quincaillerie.tanger@gmail.com' },
  { code: 'CLI-006', nom: 'Société Peinture Fès',          adresse: '90 Avenue des FAR',      ville: 'Fès',        telephone: '0535-556677', email: 'sp.fes@gmail.com' },
];

export const MOCK_TASKS = [
  {
    id: 'tsk-001', numero: 'T-2026-0001',
    codeClient: 'CLI-001', nomClient: 'Brico Déco Casablanca',
    adresse: '123 Bd Zerktouni, Casablanca',
    description: 'Visite commerciale — présentation nouvelle gamme peinture extérieure',
    datePrevue: '2026-04-07', priorite: 'haute', statut: 'en_cours_traitement',
    commercialId: 'usr-001', commercialNom: 'Taha Mejdoub', createdAt: '2026-04-01',
  },
  {
    id: 'tsk-002', numero: 'T-2026-0002',
    codeClient: 'CLI-002', nomClient: 'Peintures Atlas',
    adresse: '45 Rue Moulay Ismail, Rabat',
    description: 'Récupérer bon de commande signé + vérifier stock showroom',
    datePrevue: '2026-04-05', priorite: 'normale', statut: 'realisee',
    commercialId: 'usr-001', commercialNom: 'Taha Mejdoub', createdAt: '2026-03-28',
  },
  {
    id: 'tsk-003', numero: 'T-2026-0003',
    codeClient: 'CLI-003', nomClient: 'Matériaux El Jadida',
    adresse: '78 Avenue Hassan II, El Jadida',
    description: 'Livraison échantillons peinture murale + catalogue produits',
    datePrevue: '2026-04-10', priorite: 'urgente', statut: 'en_cours_traitement',
    commercialId: 'usr-001', commercialNom: 'Taha Mejdoub', createdAt: '2026-04-02',
  },
  {
    id: 'tsk-004', numero: 'T-2026-0004',
    codeClient: 'CLI-004', nomClient: 'Décoration Moderne Marrakech',
    adresse: '12 Rue Bab Agnaou, Marrakech',
    description: 'Formation équipe vente sur nouvelle machine à teinter',
    datePrevue: '2026-04-15', priorite: 'normale', statut: 'en_cours_traitement',
    commercialId: 'usr-001', commercialNom: 'Taha Mejdoub', createdAt: '2026-04-03',
  },
  {
    id: 'tsk-005', numero: 'T-2026-0005',
    codeClient: 'CLI-005', nomClient: 'Quincaillerie Tanger',
    adresse: '56 Bd Mohammed V, Tanger',
    description: 'Suivi réclamation peinture défectueuse lot #4521',
    datePrevue: '2026-03-25', priorite: 'haute', statut: 'annulee',
    commercialId: 'usr-001', commercialNom: 'Taha Mejdoub', createdAt: '2026-03-20',
  },
];

export const MOCK_DEMANDES = [
  {
    id: 'dem-001', numero: 'D-2026-0001',
    typeDemande: 1, typeLabel: 'Échantillons',
    statut: 'nouvelle',
    commercialId: 'usr-001', commercialNom: 'Taha Mejdoub',
    codeClient: 'CLI-001', nomClient: 'Brico Déco Casablanca',
    description: 'Demande 3 échantillons peinture satinée (blanc, ivoire, gris perle)',
    formData: { references: ['REF-SAT-001', 'REF-SAT-002', 'REF-SAT-003'] },
    commentaire: null,
    createdAt: '2026-04-01',
    historique: [
      { date: '2026-04-01 09:00', action: 'Création', auteur: 'Taha Mejdoub', color: 'bg-blue-500' },
    ],
  },
  {
    id: 'dem-002', numero: 'D-2026-0002',
    typeDemande: 3, typeLabel: 'Réclamation',
    statut: 'en_cours_validation',
    commercialId: 'usr-001', commercialNom: 'Taha Mejdoub',
    codeClient: 'CLI-005', nomClient: 'Quincaillerie Tanger',
    description: 'Réclamation: peinture écaillée après 2 mois — lot #4521',
    formData: { gravite: 'haute' },
    commentaire: 'Client mécontent, demande remplacement urgent',
    createdAt: '2026-03-28',
    historique: [
      { date: '2026-03-28 10:00', action: 'Création', auteur: 'Taha Mejdoub', color: 'bg-blue-500' },
      { date: '2026-03-29 08:00', action: 'Envoyée en validation', auteur: 'Système', color: 'bg-amber-500', commentaire: 'Transmise au responsable qualité' },
    ],
  },
  {
    id: 'dem-003', numero: 'D-2026-0003',
    typeDemande: 4, typeLabel: 'Nouveau Client',
    statut: 'validee',
    commercialId: 'usr-001', commercialNom: 'Taha Mejdoub',
    codeClient: null, nomClient: 'Peintures Oasis SARL',
    description: 'Nouveau distributeur zone Souss — recommandé par CLI-002',
    formData: { raisonSociale: 'Peintures Oasis SARL', adresse: '22 Rue Ibn Batouta, Agadir', ice: '002345678000012', telephone: '0528-334455' },
    commentaire: null,
    createdAt: '2026-03-20',
    historique: [
      { date: '2026-03-20 11:00', action: 'Création', auteur: 'Taha Mejdoub', color: 'bg-blue-500' },
      { date: '2026-03-22 09:00', action: 'Validée', auteur: 'Marie Dupont', color: 'bg-green-500', commentaire: 'Profil vérifié, créer dans Divalto' },
    ],
  },
  {
    id: 'dem-004', numero: 'D-2026-0004',
    typeDemande: 6, typeLabel: 'Formation',
    statut: 'en_cours_traitement',
    commercialId: 'usr-001', commercialNom: 'Taha Mejdoub',
    codeClient: 'CLI-004', nomClient: 'Décoration Moderne Marrakech',
    description: 'Formation technique application peinture décorative',
    formData: { nombreParticipants: 8, datesSouhaitees: '15-16 Avril 2026' },
    commentaire: null,
    createdAt: '2026-03-25',
    historique: [
      { date: '2026-03-25 14:00', action: 'Création', auteur: 'Taha Mejdoub', color: 'bg-blue-500' },
      { date: '2026-03-26 10:00', action: 'Validée', auteur: 'Marie Dupont', color: 'bg-green-500' },
      { date: '2026-03-27 08:00', action: 'En cours de traitement', auteur: 'Système', color: 'bg-yellow-500', commentaire: 'Formateur assigné: Ahmed Bennani' },
    ],
  },
  {
    id: 'dem-005', numero: 'D-2026-0005',
    typeDemande: 8, typeLabel: 'Machine à Teinter',
    statut: 'traitee',
    commercialId: 'usr-001', commercialNom: 'Taha Mejdoub',
    codeClient: 'CLI-003', nomClient: 'Matériaux El Jadida',
    description: 'Installation machine à teinter modèle MT-500',
    formData: { emplacement: 'Magasin principal' },
    commentaire: null,
    createdAt: '2026-03-10',
    historique: [
      { date: '2026-03-10 09:00', action: 'Création', auteur: 'Taha Mejdoub', color: 'bg-blue-500' },
      { date: '2026-03-11 11:00', action: 'Validée', auteur: 'Marie Dupont', color: 'bg-green-500' },
      { date: '2026-03-18 16:00', action: 'Traitée', auteur: 'Technicien Karim', color: 'bg-emerald-500', commentaire: 'Machine installée et calibrée' },
    ],
  },
  {
    id: 'dem-006', numero: 'D-2026-0006',
    typeDemande: 9, typeLabel: 'Accessoires Marketing',
    statut: 'refusee',
    commercialId: 'usr-001', commercialNom: 'Taha Mejdoub',
    codeClient: 'CLI-006', nomClient: 'Société Peinture Fès',
    description: 'PLV + kakémonos + présentoir comptoir',
    formData: { quantite: 50 },
    commentaire: 'Budget marketing Q2 épuisé',
    createdAt: '2026-03-15',
    historique: [
      { date: '2026-03-15 10:00', action: 'Création', auteur: 'Taha Mejdoub', color: 'bg-blue-500' },
      { date: '2026-03-17 14:00', action: 'Refusée', auteur: 'Marie Dupont', color: 'bg-red-500', commentaire: 'Budget marketing Q2 déjà alloué, reporter en Q3' },
    ],
  },
];

export const MOCK_DASHBOARD = {
  month: {
    ca: 125000, caIntern: 45000, caExtern: 55000, caOlybat: 25000,
    caTrend: 12.4,
    demandes: 6, demandesTrend: 2,
    taches: 8, tachesTrend: -1,
    visites: 12, visitesTrend: 3,
    objectifPct: 25,
    tauxValidation: 75,
    caPoints: [
      { label: 'Oct', value: 98000 },
      { label: 'Nov', value: 112000 },
      { label: 'Déc', value: 89000 },
      { label: 'Jan', value: 104000 },
      { label: 'Fév', value: 118000 },
      { label: 'Mar', value: 125000 },
    ],
    demandesByType: [
      { type: 'Échantillons', count: 2, perc: 33 },
      { type: 'Réclamation', count: 1, perc: 17 },
      { type: 'Nouveau Client', count: 1, perc: 17 },
      { type: 'Formation', count: 1, perc: 17 },
      { type: 'Autres', count: 1, perc: 16 },
    ],
    performers: [
      { name: 'Taha Mejdoub', zone: 'Casablanca Nord', ca: '125K', caVal: 125000, objectif: 500000, avatar: 'TM', color: 'bg-blue-50 text-blue-700' },
      { name: 'Ahmed Salhi',  zone: 'Rabat Centre',   ca: '43K',  caVal: 43000,  objectif: 400000, avatar: 'AS', color: 'bg-green-50 text-green-700' },
      { name: 'Yassine Rachidi', zone: 'Marrakech',  ca: '30K',  caVal: 30000,  objectif: 350000, avatar: 'YR', color: 'bg-amber-50 text-amber-700' },
    ],
  },
  quarter: {
    ca: 330000, caIntern: 120000, caExtern: 145000, caOlybat: 65000,
    caTrend: 9.1,
    demandes: 24, demandesTrend: 8,
    taches: 34, tachesTrend: 5,
    visites: 98, visitesTrend: 14,
    objectifPct: 17,
    tauxValidation: 78,
    caPoints: [
      { label: 'Jan', value: 104000 },
      { label: 'Fév', value: 118000 },
      { label: 'Mar', value: 125000 },
      { label: 'Avr', value: 110000 },
      { label: 'Mai', value: 132000 },
      { label: 'Juin', value: 141000 },
    ],
    demandesByType: [
      { type: 'Échantillons', count: 8,  perc: 33 },
      { type: 'Réclamation',  count: 5,  perc: 21 },
      { type: 'Nouveau Client', count: 4, perc: 17 },
      { type: 'Formation',    count: 3,  perc: 12 },
      { type: 'Autres',       count: 4,  perc: 17 },
    ],
    performers: [
      { name: 'Taha Mejdoub', zone: 'Casablanca Nord', ca: '142K', caVal: 142000, objectif: 500000, avatar: 'TM', color: 'bg-blue-50 text-blue-700' },
      { name: 'Ahmed Salhi',  zone: 'Rabat Centre',   ca: '118K', caVal: 118000, objectif: 400000, avatar: 'AS', color: 'bg-green-50 text-green-700' },
      { name: 'Yassine Rachidi', zone: 'Marrakech',  ca: '70K',  caVal: 70000,  objectif: 350000, avatar: 'YR', color: 'bg-amber-50 text-amber-700' },
    ],
  },
  year: {
    ca: 1280000, caIntern: 460000, caExtern: 540000, caOlybat: 280000,
    caTrend: 22.5,
    demandes: 284, demandesTrend: 45,
    taches: 148, tachesTrend: 21,
    visites: 412, visitesTrend: 32,
    objectifPct: 64,
    tauxValidation: 81,
    caPoints: [
      { label: 'Jan', value: 88000 },  { label: 'Fév', value: 95000 },
      { label: 'Mar', value: 102000 }, { label: 'Avr', value: 98000 },
      { label: 'Mai', value: 115000 }, { label: 'Juin', value: 128000 },
      { label: 'Juil', value: 108000 },{ label: 'Aoû', value: 92000 },
      { label: 'Sep', value: 118000 }, { label: 'Oct', value: 132000 },
      { label: 'Nov', value: 145000 }, { label: 'Déc', value: 159000 },
    ],
    demandesByType: [
      { type: 'Échantillons', count: 88, perc: 31 },
      { type: 'Réclamation',  count: 62, perc: 22 },
      { type: 'Nouveau Client', count: 55, perc: 19 },
      { type: 'Formation',    count: 44, perc: 16 },
      { type: 'Autres',       count: 35, perc: 12 },
    ],
    performers: [
      { name: 'Taha Mejdoub', zone: 'Casablanca Nord', ca: '530K', caVal: 530000, objectif: 500000, avatar: 'TM', color: 'bg-blue-50 text-blue-700' },
      { name: 'Ahmed Salhi',  zone: 'Rabat Centre',   ca: '455K', caVal: 455000, objectif: 400000, avatar: 'AS', color: 'bg-green-50 text-green-700' },
      { name: 'Yassine Rachidi', zone: 'Marrakech',  ca: '295K', caVal: 295000, objectif: 350000, avatar: 'YR', color: 'bg-amber-50 text-amber-700' },
    ],
  },
};

// Team members for admin views (users + performance data)
export const MOCK_TEAM = [
  {
    id: 'usr-001', name: 'Taha Mejdoub', role: 'Commercial', email: 'taha@olympia.com',
    phone: '+212 600-000003', status: 'Actif', avatar: 'TM', zone: 'Casablanca Nord',
    ca: '125K', caVal: 125000, tasks: 5, demandes: 6, joinDate: '2023-03-01', objectif: 500000,
  },
  {
    id: 'usr-002', name: 'Marie Dupont', role: 'Administrateur', email: 'admin@olympia.com',
    phone: '+212 600-000001', status: 'Actif', avatar: 'MD', zone: 'National',
    ca: '—', caVal: 0, tasks: 0, demandes: 0, joinDate: '2022-01-15', objectif: 2000000,
  },
  {
    id: 'usr-003', name: 'Ahmed Salhi', role: 'Commercial', email: 'ahmed@olympia.ma',
    phone: '+212 600-000002', status: 'Actif', avatar: 'AS', zone: 'Rabat Centre',
    ca: '43K', caVal: 43000, tasks: 6, demandes: 11, joinDate: '2023-05-10', objectif: 400000,
  },
  {
    id: 'usr-004', name: 'Yassine Rachidi', role: 'Commercial', email: 'yassine@olympia.ma',
    phone: '+212 600-000004', status: 'Actif', avatar: 'YR', zone: 'Marrakech',
    ca: '30K', caVal: 30000, tasks: 4, demandes: 7, joinDate: '2023-08-20', objectif: 350000,
  },
  {
    id: 'usr-005', name: 'Leila Benali', role: 'Commercial', email: 'leila@olympia.ma',
    phone: '+212 600-000005', status: 'Inactif', avatar: 'LB', zone: 'Fès',
    ca: '18K', caVal: 18000, tasks: 2, demandes: 5, joinDate: '2024-01-08', objectif: 300000,
  },
];
