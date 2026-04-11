import React, { useState } from 'react';
import {
  User, Bell, Shield, Globe, Palette, Database,
  Save, Eye, EyeOff, CheckCircle2, Mail, Phone,
  Lock, AlertTriangle, ChevronRight, Moon, Sun, Monitor
} from 'lucide-react';

const ToggleSwitch = ({ enabled, onChange, label, description }) => (
  <div className="flex items-center justify-between py-4 border-b border-slate-50 last:border-0 group">
    <div className="flex-1 pr-8">
      <p className="text-sm font-bold text-text-primary group-hover:text-primary transition-colors">{label}</p>
      {description && <p className="text-xs text-text-secondary mt-0.5 leading-relaxed">{description}</p>}
    </div>
    <button
      onClick={() => onChange(!enabled)}
      className={`relative w-11 h-6 rounded-full transition-all duration-300 shrink-0 ${enabled ? 'bg-primary' : 'bg-slate-200'}`}
    >
      <div className={`absolute top-0.5 w-5 h-5 bg-white rounded-full shadow-sm transition-all duration-300 ${enabled ? 'left-[22px]' : 'left-0.5'}`}></div>
    </button>
  </div>
);

const SectionCard = ({ icon, title, children }) => (
  <div className="bg-white rounded-premium shadow-sm border border-slate-50 overflow-hidden">
    <div className="flex items-center gap-3 p-6 border-b border-slate-50">
      <div className="p-2.5 bg-slate-50 rounded-xl">{icon}</div>
      <h3 className="text-base font-bold text-text-primary">{title}</h3>
    </div>
    <div className="p-6">{children}</div>
  </div>
);

