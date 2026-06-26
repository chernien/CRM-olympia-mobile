const KEY = 'olympia_user';

export function persistUser(user) {
  try { localStorage.setItem(KEY, JSON.stringify(user)); } catch (_) {}
}

export function getStoredUser() {
  try { return JSON.parse(localStorage.getItem(KEY)); } catch (_) { return null; }
}

export function clearStoredUser() {
  localStorage.removeItem(KEY);
}
