import { MOCK_TEAM } from '../../data/mockData.js';

let _users = MOCK_TEAM.map((u) => ({ ...u }));

const mockUserService = {
  async getUsers() {
    await _delay(300);
    return { data: [..._users], error: null };
  },

  async createUser(user) {
    await _delay(500);
    const newUser = {
      ...user,
      id: `usr-${String(_users.length + 1).padStart(3, '0')}`,
      status: 'Actif',
      ca: '0K',
      caVal: 0,
      tasks: 0,
      demandes: 0,
      joinDate: new Date().toISOString().slice(0, 10),
    };
    _users = [newUser, ..._users];
    return { data: newUser, error: null };
  },

  async updateUser(id, patch) {
    await _delay(400);
    const idx = _users.findIndex((u) => u.id === id);
    if (idx === -1) return { data: null, error: { message: 'Utilisateur introuvable', code: 404 } };
    _users[idx] = { ..._users[idx], ...patch };
    return { data: _users[idx], error: null };
  },

  async deleteUser(id) {
    await _delay(300);
    const idx = _users.findIndex((u) => u.id === id);
    if (idx === -1) return { data: null, error: { message: 'Utilisateur introuvable', code: 404 } };
    _users = _users.filter((u) => u.id !== id);
    return { data: null, error: null };
  },
};

function _delay(ms) { return new Promise((r) => setTimeout(r, ms)); }

export default mockUserService;
