import React, { useState } from 'react';
import { Search, Bell, Mail, ChevronDown, User, Settings, LogOut } from 'lucide-react';
import Dropdown from './Dropdown';
import NotificationSheet from './NotificationSheet';
import { useAuth } from '../context/AuthContext.jsx';

const Navbar = () => {
  const { user, logout } = useAuth();
  const [isNotifOpen, setIsNotifOpen] = useState(false);
  const displayName = user ? `${user.prenom} ${user.nom}` : 'Admin';
  const initials = user ? `${user.prenom?.[0] ?? ''}${user.nom?.[0] ?? ''}`.toUpperCase() : 'AD';

  return (
    <nav className="h-[var(--navbar-height)] w-[calc(100%-var(--sidebar-width))] bg-surface border-b border-slate-100 flex items-center justify-between px-8 fixed top-0 right-0 z-[999]">
      <div className="flex items-center bg-slate-50 rounded-full px-4 py-2 w-[400px] gap-3 border border-slate-100 transition-all focus-within:border-primary/30 focus-within:bg-white focus-within:shadow-sm">
        <Search size={18} className="text-text-secondary" />
        <input 
          type="text" 
          placeholder="Rechercher une demande, tâche..." 
          className="bg-transparent border-none outline-none w-full text-sm text-text-primary placeholder:text-text-secondary/50"
        />
      </div>

      <div className="flex items-center gap-5">
        <div className="w-10 h-10 border-radius-pill transition-colors flex items-center justify-center text-text-primary relative cursor-pointer hover:bg-slate-50">
          <Mail size={20} />
        </div>
        <div 
          className="w-10 h-10 border-radius-pill transition-colors flex items-center justify-center text-text-primary relative cursor-pointer hover:bg-slate-50"
          onClick={() => setIsNotifOpen(true)}
        >
          <Bell size={20} />
          <span className="absolute top-2.5 right-2.5 w-2 h-2 bg-error rounded-full border-2 border-surface"></span>
        </div>
        
        <Dropdown 
          trigger={
            <div className="flex items-center gap-3 px-3 py-1.5 bg-slate-50 rounded-full transition-all cursor-pointer hover:bg-slate-100 border border-slate-100">
              <div className="w-8 h-8 rounded-full bg-primary text-white flex items-center justify-center text-xs font-bold shadow-sm">
                {initials}
              </div>
              <div className="flex items-center gap-2">
                <span className="text-sm font-bold text-text-primary">{displayName}</span>
                <ChevronDown size={14} className="text-text-secondary" />
              </div>
            </div>
          }
        >
          <div className="px-1 py-1">
            <div className="flex items-center gap-3 px-3 py-2.5 rounded-subtle text-sm font-medium text-text-primary transition-colors hover:bg-background hover:text-primary cursor-pointer">
              <User size={16} />
              <span>Mon Profil</span>
            </div>
            <div className="flex items-center gap-3 px-3 py-2.5 rounded-subtle text-sm font-medium text-text-primary transition-colors hover:bg-background hover:text-primary cursor-pointer">
              <Settings size={16} />
              <span>Paramètres</span>
            </div>
            <div className="h-px bg-slate-100 my-1 mx-2"></div>
            <div onClick={logout} className="flex items-center gap-3 px-3 py-2.5 rounded-subtle text-sm font-medium text-error transition-colors hover:bg-red-50 cursor-pointer">
              <LogOut size={16} />
              <span>Déconnexion</span>
            </div>
          </div>
        </Dropdown>
      </div>

      <NotificationSheet isOpen={isNotifOpen} onClose={() => setIsNotifOpen(false)} />
    </nav>
  );
};

export default Navbar;
