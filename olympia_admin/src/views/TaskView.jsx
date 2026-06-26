import React, { useState, useEffect } from 'react';
import {
  Plus, Search, Calendar, User, Activity,
  Edit2, Trash2, Eye, CheckSquare, LayoutGrid, List,
  ChevronLeft, ChevronRight, Flag, CheckCircle2, X
} from 'lucide-react';
import Modal from '../components/Modal';
import Select from '../components/Select';
import DatePicker from '../components/DatePicker';
import ConfirmDialog from '../components/ConfirmDialog';
import { Services } from '../services/index.js';

// ── Constants — aligned with mobile task lifecycle ────────────────────────────
const STATUS_CONFIG = {
  'en_cours_traitement': {
    label: 'En cours',  style: 'bg-warning/10 text-warning',       next: 'realisee', nextLabel: 'Marquer réalisée',
  },
  'realisee': {
    label: 'Réalisée',  style: 'bg-success/10 text-success',       next: null, nextLabel: null,
  },
  'annulee': {
    label: 'Annulée',   style: 'bg-slate-100 text-text-secondary', next: null, nextLabel: null,
  },
};

const PRIORITY_CONFIG = {
  'urgente': { label: 'Urgente', bar: 'bg-red-500',   text: 'text-red-500',   badge: 'bg-red-50 text-red-500' },
  'haute':   { label: 'Haute',   bar: 'bg-amber-500', text: 'text-amber-500', badge: 'bg-amber-50 text-amber-500' },
  'normale': { label: 'Normale', bar: 'bg-primary',   text: 'text-primary',   badge: 'bg-primary/10 text-primary' },
};

const EMPTY_FORM = { codeClient: '', nomClient: '', description: '', priorite: 'normale', datePrevue: '', adresse: '' };

// ── Task Card ─────────────────────────────────────────────────────────────────
const TaskCard = ({ task, onView, onEdit, onDelete, onAdvance }) => {
  const s = STATUS_CONFIG[task.statut] ?? STATUS_CONFIG.en_cours_traitement;
  const p = PRIORITY_CONFIG[task.priorite] ?? PRIORITY_CONFIG.normale;
  const isOverdue = task.statut !== 'realisee' && task.statut !== 'annulee' && task.datePrevue && new Date(task.datePrevue) < new Date();

  return (
    <div className="bg-white rounded-premium shadow-sm border border-slate-50 hover:shadow-md hover:-translate-y-0.5 transition-all group relative overflow-hidden">
      <div className={`absolute left-0 top-0 bottom-0 w-1 ${p.bar}`} />
      <div className="p-5 pl-6">
        <div className="flex justify-between items-start mb-3">
          <span className="text-[10px] font-black text-primary uppercase tracking-widest">{task.numero}</span>
          <span className={`px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider ${s.style}`}>
            {s.label}
          </span>
        </div>
        <h4 className="text-sm font-bold text-text-primary group-hover:text-primary transition-colors mb-1 leading-snug">
          {task.nomClient}
        </h4>
        {task.description && (
          <p className="text-xs text-text-secondary mb-3 line-clamp-2 leading-relaxed">{task.description}</p>
        )}
        <div className="space-y-2 pt-3 border-t border-slate-50">
          <div className="flex items-center gap-2 text-xs font-bold text-text-secondary">
            <User size={12} className="text-secondary shrink-0" />
            <span className="truncate">{task.commercialNom}</span>
          </div>
          <div className={`flex items-center gap-2 text-xs font-bold ${isOverdue ? 'text-error' : 'text-text-secondary'}`}>
            <Calendar size={12} className={`shrink-0 ${isOverdue ? 'text-error' : 'text-secondary'}`} />
            <span>{isOverdue ? '⚠ Retard — ' : ''}{task.datePrevue}</span>
          </div>
          <div className="flex items-center gap-2">
            <Flag size={12} className={p.text} />
            <span className={`text-[10px] font-bold uppercase tracking-widest ${p.text}`}>{p.label}</span>
          </div>
        </div>
        <div className="flex gap-2 mt-4 pt-3 border-t border-slate-50">
          {s.next && (
            <button
              onClick={() => onAdvance(task.id, s.next)}
              className="flex-1 py-2 text-[10px] font-bold bg-success/10 text-success rounded-lg hover:bg-success hover:text-white transition-all flex items-center justify-center gap-1.5"
            >
              <CheckCircle2 size={11} />
              {s.nextLabel}
            </button>
          )}
          <button onClick={() => onView(task)} className="p-2 bg-slate-50 text-text-secondary rounded-lg hover:bg-primary/10 hover:text-primary border border-slate-100 transition-all" title="Détails">
            <Eye size={13} />
          </button>
          <button onClick={() => onEdit(task)} className="p-2 bg-slate-50 text-text-secondary rounded-lg hover:bg-secondary/10 hover:text-secondary border border-slate-100 transition-all" title="Modifier">
            <Edit2 size={13} />
          </button>
          <button onClick={() => onDelete(task)} className="p-2 bg-red-50 text-error rounded-lg hover:bg-error hover:text-white border border-red-100 transition-all" title="Supprimer">
            <Trash2 size={13} />
          </button>
        </div>
      </div>
    </div>
  );
};

