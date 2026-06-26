import apiClient from './apiClient.js';

const clientService = {
  search: (query) => apiClient.get('/clients', { q: query }),
  getByCode: (code) => apiClient.get(`/clients/${code}`),
};

export default clientService;
