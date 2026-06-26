import apiClient from './apiClient.js';

// The backend exposes a leaner user than the admin UI shows. We map what exists
// and surface "—" for fields the API doesn't provide yet (phone, per-user CA/counts).
const roleToUi = (r) =>
  (r || '').toLowerCase() === 'admin' ? 'Administrateur' : 'Commercial';
const roleToApi = (r) => (r === 'Administrateur' ? 'Admin' : 'Commercial');

const initials = (name = '') =>
  name.split(/\s+/).filter(Boolean).slice(0, 2).map((w) => w[0]?.toUpperCase() ?? '').join('') || '?';

function toUi(dto, overrides = {}) {
  const name = `${dto.prenom ?? ''} ${dto.nom ?? ''}`.trim();
  return {
    id: dto.id,
    name,
    prenom: dto.prenom,
    nom: dto.nom,
    email: dto.email,
    role: roleToUi(dto.role),
    zone: dto.zone ?? '',
    objectif: dto.objectifCA ?? 0,
    avatar: initials(name),
    status: 'Actif',     // backend UserDto doesn't expose isActive yet
    phone: '—',
    ca: '—',
    tasks: '—',
    demandes: '—',
    joinDate: '—',
    ...overrides,
  };
}

function splitName(name = '') {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  const prenom = parts[0] ?? '';
  const nom = parts.slice(1).join(' ') || prenom;
  return { prenom, nom };
}

const userService = {
  async getUsers() {
    const { data, error } = await apiClient.get('/users', { page: 1, pageSize: 100 });
    if (error) return { data: null, error };
    const list = (data?.data ?? []).map((d) => toUi(d));
    return { data: list, error: null };
  },

  async createUser(form) {
    if (!form.password || form.password.length < 8)
      return { data: null, error: { message: 'Mot de passe requis (8 caractères min).' } };
    const { prenom, nom } = splitName(form.name);
    const body = {
      email: form.email,
      password: form.password,
      nom,
      prenom,
      role: roleToApi(form.role),
      zone: form.zone || null,
    };
    const { data, error } = await apiClient.post('/users', body);
    if (error) return { data: null, error };
    return { data: toUi(data), error: null };
  },

  async updateUser(id, patch) {
    // Status toggle path
    if (patch.status && Object.keys(patch).length === 1) {
      const { data, error } = await apiClient.put(`/users/${id}`, { isActive: patch.status === 'Actif' });
      if (error) return { data: null, error };
      return { data: toUi(data, { status: patch.status }), error: null };
    }
    // Edit path (email is the login identity → not editable server-side)
    const { prenom, nom } = splitName(patch.name ?? '');
    const body = {
      ...(patch.name ? { nom, prenom } : {}),
      ...(patch.role ? { role: roleToApi(patch.role) } : {}),
      ...(patch.zone !== undefined ? { zone: patch.zone || null } : {}),
    };
    const { data, error } = await apiClient.put(`/users/${id}`, body);
    if (error) return { data: null, error };
    return { data: toUi(data), error: null };
  },

  deleteUser: (id) => apiClient.delete(`/users/${id}`),
};

export default userService;
