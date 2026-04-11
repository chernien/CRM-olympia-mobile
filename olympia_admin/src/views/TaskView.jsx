import React, { useState } from 'react';
import {
  Plus, Search, Calendar, User, AlertCircle, Activity, Zap,
  Edit2, Trash2, Eye, CheckSquare, Clock, X, LayoutGrid, List,
  ChevronLeft, ChevronRight, Flag, ArrowRight
} from 'lucide-react';
import Modal from '../components/Modal';
import Select from '../components/Select';
import DatePicker from '../components/DatePicker';
import ConfirmDialog from '../components/ConfirmDialog';

// ── Constants ────────────────────────────────────────────────────────────────
const STATUS_CONFIG = {
  'a_faire':  { label: 'À faire',   style: 'bg-warning/10 text-warning',      next: 'en_cours',  nextLabel: 'Démarrer' },
  'en_cours': { label: 'En cours',  style: 'bg-primary/10 text-primary',      next: 'terminee',  nextLabel: 'Terminer' },
  'terminee': { label: 'Terminée',  style: 'bg-success/10 text-success',      next: null,        nextLabel: null },
  'annulee':  { label: 'Annulée',   style: 'bg-slate-100 text-text-secondary', next: null,        nextLabel: null },
};

const PRIORITY_CONFIG = {
  'urgente': { label: 'Urgente', bar: 'bg-red-500',   text: 'text-red-500',   badge: 'bg-red-50 text-red-500' },
  'haute':   { label: 'Haute',   bar: 'bg-amber-500', text: 'text-amber-500', badge: 'bg-amber-50 text-amber-500' },
  'normale': { label: 'Normale', bar: 'bg-primary',   text: 'text-primary',   badge: 'bg-primary/10 text-primary' },
};

const RESPONSABLES = ['Taha Mejdoub', 'Ahmed Salhi', 'Yassine Rachidi', 'Leila Benali'];

// ── Initial Data ─────────────────────────────────────────────────────────────
const INITIAL_TASKS = [
  { id: 'TSK-001', title: 'Livraison Peinture Façade', assignedTo: 'Ahmed Salhi',   deadline: '2024-03-20', status: 'en_cours',  priority: 'haute',   description: 'Livraison lot commande #4521 chez Brico Déco Casablanca.' },
  { id: 'TSK-002', title: 'Visite Client Brico Déco',  assignedTo: 'Taha Mejdoub',  deadline: '2024-03-18', status: 'terminee',  priority: 'normale', description: 'Visite de suivi et présentation nouveaux produits.' },
  { id: 'TSK-003', title: 'Inventaire Dépôt Rabat',    assignedTo: 'Yassine Rachidi', deadline: '2024-03-22', status: 'a_faire',   priority: 'urgente', description: 'Inventaire complet du dépôt — rapport sous 48h.' },
  { id: 'TSK-004', title: 'Validation Devis #45',      assignedTo: 'Ahmed Salhi',   deadline: '2024-03-19', status: 'en_cours',  priority: 'haute',   description: 'Finaliser et valider le devis pour Atlas Construction.' },
  { id: 'TSK-005', title: 'Formation Nouveau Produit', assignedTo: 'Leila Benali',  deadline: '2024-03-25', status: 'a_faire',   priority: 'normale', description: 'Session formation gamme Décor Prestige — équipe commerciale.' },
  { id: 'TSK-006', title: 'Rapport Mensuel CA',        assignedTo: 'Taha Mejdoub',  deadline: '2024-03-31', status: 'a_faire',   priority: 'normale', description: 'Préparer le rapport de CA mensuel pour la réunion direction.' },
];

const EMPTY_FORM = { title: '', assignedTo: 'Ahmed Salhi', priority: 'normale', deadline: '', description: '' };

