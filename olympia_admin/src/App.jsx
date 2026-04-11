import React, { useState } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Navbar from './components/Navbar';
import DashboardView from './views/DashboardView';
import DemandeView from './views/DemandeView';
import TaskView from './views/TaskView';
import UserView from './views/UserView';
import ReportsView from './views/ReportsView';
import SettingsView from './views/SettingsView';
import LoginView from './views/LoginView';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  if (!isAuthenticated) {
    return <LoginView onLogin={() => setIsAuthenticated(true)} />;
  }

  return (
    <div className="flex min-h-screen bg-background text-text-primary">
      <Sidebar onLogout={() => setIsAuthenticated(false)} />
      <div className="flex-1 flex flex-col ml-[var(--sidebar-width)] transition-all duration-300">
        <Navbar onLogout={() => setIsAuthenticated(false)} />
        <main className="mt-[var(--navbar-height)] p-8 h-[calc(100vh-var(--navbar-height))] overflow-y-auto">
          <Routes>
            <Route path="/dashboard" element={<DashboardView />} />
            <Route path="/demandes" element={<DemandeView />} />
            <Route path="/tasks" element={<TaskView />} />
            <Route path="/users" element={<UserView />} />
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

export default App;
