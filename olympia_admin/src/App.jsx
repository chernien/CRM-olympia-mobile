import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext.jsx';
import Sidebar from './components/Sidebar';
import Navbar from './components/Navbar';
import DashboardView from './views/DashboardView';
import DemandeView from './views/DemandeView';
import TaskView from './views/TaskView';
import UserView from './views/UserView';
import ObjectifsView from './views/ObjectifsView';
import ReportsView from './views/ReportsView';
import SettingsView from './views/SettingsView';
import LoginView from './views/LoginView';

function AdminOnly({ children }) {
  const { user } = useAuth();
  if (user?.role !== 'admin') return <Navigate to="/dashboard" replace />;
  return children;
}

function AppShell() {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="w-8 h-8 border-2 border-primary/30 border-t-primary rounded-full animate-spin" />
      </div>
    );
  }

  if (!isAuthenticated) {
    return <LoginView />;
  }

  return (
    <div className="flex min-h-screen bg-background text-text-primary">
      <Sidebar />
      <div className="flex-1 flex flex-col ml-[var(--sidebar-width)] transition-all duration-300">
        <Navbar />
        <main className="mt-[var(--navbar-height)] p-8 h-[calc(100vh-var(--navbar-height))] overflow-y-auto">
          <Routes>
            <Route path="/dashboard" element={<DashboardView />} />
            <Route path="/demandes" element={<DemandeView />} />
            <Route path="/tasks" element={<TaskView />} />
            <Route path="/objectifs" element={<ObjectifsView />} />
            <Route path="/users" element={<AdminOnly><UserView /></AdminOnly>} />
            <Route path="/reports" element={<ReportsView />} />
            <Route path="/settings" element={<SettingsView />} />
            <Route path="/" element={<Navigate to="/dashboard" replace />} />
            <Route path="*" element={<Navigate to="/dashboard" replace />} />
          </Routes>
        </main>
      </div>
    </div>
  );
}

function App() {
  return (
    <AuthProvider>
      <AppShell />
    </AuthProvider>
  );
}

export default App;