// ── Task Card ─────────────────────────────────────────────────────────────────
const TaskCard = ({ task, onView, onEdit, onDelete, onAdvance }) => {
  const s = STATUS_CONFIG[task.status];
  const p = PRIORITY_CONFIG[task.priority];
  const isOverdue = task.status !== 'terminee' && new Date(task.deadline) < new Date();

  return (
    <div className="bg-white rounded-premium shadow-sm border border-slate-50 hover:shadow-md hover:-translate-y-0.5 transition-all group relative overflow-hidden">
      {/* Priority bar */}
      <div className={`absolute left-0 top-0 bottom-0 w-1 ${p.bar}`}></div>

      <div className="p-5 pl-6">
        <div className="flex justify-between items-start mb-3">
          <span className="text-[10px] font-black text-primary uppercase tracking-widest">{task.id}</span>
          <span className={`px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider ${s.style}`}>
            {s.label}
          </span>
        </div>

        <h4 className="text-sm font-bold text-text-primary group-hover:text-primary transition-colors mb-3 leading-snug">
          {task.title}
        </h4>

        {task.description && (
          <p className="text-xs text-text-secondary mb-3 line-clamp-2 leading-relaxed">{task.description}</p>
        )}

        <div className="space-y-2 pt-3 border-t border-slate-50">
          <div className="flex items-center gap-2 text-xs font-bold text-text-secondary">
            <User size={12} className="text-secondary shrink-0" />
            <span className="truncate">{task.assignedTo}</span>
          </div>
          <div className={`flex items-center gap-2 text-xs font-bold ${isOverdue ? 'text-error' : 'text-text-secondary'}`}>
            <Calendar size={12} className={`shrink-0 ${isOverdue ? 'text-error' : 'text-secondary'}`} />
            <span>{isOverdue ? '⚠ Retard — ' : ''}{task.deadline}</span>
          </div>
          <div className="flex items-center gap-2">
            <Flag size={12} className={p.text} />
            <span className={`text-[10px] font-bold uppercase tracking-widest ${p.text}`}>{p.label}</span>
          </div>
        </div>

        {/* Action buttons */}
        <div className="flex gap-2 mt-4 pt-3 border-t border-slate-50">
          {s.next && (
            <button
              onClick={() => onAdvance(task.id)}
              className="flex-1 py-2 text-[10px] font-bold bg-primary/10 text-primary rounded-lg hover:bg-primary hover:text-white transition-all flex items-center justify-center gap-1.5"
            >
              <ArrowRight size={11} />
              {s.nextLabel}
            </button>
          )}
          <button
            onClick={() => onView(task)}
            className="p-2 bg-slate-50 text-text-secondary rounded-lg hover:bg-primary/10 hover:text-primary border border-slate-100 transition-all"
            title="Détails"
          >
            <Eye size={13} />
          </button>
          <button
            onClick={() => onEdit(task)}
            className="p-2 bg-slate-50 text-text-secondary rounded-lg hover:bg-secondary/10 hover:text-secondary border border-slate-100 transition-all"
            title="Modifier"
          >
            <Edit2 size={13} />
          </button>
          <button
            onClick={() => onDelete(task)}
            className="p-2 bg-red-50 text-error rounded-lg hover:bg-error hover:text-white border border-red-100 transition-all"
            title="Supprimer"
          >
            <Trash2 size={13} />
          </button>
        </div>
      </div>
    </div>
  );
};

