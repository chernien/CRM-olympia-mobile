import apiClient from './apiClient.js';

// First letters of the name → avatar initials (backend doesn't send an avatar).
function initials(name = '') {
  return (
    name
      .split(' ')
      .filter(Boolean)
      .slice(0, 2)
      .map((w) => w[0]?.toUpperCase() ?? '')
      .join('') || '?'
  );
}

const dashboardService = {
  async getStats(periode) {
    const { data, error } = await apiClient.get('/dashboard/stats', { periode });
    if (error) return { data: null, error };
    const performers = (data.performers ?? []).map((p) => ({
      ...p,
      avatar: p.avatar ?? initials(p.name),
    }));
    return { data: { ...data, performers }, error: null };
  },
};

export default dashboardService;
