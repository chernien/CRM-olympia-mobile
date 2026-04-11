import React from 'react';
import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard, ClipboardList, CheckSquare, Users,
  Settings, LogOut, BarChart2, Shield
} from 'lucide-react';

const Sidebar = ({ onLogout }) => {
  const mainItems = [
    { name: 'Dashboard',    icon: <LayoutDashboard size={20} />, path: '/dashboard' },
    { name: 'Demandes',     icon: <ClipboardList size={20} />,   path: '/demandes' },
    { name: 'Tâches',       icon: <CheckSquare size={20} />,     path: '/tasks' },
    { name: 'Équipe',       icon: <Users size={20} />,           path: '/users' },
    { name: 'Rapports',     icon: <BarChart2 size={20} />,       path: '/reports' },
  ];

  const bottomItems = [
    { name: 'Paramètres',   icon: <Settings size={20} />,        path: '/settings' },
  ];

  const renderNav = (items) => (
    <div className="flex flex-col gap-1 px-4">
      {items.map((item) => (
        <NavLink
          key={item.name}
          to={item.path}
          className={({ isActive }) =>
            `flex items-center gap-4 px-4 py-3 rounded-subtle transition-all duration-200 group
            ${isActive
              ? 'bg-primary text-white shadow-lg shadow-primary/20'
              : 'text-text-secondary hover:bg-slate-50 hover:text-primary'
            }`
          }
        >
          <span className="shrink-0">{item.icon}</span>
          <span className="font-semibold text-sm">{item.name}</span>
        </NavLink>
      ))}
    </div>
  );

  return (
    <div className="w-[var(--sidebar-width)] h-screen bg-white border-r border-slate-100 fixed left-0 top-0 z-[1000] flex flex-col shadow-sidebar">
      {/* Logo */}
      <div className="p-8 pb-8 flex items-center gap-3">
        <div className="w-9 h-9 bg-primary rounded-xl flex items-center justify-center shadow-lg shadow-primary/20">
          <Shield size={18} className="text-white" />
        </div>
        <div>
          <span className="text-xl font-black italic tracking-tighter text-primary">Olympia</span>
          <p className="text-[9px] font-bold text-text-secondary uppercase tracking-widest">Admin</p>
        </div>
      </div>

      {/* Nav */}
      <nav className="flex-1 overflow-y-auto custom-scrollbar space-y-1">
        <div className="mb-6">
          <h3 className="px-8 mb-3 text-[10px] font-bold uppercase tracking-widest text-text-secondary opacity-40">
            Navigation
          </h3>
          {renderNav(mainItems)}
        </div>

        <div>
          <h3 className="px-8 mb-3 text-[10px] font-bold uppercase tracking-widest text-text-secondary opacity-40">
            Système
          </h3>
          {renderNav(bottomItems)}
        </div>
      </nav>

      {/* User + Logout */}
      <div className="p-4 border-t border-slate-100">
        <div className="flex items-center gap-3 p-3 rounded-xl bg-slate-50 border border-slate-100 mb-3">
          <div className="w-9 h-9 rounded-xl bg-primary text-white flex items-center justify-center text-xs font-black shrink-0">
            JR
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-bold text-text-primary truncate">Jason Ranti</p>
            <p className="text-[10px] font-bold text-text-secondary uppercase tracking-widest">Admin</p>
          </div>
        </div>
        <button
          onClick={onLogout}
          className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-error hover:bg-red-50 transition-all text-sm font-semibold"
        >
          <LogOut size={18} />
          Déconnexion
        </button>
      </div>
    </div>
  );
};

export default Sidebar;
