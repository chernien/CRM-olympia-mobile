import { MOCK_DEMANDES } from '../../data/mockData.js';

// In-memory demande store
let _demandes = MOCK_DEMANDES.map((d) => ({
  ...d,
  historique: d.historique.map((h) => ({ ...h })),
}));

const mockDemandeService = {
  async getDemandes({ page = 1, pageSize = 20, statut } = {}) {
    await _delay(400);
    let list = statut ? _demandes.filter((d) => d.statut === statut) : [..._demandes];
    const total = list.length;
    const start = (page - 1) * pageSize;
    list = list.slice(start, start + pageSize);
    return { data: { data: list, total, page, pageSize }, error: null };
  },

  async getDemandeById(id) {
    await _delay(200);
    const d = _demandes.find((d) => d.id === id);
    if (!d) return { data: null, error: { message: 'Demande introuvable', code: 404 } };
    return { data: d, error: null };
  },

  async createDemande(demande) {
    await _delay(500);
    const now = new Date().toISOString();
    const newDemande = {
      ...demande,
      id: `dem-${String(_demandes.length + 1).padStart(3, '0')}`,
      numero: `D-2026-${String(_demandes.length + 1).padStart(4, '0')}`,
      statut: 'nouvelle',
      createdAt: now.slice(0, 10),
      historique: [{ date: now.slice(0, 16).replace('T', ' '), action: 'Création', auteur: demande.commercialNom, color: 'bg-blue-500' }],
    };
    _demandes = [newDemande, ..._demandes];
    return { data: newDemande, error: null };
  },

  async updateStatus(id, statut, commentaire) {
    await _delay(500);
    const idx = _demandes.findIndex((d) => d.id === id);
    if (idx === -1) return { data: null, error: { message: 'Demande introuvable', code: 404 } };

    const now = new Date().toISOString().slice(0, 16).replace('T', ' ');
    const color = _statusColor(statut);
    const entry = { date: now, action: _statusAction(statut), auteur: 'Admin', color, ...(commentaire ? { commentaire } : {}) };

    _demandes[idx] = {
      ..._demandes[idx],
      statut,
      ...(commentaire ? { commentaire } : {}),
      historique: [..._demandes[idx].historique, entry],
    };
    return { data: _demandes[idx], error: null };
  },

  async deleteDemande(id) {
    await _delay(300);
    const idx = _demandes.findIndex((d) => d.id === id);
    if (idx === -1) return { data: null, error: { message: 'Demande introuvable', code: 404 } };
    _demandes = _demandes.filter((d) => d.id !== id);
    return { data: null, error: null };
  },
};

function _delay(ms) { return new Promise((r) => setTimeout(r, ms)); }

function _statusColor(statut) {
  const map = {
    en_cours_validation: 'bg-amber-500', validee: 'bg-green-500',
    en_cours_traitement: 'bg-yellow-500', traitee: 'bg-emerald-500',
    cloturee: 'bg-slate-400', refusee: 'bg-red-500',
  };
  return map[statut] ?? 'bg-slate-400';
}

function _statusAction(statut) {
  const map = {
    en_cours_validation: 'Prise en validation',
    validee: 'Validée',
    en_cours_traitement: 'En cours de traitement',
    traitee: 'Traitée',
    cloturee: 'Clôturée',
    refusee: 'Refusée',
  };
  return map[statut] ?? statut;
}

export default mockDemandeService;
