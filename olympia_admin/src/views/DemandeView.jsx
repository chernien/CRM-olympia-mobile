import React, { useState } from 'react';
import {
  Plus, Search, Filter, FileText, Eye, CheckCircle, XCircle,
  Clock, Package, Wrench, Users, GraduationCap, Building2,
  ShoppingCart, Megaphone, ChevronLeft, ChevronRight, X,
  MessageSquare, Calendar, User, AlertTriangle, Edit2, Trash2
} from 'lucide-react';
import Modal from '../components/Modal';
import Select from '../components/Select';
import ConfirmDialog from '../components/ConfirmDialog';

// ── Business Constants ──────────────────────────────────────────────────────
const DEMANDE_TYPES = [
  { value: 'echantillons', label: 'Échantillons', icon: Package },
  { value: 'echantillons_application', label: 'Échantillons + Application', icon: Package },
  { value: 'reclamation', label: 'Réclamation', icon: AlertTriangle },
  { value: 'nouveau_client', label: 'Nouveau Client', icon: Users },
  { value: 'showroom', label: 'Renouvellement Showroom', icon: Building2 },
  { value: 'formation', label: 'Formation', icon: GraduationCap },
  { value: 'assistance', label: 'Assistance Chantier', icon: Wrench },
  { value: 'machine_teinte', label: 'Machine à Teinter', icon: ShoppingCart },
  { value: 'accessoires', label: 'Accessoires Marketing', icon: Megaphone },
];

const STATUS_CONFIG = {
  nouvelle:               { label: 'Nouvelle',           style: 'bg-blue-50 text-blue-600 border-blue-100',      dot: 'bg-blue-500' },
  en_cours_validation:    { label: 'En validation',       style: 'bg-amber-50 text-amber-600 border-amber-100',   dot: 'bg-amber-500' },
  validee:                { label: 'Validée',             style: 'bg-success/10 text-success border-success/20',  dot: 'bg-success' },
  en_cours_traitement:    { label: 'En traitement',       style: 'bg-yellow-50 text-yellow-700 border-yellow-100', dot: 'bg-yellow-500' },
  traitee:                { label: 'Traitée',             style: 'bg-emerald-50 text-emerald-700 border-emerald-100', dot: 'bg-emerald-500' },
  cloturee:               { label: 'Clôturée',            style: 'bg-slate-100 text-slate-500 border-slate-200',  dot: 'bg-slate-400' },
  refusee:                { label: 'Refusée',             style: 'bg-red-50 text-error border-red-100',           dot: 'bg-error' },
};

