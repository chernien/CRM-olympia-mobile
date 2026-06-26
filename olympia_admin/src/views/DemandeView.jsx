import React, { useState, useEffect } from 'react';
import {
  Plus, Search, FileText, Eye, CheckCircle, XCircle,
  Clock, Package, Wrench, Users, GraduationCap, Building2,
  ShoppingCart, Megaphone, ChevronLeft, ChevronRight, X,
  MessageSquare, Calendar, User, AlertTriangle, Trash2
} from 'lucide-react';
import Modal from '../components/Modal';
import Select from '../components/Select';
import ConfirmDialog from '../components/ConfirmDialog';
import { Services } from '../services/index.js';
import { useAuth } from '../context/AuthContext.jsx';

// ── Business Constants ──────────────────────────────────────────────────────
const DEMANDE_TYPES = [
  { value: 1,  label: 'Échantillons',            icon: Package },
  { value: 2,  label: 'Échantillons + Application', icon: Package },
  { value: 3,  label: 'Réclamation',              icon: AlertTriangle },
  { value: 4,  label: 'Nouveau Client',           icon: Users },
  { value: 5,  label: 'Renouvellement Showroom',  icon: Building2 },
  { value: 6,  label: 'Formation',                icon: GraduationCap },
  { value: 7,  label: 'Assistance Chantier',      icon: Wrench },
  { value: 8,  label: 'Machine à Teinter',        icon: ShoppingCart },
  { value: 9,  label: 'Accessoires Marketing',    icon: Megaphone },
];

const TYPE_MAP = Object.fromEntries(DEMANDE_TYPES.map((t) => [t.value, t]));

const STATUS_CONFIG = {
  nouvelle:            { label: 'Nouvelle',      style: 'bg-blue-50 text-blue-600 border-blue-100',        dot: 'bg-blue-500' },
  en_cours_validation: { label: 'En validation', style: 'bg-amber-50 text-amber-600 border-amber-100',     dot: 'bg-amber-500' },
  validee:             { label: 'Validée',        style: 'bg-success/10 text-success border-success/20',    dot: 'bg-success' },
  en_cours_traitement: { label: 'En traitement', style: 'bg-yellow-50 text-yellow-700 border-yellow-100',  dot: 'bg-yellow-500' },
  traitee:             { label: 'Traitée',        style: 'bg-emerald-50 text-emerald-700 border-emerald-100', dot: 'bg-emerald-500' },
  cloturee:            { label: 'Clôturée',       style: 'bg-slate-100 text-slate-500 border-slate-200',   dot: 'bg-slate-400' },
  refusee:             { label: 'Refusée',        style: 'bg-red-50 text-error border-red-100',             dot: 'bg-error' },
};

const PAGE_SIZE = 6;