const SettingsView = () => {
  const [saved, setSaved] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [theme, setTheme] = useState('light');

  const [notifs, setNotifs] = useState({
    newDemande: true,
    taskDeadline: true,
    teamActivity: false,
    weeklyReport: true,
    emailNotifs: true,
    pushNotifs: false,
  });

  const [profile, setProfile] = useState({
    name: 'Jason Ranti',
    email: 'jason@olympia.ma',
    phone: '+212 600-000001',
    role: 'Administrateur',
    zone: 'Casablanca',
  });

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  const setNotif = (key) => (val) => setNotifs(prev => ({ ...prev, [key]: val }));

  return (
    <div className="max-w-[900px] mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-black text-text-primary tracking-tight mb-2">Paramètres</h1>
          <p className="text-text-secondary font-medium">Gérez votre profil, notifications et préférences système.</p>
        </div>
        <button
          onClick={handleSave}
          className={`flex items-center gap-2 px-6 py-3 rounded-xl font-bold transition-all shadow-lg ${
            saved
              ? 'bg-success text-white shadow-success/20'
              : 'bg-primary text-white shadow-primary/20 hover:bg-primary-dark hover:-translate-y-0.5'
          }`}
        >
          {saved ? <CheckCircle2 size={18} /> : <Save size={18} />}
          {saved ? 'Sauvegardé !' : 'Sauvegarder'}
        </button>
      </div>

      {/* Profile */}
      <SectionCard icon={<User size={18} className="text-primary" />} title="Profil Administrateur">
        <div className="flex items-center gap-5 mb-8 pb-6 border-b border-slate-50">
          <div className="relative">
            <div className="w-20 h-20 rounded-2xl bg-primary/10 text-primary flex items-center justify-center text-2xl font-black border border-primary/10">
              JR
            </div>
            <button className="absolute -bottom-1 -right-1 w-6 h-6 bg-primary rounded-full flex items-center justify-center text-white shadow-sm hover:bg-primary-dark transition-colors">
              <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
              </svg>
            </button>
          </div>
          <div>
            <h4 className="font-bold text-text-primary">{profile.name}</h4>
            <p className="text-xs font-bold text-text-secondary uppercase tracking-widest mt-1">{profile.role}</p>
            <div className="flex items-center gap-1.5 mt-2">
              <div className="w-1.5 h-1.5 bg-success rounded-full"></div>
              <span className="text-xs text-success font-bold">Compte actif</span>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
          {[
            { label: 'Nom complet', key: 'name', icon: <User size={14} /> },
            { label: 'Email professionnel', key: 'email', type: 'email', icon: <Mail size={14} /> },
            { label: 'Téléphone', key: 'phone', icon: <Phone size={14} /> },
            { label: 'Zone commerciale', key: 'zone', icon: <Globe size={14} /> },
          ].map(field => (
            <div key={field.key} className="space-y-2">
              <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">{field.label}</label>
              <div className="relative">
                <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-text-secondary">{field.icon}</span>
                <input
                  type={field.type || 'text'}
                  value={profile[field.key]}
                  onChange={(e) => setProfile(p => ({ ...p, [field.key]: e.target.value }))}
                  className="w-full pl-10 pr-4 py-3 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all text-sm font-medium text-text-primary"
                />
              </div>
            </div>
          ))}
        </div>
      </SectionCard>

      {/* Security */}
      <SectionCard icon={<Lock size={18} className="text-secondary" />} title="Sécurité & Mot de Passe">
        <div className="space-y-5">
          {[
            { label: 'Mot de passe actuel', placeholder: '••••••••' },
            { label: 'Nouveau mot de passe', placeholder: '••••••••' },
            { label: 'Confirmer le nouveau mot de passe', placeholder: '••••••••' },
          ].map((field, i) => (
            <div key={i} className="space-y-2">
              <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">{field.label}</label>
              <div className="relative">
                <Lock size={14} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-text-secondary" />
                <input
                  type={showPassword ? 'text' : 'password'}
                  placeholder={field.placeholder}
                  className="w-full pl-10 pr-12 py-3 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all text-sm font-medium"
                />
                {i === 0 && (
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3.5 top-1/2 -translate-y-1/2 text-text-secondary hover:text-primary transition-colors"
                  >
                    {showPassword ? <EyeOff size={14} /> : <Eye size={14} />}
                  </button>
                )}
              </div>
            </div>
          ))}

          <div className="p-4 bg-amber-50 rounded-xl border border-amber-100 flex items-start gap-3 mt-2">
            <AlertTriangle size={16} className="text-warning mt-0.5 shrink-0" />
            <p className="text-xs font-medium text-amber-700">
              Le mot de passe doit contenir au moins 8 caractères, une majuscule, un chiffre et un caractère spécial.
            </p>
          </div>

          <button className="px-6 py-3 bg-primary text-white rounded-xl text-sm font-bold hover:bg-primary-dark transition-all shadow-lg shadow-primary/20 hover:-translate-y-0.5">
            Mettre à jour le mot de passe
          </button>
        </div>
      </SectionCard>

      {/* Notifications */}
      <SectionCard icon={<Bell size={18} className="text-warning" />} title="Préférences de Notifications">
        <ToggleSwitch
          enabled={notifs.newDemande}
          onChange={setNotif('newDemande')}
          label="Nouvelle demande soumise"
          description="Soyez notifié lorsqu'un commercial soumet une nouvelle demande."
        />
        <ToggleSwitch
          enabled={notifs.taskDeadline}
          onChange={setNotif('taskDeadline')}
          label="Tâches en retard"
          description="Alertes pour les tâches dont l'échéance est dépassée."
        />
        <ToggleSwitch
          enabled={notifs.teamActivity}
          onChange={setNotif('teamActivity')}
          label="Activité de l'équipe"
          description="Mises à jour sur les actions des commerciaux en temps réel."
        />
        <ToggleSwitch
          enabled={notifs.weeklyReport}
          onChange={setNotif('weeklyReport')}
          label="Rapport hebdomadaire"
          description="Recevez un résumé des performances chaque lundi matin."
        />
        <ToggleSwitch
          enabled={notifs.emailNotifs}
          onChange={setNotif('emailNotifs')}
          label="Notifications par Email"
          description="Envoi des alertes importantes sur votre adresse email professionnelle."
        />
        <ToggleSwitch
          enabled={notifs.pushNotifs}
          onChange={setNotif('pushNotifs')}
          label="Notifications Push"
          description="Activez les notifications dans le navigateur."
        />
      </SectionCard>

      {/* Appearance */}
      <SectionCard icon={<Palette size={18} className="text-purple-500" />} title="Apparence">
        <div>
          <p className="text-xs font-bold text-text-secondary uppercase tracking-widest mb-4">Thème de l'interface</p>
          <div className="grid grid-cols-3 gap-3">
            {[
              { value: 'light', label: 'Clair', icon: <Sun size={18} /> },
              { value: 'dark', label: 'Sombre', icon: <Moon size={18} /> },
              { value: 'system', label: 'Système', icon: <Monitor size={18} /> },
            ].map(t => (
              <button
                key={t.value}
                onClick={() => setTheme(t.value)}
                className={`flex flex-col items-center gap-2.5 p-5 rounded-xl border-2 transition-all ${
                  theme === t.value
                    ? 'border-primary bg-primary/5 text-primary'
                    : 'border-slate-100 bg-slate-50 text-text-secondary hover:border-slate-200'
                }`}
              >
                {t.icon}
                <span className="text-xs font-bold">{t.label}</span>
              </button>
            ))}
          </div>
        </div>
      </SectionCard>

      {/* Danger Zone */}
      <SectionCard icon={<AlertTriangle size={18} className="text-error" />} title="Zone Critique">
        <div className="space-y-3">
          <div className="flex items-center justify-between p-4 bg-red-50 rounded-xl border border-red-100">
            <div>
              <p className="text-sm font-bold text-error">Réinitialiser toutes les données</p>
              <p className="text-xs text-red-400 mt-0.5">Supprime toutes les données de démonstration.</p>
            </div>
            <button className="px-4 py-2 text-xs font-bold text-error bg-white rounded-xl border border-red-100 hover:bg-red-50 transition-all">
              Réinitialiser
            </button>
          </div>
          <div className="flex items-center justify-between p-4 bg-red-50 rounded-xl border border-red-100">
            <div>
              <p className="text-sm font-bold text-error">Désactiver le compte</p>
              <p className="text-xs text-red-400 mt-0.5">Désactive temporairement cet accès administrateur.</p>
            </div>
            <button className="px-4 py-2 text-xs font-bold text-error bg-white rounded-xl border border-red-100 hover:bg-red-50 transition-all">
              Désactiver
            </button>
          </div>
        </div>
      </SectionCard>
    </div>
  );
};

export default SettingsView;