// ── Mock Data ───────────────────────────────────────────────────────────────
const INITIAL_DEMANDES = [
  {
    id: 'DEM-2024-001', client: 'Brico Déco SARL', commercial: 'Taha Mejdoub',
    date: '2024-03-15', status: 'nouvelle', type: 'echantillons', montant: '12 500',
    notes: 'Besoin de 3 références de peinture intérieure pour présentation showroom.',
    historique: [
      { date: '2024-03-15 09:30', action: 'Demande créée', by: 'Taha Mejdoub', color: 'bg-blue-500' },
    ],
  },
  {
    id: 'DEM-2024-002', client: 'Global Build SA', commercial: 'Ahmed Salhi',
    date: '2024-03-14', status: 'en_cours_validation', type: 'reclamation', montant: '45 000',
    notes: 'Réclamation qualité lot de peinture façade livré le 01/03.',
    historique: [
      { date: '2024-03-14 14:00', action: 'Demande créée', by: 'Ahmed Salhi', color: 'bg-blue-500' },
      { date: '2024-03-14 16:30', action: 'Prise en charge validation', by: 'Jason Ranti', color: 'bg-amber-500' },
    ],
  },
  {
    id: 'DEM-2024-003', client: 'Atlas Construction', commercial: 'Taha Mejdoub',
    date: '2024-03-14', status: 'validee', type: 'nouveau_client', montant: '8 200',
    notes: 'Ouverture compte nouveau client. Secteur BTP, zone Casablanca.',
    historique: [
      { date: '2024-03-13 10:00', action: 'Demande créée', by: 'Taha Mejdoub', color: 'bg-blue-500' },
      { date: '2024-03-14 09:00', action: 'Validation admin', by: 'Jason Ranti', color: 'bg-success' },
    ],
  },
  {
    id: 'DEM-2024-004', client: 'Immo Prestige', commercial: 'Yassine Rachidi',
    date: '2024-03-13', status: 'refusee', type: 'formation', montant: '32 000',
    notes: 'Formation technique produits spéciaux — dossier incomplet à la soumission.',
    historique: [
      { date: '2024-03-12 11:00', action: 'Demande créée', by: 'Yassine Rachidi', color: 'bg-blue-500' },
      { date: '2024-03-13 15:00', action: 'Refus — dossier incomplet', by: 'Jason Ranti', color: 'bg-error' },
    ],
  },
  {
    id: 'DEM-2024-005', client: 'Peintures Atlas', commercial: 'Ahmed Salhi',
    date: '2024-03-12', status: 'en_cours_traitement', type: 'assistance', montant: '15 000',
    notes: 'Assistance technique chantier résidence Al Fath — phase enduit.',
    historique: [
      { date: '2024-03-10 08:00', action: 'Demande créée', by: 'Ahmed Salhi', color: 'bg-blue-500' },
      { date: '2024-03-11 10:00', action: 'Validée', by: 'Jason Ranti', color: 'bg-success' },
      { date: '2024-03-12 09:00', action: 'Prise en traitement', by: 'Équipe Technique', color: 'bg-yellow-500' },
    ],
  },
  {
    id: 'DEM-2024-006', client: 'Déco Moderne', commercial: 'Taha Mejdoub',
    date: '2024-03-10', status: 'traitee', type: 'echantillons_application', montant: '6 800',
    notes: 'Échantillons + démonstration application peinture décorative.',
    historique: [
      { date: '2024-03-08 14:00', action: 'Demande créée', by: 'Taha Mejdoub', color: 'bg-blue-500' },
      { date: '2024-03-09 10:00', action: 'Validée', by: 'Jason Ranti', color: 'bg-success' },
      { date: '2024-03-10 16:00', action: 'Traitée — échantillons envoyés', by: 'Logistique', color: 'bg-emerald-500' },
    ],
  },
];

const PAGE_SIZE = 6;

