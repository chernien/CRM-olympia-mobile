import React, { useState } from 'react';
import {
  Plus, Search, Shield, User, Mail, Phone, UserPlus, Briefcase,
  Users, Edit2, Eye, CheckCircle2, XCircle, MapPin, TrendingUp,
  ClipboardList, Target, X
} from 'lucide-react';
import Modal from '../components/Modal';
import Select from '../components/Select';
import ConfirmDialog from '../components/ConfirmDialog';

// ── Constants ────────────────────────────────────────────────────────────────
const ROLES = {
  'Administrateur': { icon: <Shield size={12} />, badge: 'bg-purple-50 text-purple-600 border-purple-100', color: 'bg-purple-50 text-purple-700' },
  'Commercial':     { icon: <Briefcase size={12} />, badge: 'bg-primary/10 text-primary border-primary/20', color: 'bg-blue-50 text-blue-700' },
  'Magasinier':     { icon: <Users size={12} />, badge: 'bg-amber-50 text-amber-600 border-amber-100', color: 'bg-amber-50 text-amber-700' },
};

const ZONES = ['Casablanca Nord', 'Casablanca Sud', 'Rabat Centre', 'Marrakech', 'Tanger', 'Fès', 'El Jadida'];

const INITIAL_USERS = [
  {
    id: 1, name: 'Jason Ranti', role: 'Administrateur', email: 'jason@olympia.ma',
    phone: '+212 600-000001', status: 'Actif', avatar: 'JR', zone: 'Casablanca',
    ca: '—', tasks: 0, demandes: 0, joinDate: '2022-01-15',
  },
  {
    id: 2, name: 'Taha Mejdoub', role: 'Commercial', email: 'taha@olympia.ma',
    phone: '+212 600-000003', status: 'Actif', avatar: 'TM', zone: 'Casablanca Nord',
    ca: '52K', tasks: 8, demandes: 14, joinDate: '2023-03-01',
  },
  {
    id: 3, name: 'Ahmed Salhi', role: 'Commercial', email: 'ahmed@olympia.ma',
    phone: '+212 600-000002', status: 'Actif', avatar: 'AS', zone: 'Rabat Centre',
    ca: '43K', tasks: 6, demandes: 11, joinDate: '2023-05-10',
  },
  {
    id: 4, name: 'Yassine Rachidi', role: 'Magasinier', email: 'yassine@olympia.ma',
    phone: '+212 600-000004', status: 'Actif', avatar: 'YR', zone: 'Marrakech',
    ca: '30K', tasks: 4, demandes: 7, joinDate: '2023-08-20',
  },
  {
    id: 5, name: 'Leila Benali', role: 'Commercial', email: 'leila@olympia.ma',
    phone: '+212 600-000005', status: 'Inactif', avatar: 'LB', zone: 'Fès',
    ca: '18K', tasks: 2, demandes: 5, joinDate: '2024-01-08',
  },
];

const EMPTY_FORM = { name: '', email: '', phone: '', role: 'Commercial', zone: 'Casablanca Nord' };

