import apiClient, { setToken, clearTokens, getRefreshToken } from './apiClient.js';

// Backend roles are "Admin"/"Commercial"; the web app expects lowercase
// ('admin'/'commercial') for its role checks (e.g. AdminOnly route guard).
function normalizeUser(u) {
  if (!u) return u;
  return { ...u, role: typeof u.role === 'string' ? u.role.toLowerCase() : u.role };
}

const authService = {
  async login(email, password) {
    const { data, error } = await apiClient.post('/auth/login', { email, password });
    if (error) return { data: null, error };
    setToken(data.accessToken, data.refreshToken);
    return { data: normalizeUser(data.user), error: null };
  },

  async logout() {
    const refreshToken = getRefreshToken();
    try {
      await apiClient.post('/auth/logout', refreshToken ? { refreshToken } : {});
    } catch {
      /* ignore */
    }
    clearTokens();
    return { data: null, error: null };
  },

  async getProfile() {
    const { data, error } = await apiClient.get('/auth/me');
    if (error) return { data: null, error };
    return { data: normalizeUser(data), error: null };
  },
};

export default authService;
