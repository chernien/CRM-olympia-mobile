import { API_BASE_URL } from '../config.js';

const TOKEN_KEY = 'olympia_token';
const REFRESH_KEY = 'olympia_refresh_token';

export function getToken() {
  return localStorage.getItem(TOKEN_KEY);
}

export function getRefreshToken() {
  return localStorage.getItem(REFRESH_KEY);
}

export function setToken(token, refreshToken) {
  if (token) localStorage.setItem(TOKEN_KEY, token);
  if (refreshToken) localStorage.setItem(REFRESH_KEY, refreshToken);
}

export function clearTokens() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(REFRESH_KEY);
}

// Session expiry listeners — mirrors DioClient sessionExpired stream
const _sessionListeners = new Set();
export function onSessionExpired(cb) {
  _sessionListeners.add(cb);
  return () => _sessionListeners.delete(cb);
}
function _emitSessionExpired() {
  _sessionListeners.forEach((cb) => cb());
}

// The .NET backend wraps every payload:
//   single  -> { data: {...} }
//   list    -> { data: [...], total, page, pageSize }
//   error   -> { error: { message, code, fieldErrors? } }
// Normalize so callers always get { data, error } where, on success:
//   - list   -> data = { data, total, page, pageSize }  (kept as-is for pagination)
//   - single -> data = the inner object (unwrapped)
function _normalizeBody(body) {
  if (body && typeof body === 'object') {
    if (body.error) return { data: null, error: body.error };
    if ('total' in body && 'page' in body && 'pageSize' in body) {
      return { data: body, error: null }; // paged list — keep the envelope
    }
    if ('data' in body) return { data: body.data, error: null }; // single — unwrap
  }
  return { data: body, error: null };
}

async function _refreshToken() {
  const refresh = getRefreshToken();
  if (!refresh) return false;
  try {
    const res = await fetch(`${API_BASE_URL}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken: refresh }),
    });
    if (!res.ok) return false;
    const json = await res.json();
    const payload = json?.data ?? json; // unwrap { data: { accessToken, refreshToken } }
    if (!payload?.accessToken) return false;
    setToken(payload.accessToken, payload.refreshToken);
    return true;
  } catch {
    return false;
  }
}

const AUTH_PATHS = ['/auth/login', '/auth/refresh'];

async function request(path, options = {}, retrying = false) {
  const token = getToken();
  const headers = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...options.headers,
  };

  let res;
  try {
    res = await fetch(`${API_BASE_URL}${path}`, { ...options, headers });
  } catch {
    return { data: null, error: { message: 'Erreur réseau — le serveur backend est-il démarré ?' } };
  }

  // Auto-refresh on 401 — but never for the auth endpoints themselves
  // (a failed login must surface its own message, not "session expirée").
  const isAuthCall = AUTH_PATHS.some((p) => path.startsWith(p));
  if (res.status === 401 && !retrying && !isAuthCall) {
    const refreshed = await _refreshToken();
    if (refreshed) return request(path, options, true);
    clearTokens();
    _emitSessionExpired();
    return { data: null, error: { message: 'Session expirée', code: 401 } };
  }

  let body = null;
  try {
    body = await res.json();
  } catch {
    /* no body (e.g. 204 No Content) */
  }

  if (!res.ok) {
    const err = (body && body.error) || {};
    return {
      data: null,
      error: {
        message: err.message || `Erreur ${res.status}`,
        code: err.code || res.status,
        fieldErrors: err.fieldErrors,
      },
    };
  }

  return _normalizeBody(body);
}

const apiClient = {
  get: (path, params) => {
    const url = params ? `${path}?${new URLSearchParams(params)}` : path;
    return request(url, { method: 'GET' });
  },
  post: (path, body) => request(path, { method: 'POST', body: JSON.stringify(body) }),
  put: (path, body) => request(path, { method: 'PUT', body: JSON.stringify(body) }),
  delete: (path) => request(path, { method: 'DELETE' }),
};

export default apiClient;
