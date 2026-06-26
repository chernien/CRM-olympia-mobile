import { MOCK_CLIENTS } from '../../data/mockData.js';

const mockClientService = {
  async search(query = '') {
    await _delay(200);
    const q = query.toLowerCase();
    const results = q
      ? MOCK_CLIENTS.filter((c) => c.nom.toLowerCase().includes(q) || c.code.toLowerCase().includes(q) || c.ville.toLowerCase().includes(q))
      : MOCK_CLIENTS;
    return { data: results, error: null };
  },

  async getByCode(code) {
    await _delay(150);
    const client = MOCK_CLIENTS.find((c) => c.code === code);
    if (!client) return { data: null, error: { message: 'Client introuvable', code: 404 } };
    return { data: client, error: null };
  },
};

function _delay(ms) { return new Promise((r) => setTimeout(r, ms)); }

export default mockClientService;
