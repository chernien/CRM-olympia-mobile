import { MOCK_USERS } from '../../data/mockData.js';
import { setToken, clearTokens } from '../apiClient.js';
import { getStoredUser } from '../userStorage.js';

const FAKE_TOKEN = 'mock-jwt-token';

const mockAuthService = {
  async login(email, password) {
    await _delay(600);
    const entry = MOCK_USERS[email];
    if (!entry || entry.password !== password) {
      return { data: null, error: { message: 'Email ou mot de passe incorrect.' } };
    }
    setToken(FAKE_TOKEN, 'mock-refresh');
    return { data: entry.user, error: null };
  },

  async logout() {
    clearTokens();
    return { data: null, error: null };
  },

  async getProfile() {
    await _delay(200);
    const stored = getStoredUser();
    if (!stored) return { data: null, error: { message: 'Non authentifié', code: 401 } };
    return { data: stored, error: null };
  },
};

function _delay(ms) { return new Promise((r) => setTimeout(r, ms)); }

export default mockAuthService;
