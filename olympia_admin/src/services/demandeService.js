import apiClient from './apiClient.js';

// Backend returns ISO datetimes ("2026-06-22T09:44:35Z"); the list UI shows a date.
const dateOnly = (s) => (typeof s === 'string' && s.includes('T') ? s.slice(0, 10) : s);

const demandeService = {
  async getDemandes({ page = 1, pageSize = 20, statut } = {}) {
    const { data, error } = await apiClient.get('/demandes', {
      page,
      pageSize,
      ...(statut ? { statut } : {}),
    });
    if (error) return { data: null, error };
    const items = (data.data ?? []).map((d) => ({ ...d, createdAt: dateOnly(d.createdAt) }));
    return { data: { ...data, data: items }, error: null };
  },

  getDemandeById: (id) => apiClient.get(`/demandes/${id}`),

  createDemande: (demande) => apiClient.post('/demandes', demande),

  updateStatus: (id, statut, commentaire) =>
    apiClient.put(`/demandes/${id}/statut`, { statut, commentaire }),

  deleteDemande: (id) => apiClient.delete(`/demandes/${id}`),
};

export default demandeService;
