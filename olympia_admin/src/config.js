// API base. '/api' is proxied to the .NET backend by Vite (see vite.config.js),
// which avoids CORS and self-signed HTTPS issues in dev.
export const API_BASE_URL = '/api';

// Per-service data source: false = real .NET backend, true = local mock data.
// Everything now runs against the real backend (no static/mock data).
export const USE_MOCK = {
  auth: false,
  dashboard: false,
  demandes: false,
  tasks: false,
  clients: false,
  users: false,
};

// AuthContext uses this to decide local persistence vs token-based rehydrate.
export const USE_MOCK_DATA = USE_MOCK.auth;