// ── Task Row ──────────────────────────────────────────────────────────────────
const TaskRow = ({ task, onView, onEdit, onDelete, onAdvance }) => {
  const s = STATUS_CONFIG[task.statut] ?? STATUS_CONFIG.en_cours_traitement;
  const p = PRIORITY_CONFIG[task.priorite] ?? PRIORITY_CONFIG.normale;
  const isOverdue = task.statut !== 'realisee' && task.statut !== 'annulee' && task.datePrevue && new Date(task.datePrevue) < new Date();

  return (
    <tr className="group hover:bg-slate-50/50 transition-colors">
      <td className="px-5 py-4 border-b border-slate-50">
        <div className="flex items-center gap-2">
          <div className={`w-1 h-8 rounded-full ${p.bar}`} />
          <span className="text-xs font-black text-primary">{task.numero}</span>
        </div>
      </td>
      <td className="px-5 py-4 border-b border-slate-50">
        <p className="text-sm font-bold text-text-primary group-hover:text-primary transition-colors">{task.nomClient}</p>
        {task.description && <p className="text-xs text-text-secondary mt-0.5 truncate max-w-[300px]">{task.description}</p>}
      </td>
      <td className="px-5 py-4 border-b border-slate-50">
        <div className="flex items-center gap-2">
          <div className="w-6 h-6 rounded-lg bg-primary/10 text-primary text-[10px] font-black flex items-center justify-center">
            {(task.commercialNom ?? '').split(' ').map((n) => n[0]).join('').slice(0, 2)}
          </div>
          <span className="text-xs font-bold text-text-secondary">{(task.commercialNom ?? '').split(' ')[0]}</span>
        </div>
      </td>
      <td className="px-5 py-4 border-b border-slate-50">
        <span className={`px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider ${s.style}`}>{s.label}</span>
      </td>
      <td className="px-5 py-4 border-b border-slate-50">
        <span className={`px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider ${p.badge}`}>{p.label}</span>
      </td>
      <td className={`px-5 py-4 border-b border-slate-50 text-xs font-bold ${isOverdue ? 'text-error' : 'text-text-secondary'}`}>
        {isOverdue && '⚠ '}{task.datePrevue}
      </td>
      <td className="px-5 py-4 border-b border-slate-50">
        <div className="flex items-center gap-1.5">
          {s.next && (
            <button onClick={() => onAdvance(task.id, s.next)} className="p-2 bg-success/10 text-success rounded-lg hover:bg-success hover:text-white transition-all" title={s.nextLabel}>
              <CheckCircle2 size={13} />
            </button>
          )}
          <button onClick={() => onView(task)} className="p-2 bg-slate-50 text-text-secondary rounded-lg hover:text-primary hover:bg-primary/10 border border-slate-100 transition-all"><Eye size={13} /></button>
          <button onClick={() => onEdit(task)} className="p-2 bg-slate-50 text-text-secondary rounded-lg hover:text-secondary hover:bg-secondary/10 border border-slate-100 transition-all"><Edit2 size={13} /></button>
          <button onClick={() => onDelete(task)} className="p-2 bg-red-50 text-error rounded-lg hover:bg-error hover:text-white border border-red-100 transition-all"><Trash2 size={13} /></button>
        </div>
      </td>
    </tr>
  );
};