// ── User Card ─────────────────────────────────────────────────────────────────
const UserCard = ({ user, onView, onEdit, onToggleStatus }) => {
  const roleConfig = ROLES[user.role] || ROLES['Commercial'];

  return (
    <div className="bg-white p-6 rounded-premium shadow-sm border border-slate-50 hover:shadow-md transition-all group">
      <div className="flex items-start justify-between mb-5">
        <div className="flex items-center gap-3">
          <div className={`w-12 h-12 rounded-2xl ${roleConfig.color} flex items-center justify-center text-lg font-black shadow-sm`}>
            {user.avatar}
          </div>
          <div>
            <h4 className="font-bold text-text-primary group-hover:text-primary transition-colors">{user.name}</h4>
            <div className={`inline-flex items-center gap-1.5 mt-1 px-2 py-0.5 rounded-full text-[10px] font-black uppercase tracking-widest border ${roleConfig.badge}`}>
              {roleConfig.icon}
              {user.role}
            </div>
          </div>
        </div>
        <span className={`px-2 py-1 rounded-md text-[8px] font-black uppercase tracking-widest ${
          user.status === 'Actif' ? 'bg-success/10 text-success' : 'bg-red-50 text-error'
        }`}>
          {user.status}
        </span>
      </div>

      {/* Contact */}
      <div className="space-y-2 py-4 border-y border-slate-50">
        <div className="flex items-center gap-3 text-xs font-medium text-text-secondary">
          <Mail size={13} className="opacity-50 shrink-0" />
          <span className="truncate">{user.email}</span>
        </div>
        <div className="flex items-center gap-3 text-xs font-medium text-text-secondary">
          <Phone size={13} className="opacity-50 shrink-0" />
          <span>{user.phone}</span>
        </div>
        {user.zone && (
          <div className="flex items-center gap-3 text-xs font-medium text-text-secondary">
            <MapPin size={13} className="opacity-50 shrink-0" />
            <span>{user.zone}</span>
          </div>
        )}
      </div>

      {/* Stats */}
      {user.role === 'Commercial' && (
        <div className="grid grid-cols-3 gap-2 py-4 border-b border-slate-50">
          {[
            { icon: <TrendingUp size={11} />, label: 'CA', value: user.ca, color: 'text-primary' },
            { icon: <ClipboardList size={11} />, label: 'Tâches', value: user.tasks, color: 'text-secondary' },
            { icon: <Target size={11} />, label: 'Demandes', value: user.demandes, color: 'text-warning' },
          ].map((stat, i) => (
            <div key={i} className="text-center p-2 bg-slate-50 rounded-xl">
              <div className={`flex items-center justify-center gap-1 ${stat.color} mb-0.5`}>
                {stat.icon}
                <span className="text-xs font-black">{stat.value}</span>
              </div>
              <span className="text-[9px] font-bold text-text-secondary uppercase tracking-widest">{stat.label}</span>
            </div>
          ))}
        </div>
      )}

      {/* Actions */}
      <div className="flex gap-2 mt-4">
        <button
          onClick={() => onView(user)}
          className="flex-1 py-2 text-xs font-bold text-primary bg-primary/10 rounded-lg hover:bg-primary hover:text-white transition-all flex items-center justify-center gap-1.5"
        >
          <Eye size={12} /> Profil
        </button>
        <button
          onClick={() => onEdit(user)}
          className="flex-1 py-2 text-xs font-bold text-secondary bg-secondary/10 rounded-lg hover:bg-secondary hover:text-white transition-all flex items-center justify-center gap-1.5"
        >
          <Edit2 size={12} /> Modifier
        </button>
        <button
          onClick={() => onToggleStatus(user)}
          className={`p-2 rounded-lg transition-all border text-xs font-bold ${
            user.status === 'Actif'
              ? 'bg-red-50 text-error border-red-100 hover:bg-error hover:text-white'
              : 'bg-success/10 text-success border-success/20 hover:bg-success hover:text-white'
          }`}
          title={user.status === 'Actif' ? 'Désactiver' : 'Activer'}
        >
          {user.status === 'Actif' ? <XCircle size={14} /> : <CheckCircle2 size={14} />}
        </button>
      </div>
    </div>
  );
};