// ── Task Row (list view) ──────────────────────────────────────────────────────
const TaskRow = ({ task, onView, onEdit, onDelete, onAdvance }) => {
  const s = STATUS_CONFIG[task.status];
  const p = PRIORITY_CONFIG[task.priority];
  const isOverdue = task.status !== 'terminee' && new Date(task.deadline) < new Date();

  return (
    <tr className="group hover:bg-slate-50/50 transition-colors">
      <td className="px-5 py-4 border-b border-slate-50">
        <div className="flex items-center gap-2">
          <div className={`w-1 h-8 rounded-full ${p.bar}`}></div>
          <span className="text-xs font-black text-primary">{task.id}</span>
        </div>
      </td>
      <td className="px-5 py-4 border-b border-slate-50">
        <p className="text-sm font-bold text-text-primary group-hover:text-primary transition-colors">{task.title}</p>
        {task.description && <p className="text-xs text-text-secondary mt-0.5 truncate max-w-[300px]">{task.description}</p>}
      </td>
      <td className="px-5 py-4 border-b border-slate-50">
        <div className="flex items-center gap-2">
          <div className="w-6 h-6 rounded-lg bg-primary/10 text-primary text-[10px] font-black flex items-center justify-center">
            {task.assignedTo.split(' ').map(n => n[0]).join('').slice(0, 2)}
          </div>
          <span className="text-xs font-bold text-text-secondary">{task.assignedTo.split(' ')[0]}</span>
        </div>
      </td>
      <td className="px-5 py-4 border-b border-slate-50">
        <span className={`px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider ${s.style}`}>{s.label}</span>
      </td>
      <td className="px-5 py-4 border-b border-slate-50">
        <span className={`px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider ${p.badge}`}>{p.label}</span>
      </td>
      <td className={`px-5 py-4 border-b border-slate-50 text-xs font-bold ${isOverdue ? 'text-error' : 'text-text-secondary'}`}>
        {isOverdue && '⚠ '}{task.deadline}
      </td>
      <td className="px-5 py-4 border-b border-slate-50">
        <div className="flex items-center gap-1.5">
          {s.next && (
            <button onClick={() => onAdvance(task.id)} className="p-2 bg-primary/10 text-primary rounded-lg hover:bg-primary hover:text-white transition-all" title={s.nextLabel}>
              <ArrowRight size={13} />
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
  const [tasks, setTasks] = useState(INITIAL_TASKS);
  const [filterStatus, setFilterStatus] = useState('Tous');
  const [filterPriority, setFilterPriority] = useState('Tous');
  const [searchTerm, setSearchTerm] = useState('');
  const [viewMode, setViewMode] = useState('grid'); // 'grid' | 'list'
  const [page, setPage] = useState(1);
  const PAGE_SIZE = viewMode === 'grid' ? 6 : 8;

  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [editTask, setEditTask] = useState(null);
  const [viewTask, setViewTask] = useState(null);
  const [deleteTask, setDeleteTask] = useState(null);
  const [isDeleting, setIsDeleting] = useState(false);
  const [form, setForm] = useState(EMPTY_FORM);

  const setF = (key) => (val) => setForm(prev => ({ ...prev, [key]: val }));

  const responsableOptions = RESPONSABLES.map(r => ({ value: r, label: r, icon: User }));
  const priorityOptions = Object.entries(PRIORITY_CONFIG).map(([k, v]) => ({ value: k, label: v.label, icon: Flag }));
  const statusOptions = Object.entries(STATUS_CONFIG).map(([k, v]) => ({ value: k, label: v.label, icon: CheckSquare }));

  const filtered = tasks.filter(t => {
    const ms = filterStatus === 'Tous' || t.status === filterStatus;
    const mp = filterPriority === 'Tous' || t.priority === filterPriority;
    const mq = t.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
               t.assignedTo.toLowerCase().includes(searchTerm.toLowerCase()) ||
               t.id.toLowerCase().includes(searchTerm.toLowerCase());
    return ms && mp && mq;
  });

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  const handleCreate = () => {
    const id = `TSK-${String(tasks.length + 1).padStart(3, '0')}`;
    setTasks(prev => [{ id, ...form }, ...prev]);
    setForm(EMPTY_FORM);
    setIsCreateOpen(false);
  };

  const handleEdit = () => {
    setTasks(prev => prev.map(t => t.id === editTask.id ? { ...t, ...form } : t));
    setEditTask(null);
    setForm(EMPTY_FORM);
  };

  const openEdit = (task) => {
    setForm({ title: task.title, assignedTo: task.assignedTo, priority: task.priority, deadline: task.deadline, description: task.description || '' });
    setEditTask(task);
  };

  const handleAdvance = (id) => {
    setTasks(prev => prev.map(t => {
      if (t.id !== id) return t;
      const next = STATUS_CONFIG[t.status].next;
      return next ? { ...t, status: next } : t;
    }));
  };

  const handleDelete = async () => {
    setIsDeleting(true);
    await new Promise(r => setTimeout(r, 500));
    setTasks(prev => prev.filter(t => t.id !== deleteTask.id));
    setDeleteTask(null);
    setIsDeleting(false);
  };

  const TaskForm = ({ onSubmit, submitLabel }) => (
    <div className="space-y-5">
      <div className="space-y-2">
        <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Titre <span className="text-error">*</span></label>
        <input
          value={form.title}
          onChange={(e) => setF('title')(e.target.value)}
          className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all font-medium text-sm placeholder:text-slate-300"
          placeholder="Ex: Livraison client Alpha"
        />
      </div>
      <div className="space-y-2">
        <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Description</label>
        <textarea
          value={form.description}
          onChange={(e) => setF('description')(e.target.value)}
          className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all font-medium text-sm h-20 resize-none placeholder:text-slate-300"
          placeholder="Détails de la tâche..."
        />
      </div>
      <div className="grid grid-cols-2 gap-5">
        <div className="space-y-2">
          <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Responsable</label>
          <Select options={responsableOptions} value={form.assignedTo} onChange={setF('assignedTo')} />
        </div>
        <div className="space-y-2">
          <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Priorité</label>
          <Select options={priorityOptions} value={form.priority} onChange={setF('priority')} />
        </div>
      </div>
      <div className="space-y-2">
        <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Date d'échéance</label>
        <DatePicker value={form.deadline} onChange={setF('deadline')} placeholder="Sélectionner la date" />
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
          disabled={!form.title}
          className="bg-primary text-white px-8 py-3 rounded-xl font-bold shadow-lg shadow-primary/20 hover:bg-primary-dark transition-all disabled:opacity-40 disabled:cursor-not-allowed"
        >
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
            <span className="font-black text-text-primary">{tasks.filter(t => t.status === 'en_cours').length}</span> en cours ·{' '}
            <span className="font-black text-warning">{tasks.filter(t => t.status === 'a_faire').length}</span> à démarrer ·{' '}
            <span className="font-black text-success">{tasks.filter(t => t.status === 'terminee').length}</span> terminées
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
            placeholder="Rechercher une tâche..."
            value={searchTerm}
            onChange={(e) => { setSearchTerm(e.target.value); setPage(1); }}
            className="w-full pl-11 pr-4 py-3 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all text-sm font-medium"
          />
        </div>

        {/* Status filter */}
        <div className="flex items-center gap-1 bg-slate-50 p-1 rounded-xl border border-slate-100">
          {['Tous', ...Object.keys(STATUS_CONFIG)].map(s => {
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

        {/* Priority filter */}
        <select
          value={filterPriority}
          onChange={(e) => { setFilterPriority(e.target.value); setPage(1); }}
          className="px-4 py-3 bg-slate-50 border border-slate-100 rounded-xl outline-none text-sm font-medium text-text-primary cursor-pointer"
        >
          <option value="Tous">Toutes priorités</option>
          {Object.entries(PRIORITY_CONFIG).map(([k, v]) => <option key={k} value={k}>{v.label}</option>)}
        </select>

        {/* View toggle */}
        <div className="flex items-center gap-1 bg-slate-50 p-1 rounded-xl border border-slate-100 ml-auto">
          <button
            onClick={() => setViewMode('grid')}
            className={`p-2 rounded-lg transition-all ${viewMode === 'grid' ? 'bg-white text-primary shadow-sm' : 'text-text-secondary'}`}
          >
            <LayoutGrid size={16} />
          </button>
          <button
            onClick={() => setViewMode('list')}
            className={`p-2 rounded-lg transition-all ${viewMode === 'list' ? 'bg-white text-primary shadow-sm' : 'text-text-secondary'}`}
          >
            <List size={16} />
          </button>
        </div>
      </div>

      {/* Content */}
      {viewMode === 'grid' ? (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-5">
          {paginated.map(task => (
            <TaskCard
              key={task.id}
              task={task}
              onView={setViewTask}
              onEdit={openEdit}
              onDelete={setDeleteTask}
              onAdvance={handleAdvance}
            />
          ))}
        </div>
      ) : (
        <div className="bg-white rounded-premium shadow-sm border border-slate-50 overflow-hidden">
          <table className="w-full border-collapse">
            <thead>
              <tr className="bg-slate-50/70">
                {['ID', 'Titre', 'Responsable', 'Statut', 'Priorité', 'Échéance', 'Actions'].map((h, i) => (
                  <th key={i} className="px-5 py-4 text-left text-[10px] font-bold text-text-secondary uppercase tracking-widest border-b border-slate-100">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {paginated.map(task => (
                <TaskRow
                  key={task.id}
                  task={task}
                  onView={setViewTask}
                  onEdit={openEdit}
                  onDelete={setDeleteTask}
                  onAdvance={handleAdvance}
                />
              ))}
            </tbody>
          </table>
        </div>
      )}

      {paginated.length === 0 && (
        <div className="bg-white rounded-premium shadow-sm border border-slate-50 py-20 text-center">
          <div className="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-4">
            <Search size={24} className="text-slate-200" />
          </div>
          <p className="font-bold text-text-secondary">Aucune tâche trouvée.</p>
          <p className="text-sm text-text-secondary mt-1">Modifiez vos filtres ou créez une nouvelle tâche.</p>
        </div>
      )}

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-between">
          <p className="text-xs font-medium text-text-secondary">{filtered.length} tâche{filtered.length > 1 ? 's' : ''}</p>
          <div className="flex items-center gap-2">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="p-2 rounded-lg bg-white border border-slate-100 text-text-secondary hover:bg-primary hover:text-white transition-all disabled:opacity-30">
              <ChevronLeft size={14} />
            </button>
            {Array.from({ length: totalPages }, (_, i) => i + 1).map(n => (
              <button key={n} onClick={() => setPage(n)} className={`w-8 h-8 rounded-lg text-xs font-bold transition-all ${n === page ? 'bg-primary text-white' : 'bg-white border border-slate-100 text-text-secondary hover:bg-slate-50'}`}>{n}</button>
            ))}
            <button onClick={() => setPage(p => Math.min(totalPages, p + 1))} disabled={page === totalPages} className="p-2 rounded-lg bg-white border border-slate-100 text-text-secondary hover:bg-primary hover:text-white transition-all disabled:opacity-30">
              <ChevronRight size={14} />
            </button>
          </div>
        </div>
      )}

      {/* Create Modal */}
      <Modal isOpen={isCreateOpen} onClose={() => { setIsCreateOpen(false); setForm(EMPTY_FORM); }} title="Nouvelle Tâche">
        <TaskForm onSubmit={handleCreate} submitLabel="Créer la tâche" />
      </Modal>

      {/* Edit Modal */}
      <Modal isOpen={!!editTask} onClose={() => { setEditTask(null); setForm(EMPTY_FORM); }} title={`Modifier — ${editTask?.id}`}>
        <TaskForm onSubmit={handleEdit} submitLabel="Enregistrer" />
      </Modal>

      {/* View Modal */}
      <Modal isOpen={!!viewTask} onClose={() => setViewTask(null)} title={viewTask?.id || ''}>
        {viewTask && (
          <div className="space-y-5">
            <div className="p-5 bg-slate-50 rounded-xl border border-slate-100">
              <h3 className="font-bold text-text-primary mb-2">{viewTask.title}</h3>
              <p className="text-sm text-text-secondary leading-relaxed">{viewTask.description || 'Aucune description.'}</p>
            </div>
            <div className="grid grid-cols-2 gap-4">
              {[
                { label: 'Responsable', value: viewTask.assignedTo },
                { label: 'Statut', value: STATUS_CONFIG[viewTask.status].label },
                { label: 'Priorité', value: PRIORITY_CONFIG[viewTask.priority].label },
                { label: 'Échéance', value: viewTask.deadline },
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

      {/* Delete Confirm */}
      <ConfirmDialog
        isOpen={!!deleteTask}
        onClose={() => setDeleteTask(null)}
        onConfirm={handleDelete}
        isLoading={isDeleting}
        title="Supprimer la tâche"
        message={`Êtes-vous sûr de vouloir supprimer "${deleteTask?.title}" ? Cette action est irréversible.`}
        confirmLabel="Supprimer"
        variant="danger"
      />
    </div>
  );
};

export default TaskView;
