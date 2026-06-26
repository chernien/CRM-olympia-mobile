import apiClient from './apiClient.js';

const taskService = {
  getTasks: ({ page = 1, pageSize = 20, statut } = {}) =>
    apiClient.get('/taches', { page, pageSize, ...(statut ? { statut } : {}) }),

  getTaskById: (id) => apiClient.get(`/taches/${id}`),

  createTask: (task) => apiClient.post('/taches', task),

  updateTask: (id, patch) => apiClient.put(`/taches/${id}`, patch),

  updateTaskStatus: (id, statut) => apiClient.put(`/taches/${id}/statut`, { statut }),

  deleteTask: (id) => apiClient.delete(`/taches/${id}`),
};

export default taskService;