// ── Detail Modal ─────────────────────────────────────────────────────────────
const DemandeDetailModal = ({ isOpen, onClose, demande, onValidate, onRefuse }) => {
  const [refuseMode, setRefuseMode] = useState(false);
  const [comment, setComment] = useState('');

  if (!isOpen || !demande) return null;

  const s = STATUS_CONFIG[demande.statut] ?? STATUS_CONFIG.nouvelle;
  const typeInfo = TYPE_MAP[demande.typeDemande];
  const TypeIcon = typeInfo?.icon ?? FileText;
  const typeLabel = demande.typeLabel ?? typeInfo?.label ?? `Type ${demande.typeDemande}`;
  const canValidate = ['nouvelle', 'en_cours_validation'].includes(demande.statut);

  const handleValidate = () => { onValidate(demande.id, comment); setComment(''); onClose(); };
  const handleRefuse = () => { if (!comment.trim()) return; onRefuse(demande.id, comment); setComment(''); setRefuseMode(false); onClose(); };

  return (
    <Modal isOpen={isOpen} onClose={() => { onClose(); setRefuseMode(false); setComment(''); }} title={`Demande ${demande.numero}`}>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-start justify-between p-5 bg-slate-50 rounded-xl border border-slate-100">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-white rounded-xl shadow-sm">
              <TypeIcon size={20} className="text-primary" />
            </div>
            <div>
              <p className="text-sm font-bold text-text-primary">{typeLabel}</p>
              <p className="text-xs text-text-secondary mt-0.5">{demande.nomClient}</p>
            </div>
          </div>
          <span className={`px-3 py-1.5 rounded-full text-[10px] font-black uppercase tracking-wider border ${s.style}`}>
            {s.label}
          </span>
        </div>

        {/* Details grid */}
        <div className="grid grid-cols-2 gap-4">
          {[
            { label: 'Commercial', value: demande.commercialNom, icon: <User size={13} /> },
            { label: 'Date création', value: demande.createdAt, icon: <Calendar size={13} /> },
            { label: 'Statut', value: s.label, icon: <div className={`w-2.5 h-2.5 rounded-full ${s.dot}`} /> },
            { label: 'Numéro', value: demande.numero, icon: <FileText size={13} /> },
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

        {/* Description */}
        <div>
          <p className="text-xs font-bold text-text-secondary uppercase tracking-widest mb-2 flex items-center gap-2">
            <MessageSquare size={12} /> Description
          </p>
          <div className="p-4 bg-slate-50 rounded-xl border border-slate-50">
            <p className="text-sm text-text-secondary leading-relaxed font-medium">{demande.description || 'Aucune description.'}</p>
          </div>
        </div>

        {demande.commentaire && (
          <div>
            <p className="text-xs font-bold text-text-secondary uppercase tracking-widest mb-2">Commentaire</p>
            <div className="p-4 bg-amber-50 rounded-xl border border-amber-100">
              <p className="text-sm text-amber-800 font-medium">{demande.commentaire}</p>
            </div>
          </div>
        )}

        {/* Timeline */}
        <div>
          <p className="text-xs font-bold text-text-secondary uppercase tracking-widest mb-3">Historique</p>
          <div className="relative pl-4">
            <div className="absolute left-1.5 top-0 bottom-0 w-px bg-slate-200" />
            <div className="space-y-3">
              {(demande.historique ?? []).map((h, i) => (
                <div key={i} className="relative flex items-start gap-3">
                  <div className={`absolute -left-[13px] w-2.5 h-2.5 rounded-full ${h.color} border-2 border-white mt-1 shrink-0`} />
                  <div className="flex-1 p-3 bg-slate-50 rounded-xl border border-slate-50">
                    <p className="text-xs font-bold text-text-primary">{h.action}</p>
                    <div className="flex items-center gap-2 mt-1">
                      <span className="text-[10px] font-medium text-text-secondary">{h.auteur}</span>
                      <span className="text-[10px] text-slate-300">·</span>
                      <span className="text-[10px] font-medium text-text-secondary">{h.date}</span>
                    </div>
                    {h.commentaire && <p className="text-[10px] text-text-secondary mt-1 italic">{h.commentaire}</p>}
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
                  <button onClick={() => setRefuseMode(false)} className="flex-1 py-3 text-sm font-bold text-text-secondary bg-slate-50 rounded-xl hover:bg-slate-100 transition-all">
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
                  <label className="text-xs font-bold text-text-secondary uppercase tracking-widest">Commentaire (optionnel)</label>
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
  const { user } = useAuth();
  const [demandes, setDemandes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filterStatus, setFilterStatus] = useState('Tous');
  const [filterType, setFilterType] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [page, setPage] = useState(1);

  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [detailDemande, setDetailDemande] = useState(null);
  const [deleteDemande, setDeleteDemande] = useState(null);
  const [isDeleting, setIsDeleting] = useState(false);
  const [isSaving, setIsSaving] = useState(false);

  const [form, setForm] = useState({ nomClient: '', commercialNom: '', typeDemande: 1, description: '' });
  const setF = (key) => (val) => setForm((prev) => ({ ...prev, [key]: val }));

  useEffect(() => {
    setLoading(true);
    Services.demandes.getDemandes({ pageSize: 50 }).then(({ data }) => {
      if (data) setDemandes(data.data ?? []);
      setLoading(false);
    });
  }, []);

  const typeOptions = DEMANDE_TYPES.map((t) => ({ value: t.value, label: t.label, icon: t.icon }));

  const filtered = demandes.filter((d) => {
    const matchStatus = filterStatus === 'Tous' || d.statut === filterStatus;
    const matchType = filterType === '' || d.typeDemande === Number(filterType);
    const q = searchQuery.toLowerCase();
    const matchSearch = !q || (d.nomClient ?? '').toLowerCase().includes(q) ||
      (d.numero ?? '').toLowerCase().includes(q) ||
      (d.commercialNom ?? '').toLowerCase().includes(q);
    return matchStatus && matchType && matchSearch;
  });

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  const handleCreate = async () => {
    if (!form.nomClient) return;
    setIsSaving(true);
    const { data, error } = await Services.demandes.createDemande({
      ...form,
      commercialNom: form.commercialNom || (user ? `${user.prenom} ${user.nom}` : 'Admin'),
      typeLabel: TYPE_MAP[form.typeDemande]?.label ?? '',
    });
    if (!error && data) setDemandes((prev) => [data, ...prev]);
    setForm({ nomClient: '', commercialNom: '', typeDemande: 1, description: '' });
    setIsCreateOpen(false);
    setIsSaving(false);
  };

  // Lifecycle: nouvelle → en_cours_validation → validee | refusee.
  // A "nouvelle" demande must first be submitted before it can be validated/refused,
  // so chain the intermediate transition when needed.
  const advanceTo = async (id, target, comment) => {
    const current = demandes.find((d) => d.id === id)?.statut;
    if (current === 'nouvelle') {
      const step = await Services.demandes.updateStatus(id, 'en_cours_validation');
      if (step.error) return step;
    }
    return Services.demandes.updateStatus(id, target, comment);
  };

  const handleValidate = async (id, comment) => {
    const { data, error } = await advanceTo(id, 'validee', comment || undefined);
    if (error) { alert(error.message || 'Échec de la validation.'); return; }
    if (data) setDemandes((prev) => prev.map((d) => d.id === id ? data : d));
  };

  const handleRefuse = async (id, comment) => {
    const { data, error } = await advanceTo(id, 'refusee', comment);
    if (error) { alert(error.message || 'Échec du refus.'); return; }
    if (data) setDemandes((prev) => prev.map((d) => d.id === id ? data : d));
  };

  const handleDelete = async () => {
    setIsDeleting(true);
    const { error } = await Services.demandes.deleteDemande(deleteDemande.id);
    if (!error) setDemandes((prev) => prev.filter((d) => d.id !== deleteDemande.id));
    setDeleteDemande(null);
    setIsDeleting(false);
  };

  const pendingCount = demandes.filter((d) => ['nouvelle', 'en_cours_validation'].includes(d.statut)).length;

  return (
    <div className="max-w-[1400px] mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h1 className="text-3xl font-black text-text-primary tracking-tight mb-2">Gestion des Demandes</h1>
          <p className="text-text-secondary font-medium">
            <span className="font-black text-text-primary">{pendingCount}</span> demandes en attente de validation
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

      {/* Status chips */}
      <div className="flex flex-wrap gap-2">
        {Object.entries(STATUS_CONFIG).map(([key, cfg]) => {
          const count = demandes.filter((d) => d.statut === key).length;
          if (!count) return null;
          return (
            <button
              key={key}
              onClick={() => { setFilterStatus(key); setPage(1); }}
              className={`flex items-center gap-2 px-3 py-1.5 rounded-full text-[10px] font-black uppercase tracking-wider border transition-all ${
                filterStatus === key ? cfg.style + ' shadow-sm' : 'bg-white text-text-secondary border-slate-100 hover:border-slate-200'
              }`}
            >
              <div className={`w-1.5 h-1.5 rounded-full ${cfg.dot}`} />
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
            placeholder="Rechercher par numéro, client ou commercial..."
            value={searchQuery}
            onChange={(e) => { setSearchQuery(e.target.value); setPage(1); }}
            className="w-full pl-11 pr-4 py-3 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all text-sm font-medium"
          />
        </div>
        <select
          value={filterType}
          onChange={(e) => { setFilterType(e.target.value); setPage(1); }}
          className="px-4 py-3 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 text-sm font-medium text-text-primary cursor-pointer"
        >
          <option value="">Tous les types</option>
          {DEMANDE_TYPES.map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
        </select>
      </div>

      {/* Table */}
      <div className="bg-white rounded-premium shadow-sm border border-slate-50 overflow-hidden">
        {loading ? (
          <div className="py-20 flex items-center justify-center gap-3">
            <div className="w-6 h-6 border-2 border-primary/30 border-t-primary rounded-full animate-spin" />
            <span className="text-sm font-medium text-text-secondary">Chargement des demandes...</span>
          </div>
        ) : (
          <>
            <table className="w-full border-collapse">
              <thead>
                <tr className="bg-slate-50/70">
                  {['Numéro', 'Client', 'Commercial', 'Type', 'Statut', 'Date', 'Actions'].map((h, i) => (
                    <th key={i} className="px-5 py-4 text-[10px] font-bold text-text-secondary uppercase tracking-widest border-b border-slate-100 text-left">
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {paginated.map((dem) => {
                  const s = STATUS_CONFIG[dem.statut] ?? STATUS_CONFIG.nouvelle;
                  const typeInfo = TYPE_MAP[dem.typeDemande];
                  const TypeIcon = typeInfo?.icon ?? FileText;
                  const typeLabel = dem.typeLabel ?? typeInfo?.label ?? `Type ${dem.typeDemande}`;
                  return (
                    <tr key={dem.id} className="group hover:bg-slate-50/50 transition-colors">
                      <td className="px-5 py-4 border-b border-slate-50">
                        <span className="font-black text-primary text-sm">{dem.numero}</span>
                      </td>
                      <td className="px-5 py-4 border-b border-slate-50 text-sm font-bold text-text-primary max-w-[140px] truncate">
                        {dem.nomClient}
                      </td>
                      <td className="px-5 py-4 border-b border-slate-50">
                        <div className="flex items-center gap-2">
                          <div className="w-6 h-6 rounded-lg bg-primary/10 text-primary text-[10px] font-black flex items-center justify-center shrink-0">
                            {(dem.commercialNom ?? '').split(' ').map((n) => n[0]).join('').slice(0, 2)}
                          </div>
                          <span className="text-xs font-bold text-text-secondary truncate max-w-[90px]">
                            {(dem.commercialNom ?? '').split(' ')[0]}
                          </span>
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
                      <td className="px-5 py-4 border-b border-slate-50 text-xs font-medium text-text-secondary whitespace-nowrap">
                        {dem.createdAt}
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
                          {['nouvelle', 'en_cours_validation'].includes(dem.statut) && (
                            <button
                              onClick={() => setDetailDemande(dem)}
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

            {totalPages > 1 && (
              <div className="flex items-center justify-between px-6 py-4 border-t border-slate-50">
                <p className="text-xs font-medium text-text-secondary">
                  {filtered.length} demande{filtered.length > 1 ? 's' : ''} — page {page} / {totalPages}
                </p>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setPage((p) => Math.max(1, p - 1))}
                    disabled={page === 1}
                    className="p-2 rounded-lg bg-slate-50 text-text-secondary hover:bg-primary hover:text-white transition-all disabled:opacity-30 disabled:cursor-not-allowed border border-slate-100"
                  >
                    <ChevronLeft size={14} />
                  </button>
                  {Array.from({ length: totalPages }, (_, i) => i + 1).map((n) => (
                    <button
                      key={n}
                      onClick={() => setPage(n)}
                      className={`w-8 h-8 rounded-lg text-xs font-bold transition-all ${n === page ? 'bg-primary text-white shadow-sm' : 'bg-slate-50 text-text-secondary hover:bg-slate-100 border border-slate-100'}`}
                    >
                      {n}
                    </button>
                  ))}
                  <button
                    onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                    disabled={page === totalPages}
                    className="p-2 rounded-lg bg-slate-50 text-text-secondary hover:bg-primary hover:text-white transition-all disabled:opacity-30 disabled:cursor-not-allowed border border-slate-100"
                  >
                    <ChevronRight size={14} />
                  </button>
                </div>
              </div>
            )}
          </>
        )}
      </div>

      {/* Create Modal */}
      <Modal isOpen={isCreateOpen} onClose={() => setIsCreateOpen(false)} title="Nouvelle Demande">
        <div className="space-y-5">
          <div className="space-y-2">
            <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">
              Client <span className="text-error">*</span>
            </label>
            <input
              value={form.nomClient}
              onChange={(e) => setF('nomClient')(e.target.value)}
              className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all font-medium text-sm placeholder:text-slate-300"
              placeholder="Nom de l'entreprise"
            />
          </div>
          <div className="space-y-2">
            <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Type de Demande</label>
            <Select options={typeOptions} value={form.typeDemande} onChange={(v) => setF('typeDemande')(Number(v))} />
          </div>
          <div className="space-y-2">
            <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Description</label>
            <textarea
              value={form.description}
              onChange={(e) => setF('description')(e.target.value)}
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
              disabled={!form.nomClient || isSaving}
              className="bg-primary text-white px-8 py-3 rounded-xl font-bold shadow-lg shadow-primary/20 hover:bg-primary-dark transition-all disabled:opacity-40 disabled:cursor-not-allowed flex items-center gap-2"
            >
              {isSaving && <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />}
              Créer la demande
            </button>
          </div>
        </div>
      </Modal>

      <DemandeDetailModal
        isOpen={!!detailDemande}
        onClose={() => setDetailDemande(null)}
        demande={detailDemande}
        onValidate={handleValidate}
        onRefuse={handleRefuse}
      />

      <ConfirmDialog
        isOpen={!!deleteDemande}
        onClose={() => setDeleteDemande(null)}
        onConfirm={handleDelete}
        isLoading={isDeleting}
        title="Supprimer la demande"
        message={`Êtes-vous sûr de vouloir supprimer la demande ${deleteDemande?.numero} ? Cette action est irréversible.`}
        confirmLabel="Supprimer"
        variant="danger"
      />
    </div>
  );
};

export default DemandeView;
