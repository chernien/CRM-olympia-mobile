import apiClient from './apiClient.js';

const objectifService = {
  async getObjectifs() {
    const { data, error } = await apiClient.get('/objectifs', { page: 1, pageSize: 100 });
    if (error) return { data: null, error };
    return { data: data?.data ?? [], error: null };
  },

  createObjectif: (payload) => apiClient.post('/objectifs', payload),

  updateObjectif: (id, payload) => apiClient.put(`/objectifs/${id}`, payload),

  deleteObjectif: (id) => apiClient.delete(`/objectifs/${id}`),
};

export default objectifService;