// ── Main View ─────────────────────────────────────────────────────────────────
const UserView = () => {
  const [users, setUsers] = useState(INITIAL_USERS);
  const [filterRole, setFilterRole] = useState('Tous');
  const [filterStatus, setFilterStatus] = useState('Tous');
  const [searchQuery, setSearchQuery] = useState('');

  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [editUser, setEditUser] = useState(null);
  const [viewUser, setViewUser] = useState(null);
  const [toggleUser, setToggleUser] = useState(null);
  const [form, setForm] = useState(EMPTY_FORM);

  const setF = (key) => (val) => setForm(prev => ({ ...prev, [key]: val }));

  const roleOptions = Object.keys(ROLES).map(r => ({ value: r, label: r, icon: Shield }));
  const zoneOptions = ZONES.map(z => ({ value: z, label: z, icon: MapPin }));

  const filtered = users.filter(u => {
    const mr = filterRole === 'Tous' || u.role === filterRole;
    const ms = filterStatus === 'Tous' || u.status === filterStatus;
    const mq = u.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
               u.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
               (u.zone || '').toLowerCase().includes(searchQuery.toLowerCase());
    return mr && ms && mq;
  });

  const handleCreate = () => {
    const initials = form.name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();
    const newUser = {
      id: users.length + 1,
      ...form,
      status: 'Actif',
      avatar: initials,
      ca: '0K',
      tasks: 0,
      demandes: 0,
      joinDate: new Date().toISOString().split('T')[0],
    };
    setUsers(prev => [newUser, ...prev]);
    setForm(EMPTY_FORM);
    setIsCreateOpen(false);
  };

  const handleEdit = () => {
    setUsers(prev => prev.map(u => u.id === editUser.id ? { ...u, ...form } : u));
    setEditUser(null);
    setForm(EMPTY_FORM);
  };

  const openEdit = (user) => {
    setForm({ name: user.name, email: user.email, phone: user.phone || '', role: user.role, zone: user.zone || '' });
    setEditUser(user);
  };

  const handleToggleStatus = () => {
    setUsers(prev => prev.map(u =>
      u.id === toggleUser.id ? { ...u, status: u.status === 'Actif' ? 'Inactif' : 'Actif' } : u
    ));
    setToggleUser(null);
  };

  const UserForm = ({ onSubmit, submitLabel }) => (
    <div className="space-y-5">
      <div className="grid grid-cols-2 gap-5">
        <div className="space-y-2">
          <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Nom complet <span className="text-error">*</span></label>
          <input
            value={form.name}
            onChange={(e) => setF('name')(e.target.value)}
            className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all font-medium text-sm placeholder:text-slate-300"
            placeholder="Prénom Nom"
          />
        </div>
        <div className="space-y-2">
          <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Rôle</label>
          <Select options={roleOptions} value={form.role} onChange={setF('role')} />
        </div>
      </div>
      <div className="space-y-2">
        <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Email professionnel <span className="text-error">*</span></label>
        <input
          type="email"
          value={form.email}
          onChange={(e) => setF('email')(e.target.value)}
          className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all font-medium text-sm placeholder:text-slate-300"
          placeholder="prenom.nom@olympia.ma"
        />
      </div>
      <div className="grid grid-cols-2 gap-5">
        <div className="space-y-2">
          <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Téléphone</label>
          <input
            value={form.phone}
            onChange={(e) => setF('phone')(e.target.value)}
            className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all font-medium text-sm placeholder:text-slate-300"
            placeholder="+212 6XX-XXXXXX"
          />
        </div>
        <div className="space-y-2">
          <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Zone</label>
          <Select options={zoneOptions} value={form.zone} onChange={setF('zone')} />
        </div>
      </div>
      <div className="flex justify-end gap-3 pt-2">
        <button type="button" onClick={() => { setIsCreateOpen(false); setEditUser(null); setForm(EMPTY_FORM); }} className="px-6 py-3 text-text-secondary font-bold hover:bg-slate-50 rounded-xl transition-all">
          Annuler
        </button>
        <button onClick={onSubmit} disabled={!form.name || !form.email} className="bg-primary text-white px-8 py-3 rounded-xl font-bold shadow-lg shadow-primary/20 hover:bg-primary-dark transition-all disabled:opacity-40 disabled:cursor-not-allowed">
          {submitLabel}
        </button>
      </div>
    </div>
  );

  return (
    <div className="max-w-[1400px] mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h1 className="text-3xl font-black text-text-primary tracking-tight mb-2">Annuaire de l'Équipe</h1>
          <p className="text-text-secondary font-medium">
            <span className="font-black text-text-primary">{users.filter(u => u.status === 'Actif').length}</span> membres actifs ·{' '}
            <span className="font-black text-text-primary">{users.filter(u => u.role === 'Commercial').length}</span> commerciaux
          </p>
        </div>
        <button
          onClick={() => { setForm(EMPTY_FORM); setIsCreateOpen(true); }}
          className="bg-primary text-white px-6 py-3 rounded-xl font-bold flex items-center gap-3 shadow-lg shadow-primary/20 transition-all hover:bg-primary-dark hover:-translate-y-0.5 self-start"
        >
          <UserPlus size={18} />
          Ajouter un membre
        </button>
      </div>

      {/* Filters */}
      <div className="bg-white p-5 rounded-premium shadow-sm border border-slate-50 flex flex-wrap items-center gap-5">
        <div className="flex-1 min-w-[240px] relative">
          <Search size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-text-secondary" />
          <input
            type="text"
            placeholder="Rechercher par nom, email ou zone..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-11 pr-4 py-3 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all text-sm font-medium"
          />
          {searchQuery && (
            <button onClick={() => setSearchQuery('')} className="absolute right-3.5 top-1/2 -translate-y-1/2 text-text-secondary hover:text-error transition-colors">
              <X size={14} />
            </button>
          )}
        </div>

        {/* Role filter */}
        <div className="flex items-center gap-1 bg-slate-50 p-1 rounded-xl border border-slate-100">
          {['Tous', ...Object.keys(ROLES)].map(r => (
            <button
              key={r}
              onClick={() => setFilterRole(r)}
              className={`px-3 py-2 rounded-lg text-xs font-bold transition-all ${filterRole === r ? 'bg-white text-primary shadow-sm' : 'text-text-secondary hover:text-text-primary'}`}
            >
              {r}
            </button>
          ))}
        </div>

        {/* Status filter */}
        <div className="flex items-center gap-1 bg-slate-50 p-1 rounded-xl border border-slate-100">
          {['Tous', 'Actif', 'Inactif'].map(s => (
            <button
              key={s}
              onClick={() => setFilterStatus(s)}
              className={`px-3 py-2 rounded-lg text-xs font-bold transition-all ${filterStatus === s ? 'bg-white text-primary shadow-sm' : 'text-text-secondary hover:text-text-primary'}`}
            >
              {s}
            </button>
          ))}
        </div>
      </div>

      {/* Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        {filtered.map(user => (
          <UserCard
            key={user.id}
            user={user}
            onView={setViewUser}
            onEdit={openEdit}
            onToggleStatus={setToggleUser}
          />
        ))}
      </div>

      {filtered.length === 0 && (
        <div className="bg-white rounded-premium shadow-sm border border-slate-50 py-20 text-center">
          <div className="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-4">
            <Search size={24} className="text-slate-200" />
          </div>
          <p className="font-bold text-text-secondary">Aucun membre trouvé.</p>
        </div>
      )}

      {/* Create Modal */}
      <Modal isOpen={isCreateOpen} onClose={() => { setIsCreateOpen(false); setForm(EMPTY_FORM); }} title="Ajouter un membre">
        <UserForm onSubmit={handleCreate} submitLabel="Créer le compte" />
      </Modal>

      {/* Edit Modal */}
      <Modal isOpen={!!editUser} onClose={() => { setEditUser(null); setForm(EMPTY_FORM); }} title={`Modifier — ${editUser?.name}`}>
        <UserForm onSubmit={handleEdit} submitLabel="Enregistrer" />
      </Modal>

      {/* View Profile Modal */}
      <Modal isOpen={!!viewUser} onClose={() => setViewUser(null)} title="Profil Collaborateur">
        {viewUser && (
          <div className="space-y-5">
            {/* Header */}
            <div className="flex items-center gap-4 p-5 bg-slate-50 rounded-xl border border-slate-100">
              <div className={`w-16 h-16 rounded-2xl ${ROLES[viewUser.role]?.color} flex items-center justify-center text-2xl font-black`}>
                {viewUser.avatar}
              </div>
              <div>
                <h3 className="text-lg font-bold text-text-primary">{viewUser.name}</h3>
                <div className={`inline-flex items-center gap-1.5 mt-1 px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border ${ROLES[viewUser.role]?.badge}`}>
                  {ROLES[viewUser.role]?.icon}
                  {viewUser.role}
                </div>
              </div>
              <span className={`ml-auto px-2.5 py-1 rounded-full text-[10px] font-black uppercase ${viewUser.status === 'Actif' ? 'bg-success/10 text-success' : 'bg-red-50 text-error'}`}>
                {viewUser.status}
              </span>
            </div>

            {/* Info */}
            <div className="grid grid-cols-2 gap-3">
              {[
                { label: 'Email', value: viewUser.email },
                { label: 'Téléphone', value: viewUser.phone || '—' },
                { label: 'Zone', value: viewUser.zone || '—' },
                { label: "Membre depuis", value: viewUser.joinDate },
              ].map((item, i) => (
                <div key={i} className="p-4 bg-slate-50 rounded-xl border border-slate-50">
                  <p className="text-[10px] font-bold text-text-secondary uppercase tracking-widest mb-1.5">{item.label}</p>
                  <p className="text-sm font-bold text-text-primary truncate">{item.value}</p>
                </div>
              ))}
            </div>

            {/* Performance */}
            {viewUser.role === 'Commercial' && (
              <div>
                <p className="text-xs font-bold text-text-secondary uppercase tracking-widest mb-3">Performance</p>
                <div className="grid grid-cols-3 gap-3">
                  {[
                    { label: 'CA réalisé', value: viewUser.ca + ' MAD', color: 'text-primary' },
                    { label: 'Tâches', value: String(viewUser.tasks), color: 'text-secondary' },
                    { label: 'Demandes', value: String(viewUser.demandes), color: 'text-warning' },
                  ].map((stat, i) => (
                    <div key={i} className="p-4 bg-slate-50 rounded-xl border border-slate-50 text-center">
                      <p className={`text-lg font-black ${stat.color}`}>{stat.value}</p>
                      <p className="text-[10px] font-bold text-text-secondary uppercase tracking-widest mt-1">{stat.label}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            <div className="flex justify-end gap-3 pt-2">
              <button onClick={() => { setViewUser(null); openEdit(viewUser); }} className="px-6 py-3 text-primary font-bold bg-primary/10 rounded-xl hover:bg-primary hover:text-white transition-all flex items-center gap-2">
                <Edit2 size={14} /> Modifier
              </button>
            </div>
          </div>
        )}
      </Modal>

      {/* Toggle Status Confirm */}
      <ConfirmDialog
        isOpen={!!toggleUser}
        onClose={() => setToggleUser(null)}
        onConfirm={handleToggleStatus}
        title={toggleUser?.status === 'Actif' ? 'Désactiver le compte' : 'Activer le compte'}
        message={
          toggleUser?.status === 'Actif'
            ? `Êtes-vous sûr de vouloir désactiver le compte de ${toggleUser?.name} ? Il ne pourra plus se connecter.`
            : `Activer le compte de ${toggleUser?.name} ? Il pourra se reconnecter à l'application.`
        }
        confirmLabel={toggleUser?.status === 'Actif' ? 'Désactiver' : 'Activer'}
        variant={toggleUser?.status === 'Actif' ? 'danger' : 'default'}
      />
    </div>
  );
};

export default UserView;