// ── Main View ─────────────────────────────────────────────────────────────────
const TaskView = () => {
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filterStatus, setFilterStatus] = useState('Tous');
  const [filterPriority, setFilterPriority] = useState('Tous');
  const [searchTerm, setSearchTerm] = useState('');
  const [viewMode, setViewMode] = useState('grid');
  const [page, setPage] = useState(1);
  const PAGE_SIZE = viewMode === 'grid' ? 6 : 8;

  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [editTask, setEditTask] = useState(null);
  const [viewTask, setViewTask] = useState(null);
  const [deleteTask, setDeleteTask] = useState(null);
  const [isDeleting, setIsDeleting] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [form, setForm] = useState(EMPTY_FORM);

  const setF = (key) => (val) => setForm((prev) => ({ ...prev, [key]: val }));

  useEffect(() => {
    setLoading(true);
    Services.tasks.getTasks({ pageSize: 50 }).then(({ data }) => {
      if (data) setTasks(data.data ?? []);
      setLoading(false);
    });
  }, []);

  const priorityOptions = Object.entries(PRIORITY_CONFIG).map(([k, v]) => ({ value: k, label: v.label, icon: Flag }));

  const filtered = tasks.filter((t) => {
    const ms = filterStatus === 'Tous' || t.statut === filterStatus;
    const mp = filterPriority === 'Tous' || t.priorite === filterPriority;
    const q = searchTerm.toLowerCase();
    const mq = !q || (t.nomClient ?? '').toLowerCase().includes(q) ||
      (t.commercialNom ?? '').toLowerCase().includes(q) ||
      (t.numero ?? '').toLowerCase().includes(q);
    return ms && mp && mq;
  });

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  const handleCreate = async () => {
    if (!form.nomClient || !form.codeClient || !form.description || !form.datePrevue) return;
    setIsSaving(true);
    const { data, error } = await Services.tasks.createTask(form);
    if (error) { alert(error.message || 'Échec de la création.'); setIsSaving(false); return; }
    if (data) setTasks((prev) => [data, ...prev]);
    setForm(EMPTY_FORM);
    setIsCreateOpen(false);
    setIsSaving(false);
  };

  const handleEdit = async () => {
    if (!editTask) return;
    setIsSaving(true);
    const patch = { description: form.description, nomClient: form.nomClient, priorite: form.priorite, datePrevue: form.datePrevue, adresse: form.adresse };
    const { data, error } = await Services.tasks.updateTask(editTask.id, patch);
    if (error) { alert(error.message || 'Échec de la mise à jour.'); setIsSaving(false); return; }
    if (data) setTasks((prev) => prev.map((t) => t.id === editTask.id ? data : t));
    setEditTask(null);
    setForm(EMPTY_FORM);
    setIsSaving(false);
  };

  const openEdit = (task) => {
    setForm({
      codeClient: task.codeClient ?? '',
      nomClient: task.nomClient ?? '',
      description: task.description ?? '',
      priorite: task.priorite ?? 'normale',
      datePrevue: task.datePrevue ?? '',
      adresse: task.adresse ?? '',
    });
    setEditTask(task);
  };

  const handleAdvance = async (id, nextStatut) => {
    const { data, error } = await Services.tasks.updateTaskStatus(id, nextStatut);
    if (!error && data) setTasks((prev) => prev.map((t) => t.id === id ? data : t));
  };

  const handleDelete = async () => {
    setIsDeleting(true);
    const { error } = await Services.tasks.deleteTask(deleteTask.id);
    if (!error) setTasks((prev) => prev.filter((t) => t.id !== deleteTask.id));
    setDeleteTask(null);
    setIsDeleting(false);
  };

  const TaskForm = ({ onSubmit, submitLabel }) => (
    <div className="space-y-5">
      <div className="grid grid-cols-2 gap-5">
        <div className="space-y-2">
          <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Client <span className="text-error">*</span></label>
          <input
            value={form.nomClient}
            onChange={(e) => setF('nomClient')(e.target.value)}
            className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all font-medium text-sm placeholder:text-slate-300"
            placeholder="Nom du client"
          />
        </div>
        <div className="space-y-2">
          <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Code client <span className="text-error">*</span></label>
          <input
            value={form.codeClient}
            onChange={(e) => setF('codeClient')(e.target.value)}
            className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all font-medium text-sm placeholder:text-slate-300"
            placeholder="ex. C0001"
          />
        </div>
      </div>
      <div className="space-y-2">
        <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Description <span className="text-error">*</span></label>
        <textarea
          value={form.description}
          onChange={(e) => setF('description')(e.target.value)}
          className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all font-medium text-sm h-20 resize-none placeholder:text-slate-300"
          placeholder="Détails de la tâche..."
        />
      </div>
      <div className="grid grid-cols-2 gap-5">
        <div className="space-y-2">
          <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Priorité</label>
          <Select options={priorityOptions} value={form.priorite} onChange={setF('priorite')} />
        </div>
        <div className="space-y-2">
          <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Date prévue <span className="text-error">*</span></label>
          <DatePicker value={form.datePrevue} onChange={setF('datePrevue')} placeholder="Sélectionner la date" />
        </div>
      </div>
      <div className="flex justify-end gap-3 pt-2">
        <button
          type="button"
          onClick={() => { setIsCreateOpen(false); setEditTask(null); setForm(EMPTY_FORM); }}
          className="px-6 py-3 text-text-secondary font-bold hover:bg-slate-50 rounded-xl transition-all"
        >
          Annuler
        </button>
        <button
          onClick={onSubmit}
          disabled={!form.nomClient || !form.codeClient || !form.description || !form.datePrevue || isSaving}
          className="bg-primary text-white px-8 py-3 rounded-xl font-bold shadow-lg shadow-primary/20 hover:bg-primary-dark transition-all disabled:opacity-40 disabled:cursor-not-allowed flex items-center gap-2"
        >
          {isSaving && <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />}
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
          <h1 className="text-3xl font-black text-text-primary tracking-tight mb-2">Gestion des Tâches</h1>
          <p className="text-text-secondary font-medium">
            <span className="font-black text-primary">{tasks.filter((t) => t.statut === 'en_cours_traitement').length}</span> en cours ·{' '}
            <span className="font-black text-success">{tasks.filter((t) => t.statut === 'realisee').length}</span> réalisées ·{' '}
            <span className="font-black text-text-secondary">{tasks.filter((t) => t.statut === 'annulee').length}</span> annulées
          </p>
        </div>
        <button
          onClick={() => { setForm(EMPTY_FORM); setIsCreateOpen(true); }}
          className="bg-primary text-white px-6 py-3 rounded-xl font-bold flex items-center gap-3 shadow-lg shadow-primary/20 transition-all hover:bg-primary-dark hover:-translate-y-0.5 self-start"
        >
          <Plus size={18} />
          Nouvelle Tâche
        </button>
      </div>

      {/* Filters */}
      <div className="bg-white p-5 rounded-premium shadow-sm border border-slate-50 flex flex-wrap items-center gap-5">
        <div className="flex-1 min-w-[240px] relative">
          <Search size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-text-secondary" />
          <input
            type="text"
            placeholder="Rechercher par client, commercial..."
            value={searchTerm}
            onChange={(e) => { setSearchTerm(e.target.value); setPage(1); }}
            className="w-full pl-11 pr-4 py-3 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all text-sm font-medium"
          />
        </div>

        <div className="flex items-center gap-1 bg-slate-50 p-1 rounded-xl border border-slate-100">
          {['Tous', ...Object.keys(STATUS_CONFIG)].map((s) => {
            const cfg = s !== 'Tous' ? STATUS_CONFIG[s] : null;
            return (
              <button
                key={s}
                onClick={() => { setFilterStatus(s); setPage(1); }}
                className={`px-3 py-2 rounded-lg text-xs font-bold transition-all ${filterStatus === s ? 'bg-white text-primary shadow-sm' : 'text-text-secondary hover:text-text-primary'}`}
              >
                {cfg ? cfg.label : 'Tous'}
              </button>
            );
          })}
        </div>

        <select
          value={filterPriority}
          onChange={(e) => { setFilterPriority(e.target.value); setPage(1); }}
          className="px-4 py-3 bg-slate-50 border border-slate-100 rounded-xl outline-none text-sm font-medium text-text-primary cursor-pointer"
        >
          <option value="Tous">Toutes priorités</option>
          {Object.entries(PRIORITY_CONFIG).map(([k, v]) => <option key={k} value={k}>{v.label}</option>)}
        </select>

        <div className="flex items-center gap-1 bg-slate-50 p-1 rounded-xl border border-slate-100 ml-auto">
          <button onClick={() => setViewMode('grid')} className={`p-2 rounded-lg transition-all ${viewMode === 'grid' ? 'bg-white text-primary shadow-sm' : 'text-text-secondary'}`}>
            <LayoutGrid size={16} />
          </button>
          <button onClick={() => setViewMode('list')} className={`p-2 rounded-lg transition-all ${viewMode === 'list' ? 'bg-white text-primary shadow-sm' : 'text-text-secondary'}`}>
            <List size={16} />
          </button>
        </div>
      </div>

      {/* Content */}
      {loading ? (
        <div className="bg-white rounded-premium shadow-sm border border-slate-50 py-20 flex items-center justify-center gap-3">
          <div className="w-6 h-6 border-2 border-primary/30 border-t-primary rounded-full animate-spin" />
          <span className="text-sm font-medium text-text-secondary">Chargement des tâches...</span>
        </div>
      ) : viewMode === 'grid' ? (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-5">
          {paginated.map((task) => (
            <TaskCard key={task.id} task={task} onView={setViewTask} onEdit={openEdit} onDelete={setDeleteTask} onAdvance={handleAdvance} />
          ))}
        </div>
      ) : (
        <div className="bg-white rounded-premium shadow-sm border border-slate-50 overflow-hidden">
          <table className="w-full border-collapse">
            <thead>
              <tr className="bg-slate-50/70">
                {['Numéro', 'Client', 'Commercial', 'Statut', 'Priorité', 'Date prévue', 'Actions'].map((h, i) => (
                  <th key={i} className="px-5 py-4 text-left text-[10px] font-bold text-text-secondary uppercase tracking-widest border-b border-slate-100">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {paginated.map((task) => (
                <TaskRow key={task.id} task={task} onView={setViewTask} onEdit={openEdit} onDelete={setDeleteTask} onAdvance={handleAdvance} />
              ))}
            </tbody>
          </table>
        </div>
      )}

      {!loading && paginated.length === 0 && (
        <div className="bg-white rounded-premium shadow-sm border border-slate-50 py-20 text-center">
          <div className="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-4">
            <Search size={24} className="text-slate-200" />
          </div>
          <p className="font-bold text-text-secondary">Aucune tâche trouvée.</p>
          <p className="text-sm text-text-secondary mt-1">Modifiez vos filtres ou créez une nouvelle tâche.</p>
        </div>
      )}

      {totalPages > 1 && (
        <div className="flex items-center justify-between">
          <p className="text-xs font-medium text-text-secondary">{filtered.length} tâche{filtered.length > 1 ? 's' : ''}</p>
          <div className="flex items-center gap-2">
            <button onClick={() => setPage((p) => Math.max(1, p - 1))} disabled={page === 1} className="p-2 rounded-lg bg-white border border-slate-100 text-text-secondary hover:bg-primary hover:text-white transition-all disabled:opacity-30">
              <ChevronLeft size={14} />
            </button>
            {Array.from({ length: totalPages }, (_, i) => i + 1).map((n) => (
              <button key={n} onClick={() => setPage(n)} className={`w-8 h-8 rounded-lg text-xs font-bold transition-all ${n === page ? 'bg-primary text-white' : 'bg-white border border-slate-100 text-text-secondary hover:bg-slate-50'}`}>{n}</button>
            ))}
            <button onClick={() => setPage((p) => Math.min(totalPages, p + 1))} disabled={page === totalPages} className="p-2 rounded-lg bg-white border border-slate-100 text-text-secondary hover:bg-primary hover:text-white transition-all disabled:opacity-30">
              <ChevronRight size={14} />
            </button>
          </div>
        </div>
      )}

      <Modal isOpen={isCreateOpen} onClose={() => { setIsCreateOpen(false); setForm(EMPTY_FORM); }} title="Nouvelle Tâche">
        {TaskForm({ onSubmit: handleCreate, submitLabel: 'Créer la tâche' })}
      </Modal>

      <Modal isOpen={!!editTask} onClose={() => { setEditTask(null); setForm(EMPTY_FORM); }} title={`Modifier — ${editTask?.numero}`}>
        {TaskForm({ onSubmit: handleEdit, submitLabel: 'Enregistrer' })}
      </Modal>

      <Modal isOpen={!!viewTask} onClose={() => setViewTask(null)} title={viewTask?.numero ?? ''}>
        {viewTask && (
          <div className="space-y-5">
            <div className="p-5 bg-slate-50 rounded-xl border border-slate-100">
              <h3 className="font-bold text-text-primary mb-2">{viewTask.nomClient}</h3>
              <p className="text-sm text-text-secondary leading-relaxed">{viewTask.description || 'Aucune description.'}</p>
            </div>
            <div className="grid grid-cols-2 gap-4">
              {[
                { label: 'Commercial', value: viewTask.commercialNom },
                { label: 'Statut', value: STATUS_CONFIG[viewTask.statut]?.label ?? viewTask.statut },
                { label: 'Priorité', value: PRIORITY_CONFIG[viewTask.priorite]?.label ?? viewTask.priorite },
                { label: 'Date prévue', value: viewTask.datePrevue },
              ].map((item, i) => (
                <div key={i} className="p-4 bg-slate-50 rounded-xl border border-slate-50">
                  <p className="text-[10px] font-bold text-text-secondary uppercase tracking-widest mb-1.5">{item.label}</p>
                  <p className="text-sm font-bold text-text-primary">{item.value}</p>
                </div>
              ))}
            </div>
            <div className="flex justify-end gap-3 pt-2">
              <button onClick={() => { setViewTask(null); openEdit(viewTask); }} className="px-6 py-3 text-primary font-bold bg-primary/10 rounded-xl hover:bg-primary hover:text-white transition-all flex items-center gap-2">
                <Edit2 size={14} /> Modifier
              </button>
            </div>
          </div>
        )}
      </Modal>

      <ConfirmDialog
        isOpen={!!deleteTask}
        onClose={() => setDeleteTask(null)}
        onConfirm={handleDelete}
        isLoading={isDeleting}
        title="Supprimer la tâche"
        message={`Êtes-vous sûr de vouloir supprimer la tâche "${deleteTask?.numero}" ? Cette action est irréversible.`}
        confirmLabel="Supprimer"
        variant="danger"
      />
    </div>
  );
};

export default TaskView;
