import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { Services } from '../services/index.js';
import { persistUser, getStoredUser, clearStoredUser } from '../services/userStorage.js';
import { USE_MOCK_DATA } from '../config.js';
import { getToken, onSessionExpired } from '../services/apiClient.js';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  // Rehydrate from localStorage on mount
  useEffect(() => {
    const token = getToken();
    if (!token) { setIsLoading(false); return; }

    if (USE_MOCK_DATA) {
      const stored = getStoredUser();
      setUser(stored);
      setIsLoading(false);
    } else {
      Services.auth.getProfile()
        .then(({ data }) => setUser(data))
        .catch(() => {})
        .finally(() => setIsLoading(false));
    }
  }, []);

  // Listen for session expiry from apiClient
  useEffect(() => {
    return onSessionExpired(() => setUser(null));
  }, []);

  const login = useCallback(async (email, password) => {
    const { data, error } = await Services.auth.login(email, password);
    if (error) return { error };
    setUser(data);
    if (USE_MOCK_DATA) persistUser(data);
    return { data };
  }, []);

  const logout = useCallback(async () => {
    await Services.auth.logout();
    if (USE_MOCK_DATA) clearStoredUser();
    setUser(null);
  }, []);

  return (
    <AuthContext.Provider value={{ user, isAuthenticated: !!user, isLoading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