// ── Detail Modal ─────────────────────────────────────────────────────────────
const DemandeDetailModal = ({ isOpen, onClose, demande, onValidate, onRefuse }) => {
  const [refuseMode, setRefuseMode] = useState(false);
  const [comment, setComment] = useState('');

  if (!isOpen || !demande) return null;

  const s = STATUS_CONFIG[demande.status];
  const TypeIcon = DEMANDE_TYPES.find(t => t.value === demande.type)?.icon || FileText;
  const typeLabel = DEMANDE_TYPES.find(t => t.value === demande.type)?.label || demande.type;
  const canValidate = ['nouvelle', 'en_cours_validation'].includes(demande.status);

  const handleValidate = () => { onValidate(demande.id, comment); setComment(''); onClose(); };
  const handleRefuse = () => { if (!comment.trim()) return; onRefuse(demande.id, comment); setComment(''); setRefuseMode(false); onClose(); };

  return (
    <Modal isOpen={isOpen} onClose={() => { onClose(); setRefuseMode(false); setComment(''); }} title={`Demande ${demande.id}`}>
      <div className="space-y-6">
        {/* Header info */}
        <div className="flex items-start justify-between p-5 bg-slate-50 rounded-xl border border-slate-100">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-white rounded-xl shadow-sm">
              <TypeIcon size={20} className="text-primary" />
            </div>
            <div>
              <p className="text-sm font-bold text-text-primary">{typeLabel}</p>
              <p className="text-xs text-text-secondary mt-0.5">{demande.client}</p>
            </div>
          </div>
          <span className={`px-3 py-1.5 rounded-full text-[10px] font-black uppercase tracking-wider border ${s.style}`}>
            {s.label}
          </span>
        </div>

        {/* Details grid */}
        <div className="grid grid-cols-2 gap-4">
          {[
            { label: 'Commercial', value: demande.commercial, icon: <User size={13} /> },
            { label: 'Date création', value: demande.date, icon: <Calendar size={13} /> },
            { label: 'Montant estimé', value: demande.montant + ' MAD', icon: <FileText size={13} /> },
            { label: 'Statut', value: s.label, icon: <div className={`w-2.5 h-2.5 rounded-full ${s.dot}`}></div> },
          ].map((item, i) => (
            <div key={i} className="p-4 bg-slate-50 rounded-xl border border-slate-50">
              <div className="flex items-center gap-1.5 text-text-secondary mb-1.5">
                {item.icon}
                <span className="text-[10px] font-bold uppercase tracking-widest">{item.label}</span>
              </div>
              <p className="text-sm font-bold text-text-primary">{item.value}</p>
            </div>
          ))}
        </div>

        {/* Notes */}
        <div>
          <p className="text-xs font-bold text-text-secondary uppercase tracking-widest mb-2 flex items-center gap-2">
            <MessageSquare size={12} /> Notes
          </p>
          <div className="p-4 bg-slate-50 rounded-xl border border-slate-50">
            <p className="text-sm text-text-secondary leading-relaxed font-medium">{demande.notes || 'Aucune note.'}</p>
          </div>
        </div>

        {/* Timeline */}
        <div>
          <p className="text-xs font-bold text-text-secondary uppercase tracking-widest mb-3">Historique</p>
          <div className="relative pl-4">
            <div className="absolute left-1.5 top-0 bottom-0 w-px bg-slate-200"></div>
            <div className="space-y-3">
              {demande.historique.map((h, i) => (
                <div key={i} className="relative flex items-start gap-3">
                  <div className={`absolute -left-[13px] w-2.5 h-2.5 rounded-full ${h.color} border-2 border-white mt-1 shrink-0`}></div>
                  <div className="flex-1 p-3 bg-slate-50 rounded-xl border border-slate-50">
                    <p className="text-xs font-bold text-text-primary">{h.action}</p>
                    <div className="flex items-center gap-2 mt-1">
                      <span className="text-[10px] font-medium text-text-secondary">{h.by}</span>
                      <span className="text-[10px] text-slate-300">·</span>
                      <span className="text-[10px] font-medium text-text-secondary">{h.date}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Validation Actions */}
        {canValidate && (
          <div className="pt-4 border-t border-slate-50 space-y-4">
            {refuseMode ? (
              <>
                <div className="space-y-2">
                  <label className="text-xs font-bold text-text-secondary uppercase tracking-widest">
                    Motif du refus <span className="text-error">*</span>
                  </label>
                  <textarea
                    value={comment}
                    onChange={(e) => setComment(e.target.value)}
                    placeholder="Expliquez la raison du refus..."
                    className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-error/30 focus:bg-white transition-all text-sm font-medium h-24 resize-none placeholder:text-slate-300"
                  />
                </div>
                <div className="flex gap-3">
                  <button
                    onClick={() => setRefuseMode(false)}
                    className="flex-1 py-3 text-sm font-bold text-text-secondary bg-slate-50 rounded-xl hover:bg-slate-100 transition-all"
                  >
                    Retour
                  </button>
                  <button
                    onClick={handleRefuse}
                    disabled={!comment.trim()}
                    className="flex-1 py-3 text-sm font-bold text-white bg-error rounded-xl hover:bg-red-600 transition-all shadow-lg shadow-red-200 disabled:opacity-40 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                  >
                    <XCircle size={16} />
                    Confirmer le refus
                  </button>
                </div>
              </>
            ) : (
              <>
                <div className="space-y-2">
                  <label className="text-xs font-bold text-text-secondary uppercase tracking-widest">
                    Commentaire (optionnel)
                  </label>
                  <textarea
                    value={comment}
                    onChange={(e) => setComment(e.target.value)}
                    placeholder="Ajoutez une note de validation..."
                    className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all text-sm font-medium h-20 resize-none placeholder:text-slate-300"
                  />
                </div>
                <div className="flex gap-3">
                  <button
                    onClick={() => setRefuseMode(true)}
                    className="flex-1 py-3 text-sm font-bold text-error bg-red-50 rounded-xl hover:bg-red-100 transition-all border border-red-100 flex items-center justify-center gap-2"
                  >
                    <XCircle size={16} />
                    Refuser
                  </button>
                  <button
                    onClick={handleValidate}
                    className="flex-1 py-3 text-sm font-bold text-white bg-success rounded-xl hover:bg-emerald-600 transition-all shadow-lg shadow-success/20 flex items-center justify-center gap-2"
                  >
                    <CheckCircle size={16} />
                    Valider
                  </button>
                </div>
              </>
            )}
          </div>
        )}
      </div>
    </Modal>
  );
};

// ── Main View ────────────────────────────────────────────────────────────────
const DemandeView = () => {
  const [demandes, setDemandes] = useState(INITIAL_DEMANDES);
  const [filterStatus, setFilterStatus] = useState('Tous');
  const [filterType, setFilterType] = useState('Tous');
  const [searchQuery, setSearchQuery] = useState('');
  const [page, setPage] = useState(1);

  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [detailDemande, setDetailDemande] = useState(null);
  const [deleteDemande, setDeleteDemande] = useState(null);
  const [isDeleting, setIsDeleting] = useState(false);

  // New demande form state
  const [form, setForm] = useState({ client: '', commercial: '', type: 'echantillons', montant: '', notes: '' });

  const setF = (key) => (val) => setForm(prev => ({ ...prev, [key]: val }));

  const typeOptions = DEMANDE_TYPES.map(t => ({ value: t.value, label: t.label, icon: t.icon }));
  const commercialOptions = [
    { value: 'Taha Mejdoub', label: 'Taha Mejdoub', icon: User },
    { value: 'Ahmed Salhi', label: 'Ahmed Salhi', icon: User },
    { value: 'Yassine Rachidi', label: 'Yassine Rachidi', icon: User },
  ];

  const statusFilters = ['Tous', ...Object.keys(STATUS_CONFIG)];
  const typeFilters = ['Tous', ...DEMANDE_TYPES.map(t => t.value)];

  const filtered = demandes.filter(d => {
    const matchStatus = filterStatus === 'Tous' || d.status === filterStatus;
    const matchType = filterType === 'Tous' || d.type === filterType;
    const matchSearch = d.client.toLowerCase().includes(searchQuery.toLowerCase()) ||
                        d.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
                        d.commercial.toLowerCase().includes(searchQuery.toLowerCase());
    return matchStatus && matchType && matchSearch;
  });

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  const handleCreate = () => {
    const id = `DEM-2024-${String(demandes.length + 1).padStart(3, '0')}`;
    const today = new Date().toISOString().split('T')[0];
    const newDem = {
      id, client: form.client, commercial: form.commercial || 'Taha Mejdoub',
      date: today, status: 'nouvelle', type: form.type,
      montant: form.montant || '0',
      notes: form.notes,
      historique: [{ date: `${today} ${new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })}`, action: 'Demande créée', by: form.commercial || 'Taha Mejdoub', color: 'bg-blue-500' }],
    };
    setDemandes(prev => [newDem, ...prev]);
    setForm({ client: '', commercial: '', type: 'echantillons', montant: '', notes: '' });
    setIsCreateOpen(false);
  };

  const handleValidate = (id, comment) => {
    setDemandes(prev => prev.map(d => {
      if (d.id !== id) return d;
      const now = new Date().toLocaleString('fr-FR', { dateStyle: 'short', timeStyle: 'short' });
      return {
        ...d, status: 'validee',
        historique: [...d.historique, { date: now, action: comment ? `Validée — ${comment}` : 'Validée', by: 'Jason Ranti', color: 'bg-success' }],
      };
    }));
  };

  const handleRefuse = (id, comment) => {
    setDemandes(prev => prev.map(d => {
      if (d.id !== id) return d;
      const now = new Date().toLocaleString('fr-FR', { dateStyle: 'short', timeStyle: 'short' });
      return {
        ...d, status: 'refusee',
        historique: [...d.historique, { date: now, action: `Refusée — ${comment}`, by: 'Jason Ranti', color: 'bg-error' }],
      };
    }));
  };

  const handleDelete = async () => {
    setIsDeleting(true);
    await new Promise(r => setTimeout(r, 600));
    setDemandes(prev => prev.filter(d => d.id !== deleteDemande.id));
    setDeleteDemande(null);
    setIsDeleting(false);
  };

  return (
    <div className="max-w-[1400px] mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h1 className="text-3xl font-black text-text-primary tracking-tight mb-2">Gestion des Demandes</h1>
          <p className="text-text-secondary font-medium">
            <span className="font-black text-text-primary">{demandes.filter(d => ['nouvelle','en_cours_validation'].includes(d.status)).length}</span> demandes en attente de validation
          </p>
        </div>
        <button
          onClick={() => setIsCreateOpen(true)}
          className="bg-primary text-white px-6 py-3 rounded-xl font-bold flex items-center gap-3 shadow-lg shadow-primary/20 transition-all hover:bg-primary-dark hover:-translate-y-0.5 self-start"
        >
          <Plus size={18} />
          Nouvelle Demande
        </button>
      </div>

      {/* Status summary chips */}
      <div className="flex flex-wrap gap-2">
        {Object.entries(STATUS_CONFIG).map(([key, cfg]) => {
          const count = demandes.filter(d => d.status === key).length;
          if (!count) return null;
          return (
            <button
              key={key}
              onClick={() => { setFilterStatus(key); setPage(1); }}
              className={`flex items-center gap-2 px-3 py-1.5 rounded-full text-[10px] font-black uppercase tracking-wider border transition-all ${
                filterStatus === key ? cfg.style + ' shadow-sm' : 'bg-white text-text-secondary border-slate-100 hover:border-slate-200'
              }`}
            >
              <div className={`w-1.5 h-1.5 rounded-full ${cfg.dot}`}></div>
              {cfg.label} ({count})
            </button>
          );
        })}
        {filterStatus !== 'Tous' && (
          <button
            onClick={() => { setFilterStatus('Tous'); setPage(1); }}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[10px] font-bold text-text-secondary bg-white border border-slate-100 hover:border-slate-200 transition-all"
          >
            <X size={10} /> Réinitialiser
          </button>
        )}
      </div>

      {/* Filters */}
      <div className="bg-white p-5 rounded-premium shadow-sm border border-slate-50 flex flex-wrap items-center gap-5">
        <div className="flex-1 min-w-[260px] relative">
          <Search size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-text-secondary" />
          <input
            type="text"
            placeholder="Rechercher par ID, client ou commercial..."
            value={searchQuery}
            onChange={(e) => { setSearchQuery(e.target.value); setPage(1); }}
            className="w-full pl-11 pr-4 py-3 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all text-sm font-medium"
          />
        </div>

        {/* Type filter */}
        <select
          value={filterType}
          onChange={(e) => { setFilterType(e.target.value); setPage(1); }}
          className="px-4 py-3 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 text-sm font-medium text-text-primary cursor-pointer"
        >
          <option value="Tous">Tous les types</option>
          {DEMANDE_TYPES.map(t => <option key={t.value} value={t.value}>{t.label}</option>)}
        </select>
      </div>

      {/* Table */}
      <div className="bg-white rounded-premium shadow-sm border border-slate-50 overflow-hidden">
        <table className="w-full border-collapse">
          <thead>
            <tr className="bg-slate-50/70">
              {['ID Demande', 'Client', 'Commercial', 'Type', 'Statut', 'Montant', 'Date', 'Actions'].map((h, i) => (
                <th key={i} className={`px-5 py-4 text-[10px] font-bold text-text-secondary uppercase tracking-widest border-b border-slate-100 ${i === 5 ? 'text-right' : 'text-left'}`}>
                  {h}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {paginated.map((dem) => {
              const s = STATUS_CONFIG[dem.status];
              const TypeIcon = DEMANDE_TYPES.find(t => t.value === dem.type)?.icon || FileText;
              const typeLabel = DEMANDE_TYPES.find(t => t.value === dem.type)?.label || dem.type;
              return (
                <tr key={dem.id} className="group hover:bg-slate-50/50 transition-colors">
                  <td className="px-5 py-4 border-b border-slate-50">
                    <span className="font-black text-primary text-sm">{dem.id}</span>
                  </td>
                  <td className="px-5 py-4 border-b border-slate-50 text-sm font-bold text-text-primary max-w-[140px] truncate">
                    {dem.client}
                  </td>
                  <td className="px-5 py-4 border-b border-slate-50">
                    <div className="flex items-center gap-2">
                      <div className="w-6 h-6 rounded-lg bg-primary/10 text-primary text-[10px] font-black flex items-center justify-center shrink-0">
                        {dem.commercial.split(' ').map(n => n[0]).join('').slice(0, 2)}
                      </div>
                      <span className="text-xs font-bold text-text-secondary truncate max-w-[90px]">{dem.commercial.split(' ')[0]}</span>
                    </div>
                  </td>
                  <td className="px-5 py-4 border-b border-slate-50">
                    <div className="flex items-center gap-2 text-xs font-semibold text-text-secondary">
                      <TypeIcon size={13} className="text-secondary shrink-0" />
                      <span className="truncate max-w-[120px]">{typeLabel}</span>
                    </div>
                  </td>
                  <td className="px-5 py-4 border-b border-slate-50">
                    <span className={`px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider border ${s.style}`}>
                      {s.label}
                    </span>
                  </td>
                  <td className="px-5 py-4 border-b border-slate-50 text-right font-black text-sm text-text-primary">
                    {dem.montant} <span className="text-[10px] text-text-secondary font-medium">MAD</span>
                  </td>
                  <td className="px-5 py-4 border-b border-slate-50 text-xs font-medium text-text-secondary whitespace-nowrap">
                    {dem.date}
                  </td>
                  <td className="px-5 py-4 border-b border-slate-50">
                    <div className="flex items-center justify-center gap-1.5">
                      <button
                        onClick={() => setDetailDemande(dem)}
                        className="p-2 bg-slate-50 text-text-secondary rounded-lg hover:text-primary hover:bg-primary/10 border border-slate-100 transition-all"
                        title="Voir détails"
                      >
                        <Eye size={14} />
                      </button>
                      {['nouvelle', 'en_cours_validation'].includes(dem.status) && (
                        <button
                          onClick={() => { setDetailDemande(dem); }}
                          className="p-2 bg-success/10 text-success rounded-lg hover:bg-success hover:text-white border border-success/20 transition-all"
                          title="Valider"
                        >
                          <CheckCircle size={14} />
                        </button>
                      )}
                      <button
                        onClick={() => setDeleteDemande(dem)}
                        className="p-2 bg-red-50 text-error rounded-lg hover:bg-error hover:text-white border border-red-100 transition-all"
                        title="Supprimer"
                      >
                        <Trash2 size={14} />
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>

        {paginated.length === 0 && (
          <div className="py-20 text-center">
            <div className="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-4">
              <Search size={24} className="text-slate-200" />
            </div>
            <p className="font-bold text-text-secondary">Aucune demande trouvée.</p>
            <p className="text-sm text-text-secondary mt-1">Modifiez vos filtres ou créez une nouvelle demande.</p>
          </div>
        )}

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex items-center justify-between px-6 py-4 border-t border-slate-50">
            <p className="text-xs font-medium text-text-secondary">
              {filtered.length} demande{filtered.length > 1 ? 's' : ''} — page {page} / {totalPages}
            </p>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page === 1}
                className="p-2 rounded-lg bg-slate-50 text-text-secondary hover:bg-primary hover:text-white transition-all disabled:opacity-30 disabled:cursor-not-allowed border border-slate-100"
              >
                <ChevronLeft size={14} />
              </button>
              {Array.from({ length: totalPages }, (_, i) => i + 1).map(n => (
                <button
                  key={n}
                  onClick={() => setPage(n)}
                  className={`w-8 h-8 rounded-lg text-xs font-bold transition-all ${n === page ? 'bg-primary text-white shadow-sm' : 'bg-slate-50 text-text-secondary hover:bg-slate-100 border border-slate-100'}`}
                >
                  {n}
                </button>
              ))}
              <button
                onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                disabled={page === totalPages}
                className="p-2 rounded-lg bg-slate-50 text-text-secondary hover:bg-primary hover:text-white transition-all disabled:opacity-30 disabled:cursor-not-allowed border border-slate-100"
              >
                <ChevronRight size={14} />
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Create Modal */}
      <Modal isOpen={isCreateOpen} onClose={() => setIsCreateOpen(false)} title="Nouvelle Demande">
        <div className="space-y-5">
          <div className="grid grid-cols-2 gap-5">
            <div className="space-y-2">
              <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Client <span className="text-error">*</span></label>
              <input
                value={form.client}
                onChange={(e) => setF('client')(e.target.value)}
                className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all font-medium text-sm placeholder:text-slate-300"
                placeholder="Nom de l'entreprise"
              />
            </div>
            <div className="space-y-2">
              <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Commercial</label>
              <Select options={commercialOptions} value={form.commercial || 'Taha Mejdoub'} onChange={setF('commercial')} />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-5">
            <div className="space-y-2">
              <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Type de Demande</label>
              <Select options={typeOptions} value={form.type} onChange={setF('type')} />
            </div>
            <div className="space-y-2">
              <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Montant estimé (MAD)</label>
              <input
                type="number"
                value={form.montant}
                onChange={(e) => setF('montant')(e.target.value)}
                className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all font-medium text-sm placeholder:text-slate-300"
                placeholder="Ex: 15 000"
              />
            </div>
          </div>
          <div className="space-y-2">
            <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Notes / Description</label>
            <textarea
              value={form.notes}
              onChange={(e) => setF('notes')(e.target.value)}
              className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all font-medium text-sm h-28 resize-none placeholder:text-slate-300"
              placeholder="Détails de la demande..."
            />
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button onClick={() => setIsCreateOpen(false)} className="px-6 py-3 text-text-secondary font-bold hover:bg-slate-50 rounded-xl transition-all">
              Annuler
            </button>
            <button
              onClick={handleCreate}
              disabled={!form.client}
              className="bg-primary text-white px-8 py-3 rounded-xl font-bold shadow-lg shadow-primary/20 hover:bg-primary-dark transition-all disabled:opacity-40 disabled:cursor-not-allowed"
            >
              Créer la demande
            </button>
          </div>
        </div>
      </Modal>

      {/* Detail Modal with validation */}
      <DemandeDetailModal
        isOpen={!!detailDemande}
        onClose={() => setDetailDemande(null)}
        demande={detailDemande}
        onValidate={handleValidate}
        onRefuse={handleRefuse}
      />

      {/* Delete Confirm */}
      <ConfirmDialog
        isOpen={!!deleteDemande}
        onClose={() => setDeleteDemande(null)}
        onConfirm={handleDelete}
        isLoading={isDeleting}
        title="Supprimer la demande"
        message={`Êtes-vous sûr de vouloir supprimer la demande ${deleteDemande?.id} ? Cette action est irréversible.`}
        confirmLabel="Supprimer"
        variant="danger"
      />
    </div>
  );
};

export default DemandeView;
