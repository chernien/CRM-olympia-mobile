import React, { useState, useEffect } from 'react';
import {
  Plus, Target, TrendingUp, CheckSquare, Edit2, Trash2,
  Calendar, X,
} from 'lucide-react';
import Modal from '../components/Modal';
import Select from '../components/Select';
import ConfirmDialog from '../components/ConfirmDialog';
import { Services } from '../services/index.js';
import { useAuth } from '../context/AuthContext.jsx';

const TYPE_CONFIG = {
  chiffre_affaire: { label: "Chiffre d'affaires", icon: TrendingUp, badge: 'bg-primary/10 text-primary border-primary/20', tile: 'bg-primary/10 text-primary', unit: 'MAD' },
  tache:           { label: 'Tâche', icon: CheckSquare, badge: 'bg-secondary/10 text-secondary border-secondary/20', tile: 'bg-secondary/10 text-secondary', unit: '' },
};
const PERIODE_CONFIG = {
  mois:      { label: 'Mensuel' },
  trimestre: { label: 'Trimestriel' },
};

const TYPE_OPTIONS = [
  { value: 'chiffre_affaire', label: "Chiffre d'affaires", icon: TrendingUp },
  { value: 'tache', label: 'Tâche', icon: CheckSquare },
];
const PERIODE_OPTIONS = [
  { value: 'mois', label: 'Mensuel', icon: Calendar },
  { value: 'trimestre', label: 'Trimestriel', icon: Calendar },
];
const EMPTY_FORM = { type: 'chiffre_affaire', valeur: '', description: '', periode: 'mois' };

const formatValeur = (o) => {
  const cfg = TYPE_CONFIG[o.type] ?? TYPE_CONFIG.chiffre_affaire;
  const n = Number(o.valeur) || 0;
  return cfg.unit ? `${n.toLocaleString('fr-FR')} ${cfg.unit}` : `${n.toLocaleString('fr-FR')}`;
};

const ObjectifsView = () => {
  const { user } = useAuth();
  const isAdmin = user?.role === 'admin';

  const [objectifs, setObjectifs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [editObjectif, setEditObjectif] = useState(null);
  const [deleteObjectif, setDeleteObjectif] = useState(null);
  const [isDeleting, setIsDeleting] = useState(false);
  const [form, setForm] = useState(EMPTY_FORM);
  const setF = (key) => (val) => setForm((prev) => ({ ...prev, [key]: val }));

  useEffect(() => {
    setLoading(true);
    Services.objectifs.getObjectifs().then(({ data }) => {
      if (data) setObjectifs(data);
      setLoading(false);
    });
  }, []);

  const payload = () => ({
    type: form.type,
    valeur: Number(form.valeur) || 0,
    description: form.description.trim(),
    periode: form.periode,
  });

  const handleCreate = async () => {
    if (!form.description.trim() || !form.valeur) return;
    setIsSaving(true);
    const { data, error } = await Services.objectifs.createObjectif(payload());
    if (error) { alert(error.message || 'Échec de la création.'); setIsSaving(false); return; }
    if (data) setObjectifs((prev) => [data, ...prev]);
    setForm(EMPTY_FORM);
    setIsCreateOpen(false);
    setIsSaving(false);
  };

  const openEdit = (o) => {
    setForm({ type: o.type, valeur: String(o.valeur), description: o.description, periode: o.periode });
    setEditObjectif(o);
  };

  const handleEdit = async () => {
    if (!editObjectif) return;
    setIsSaving(true);
    const { data, error } = await Services.objectifs.updateObjectif(editObjectif.id, payload());
    if (error) { alert(error.message || 'Échec de la mise à jour.'); setIsSaving(false); return; }
    if (data) setObjectifs((prev) => prev.map((o) => o.id === editObjectif.id ? data : o));
    setEditObjectif(null);
    setForm(EMPTY_FORM);
    setIsSaving(false);
  };

  const handleDelete = async () => {
    setIsDeleting(true);
    const { error } = await Services.objectifs.deleteObjectif(deleteObjectif.id);
    if (!error) setObjectifs((prev) => prev.filter((o) => o.id !== deleteObjectif.id));
    setDeleteObjectif(null);
    setIsDeleting(false);
  };

  const ObjectifForm = ({ onSubmit, submitLabel }) => (
    <div className="space-y-5">
      <div className="grid grid-cols-2 gap-5">
        <div className="space-y-2">
          <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Type d'objectif</label>
          <Select options={TYPE_OPTIONS} value={form.type} onChange={setF('type')} />
        </div>
        <div className="space-y-2">
          <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Période</label>
          <Select options={PERIODE_OPTIONS} value={form.periode} onChange={setF('periode')} />
        </div>
      </div>
      <div className="space-y-2">
        <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">
          Valeur cible <span className="text-error">*</span>
          <span className="ml-1 normal-case font-medium text-slate-400">
            {form.type === 'chiffre_affaire' ? '(MAD)' : '(nombre, ex. visites)'}
          </span>
        </label>
        <input
          type="number" min="0"
          value={form.valeur}
          onChange={(e) => setF('valeur')(e.target.value)}
          className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all font-medium text-sm placeholder:text-slate-300"
          placeholder={form.type === 'chiffre_affaire' ? 'ex. 100000' : 'ex. 12'}
        />
      </div>
      <div className="space-y-2">
        <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">Description <span className="text-error">*</span></label>
        <textarea
          value={form.description}
          onChange={(e) => setF('description')(e.target.value)}
          className="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/30 focus:bg-white transition-all font-medium text-sm h-24 resize-none placeholder:text-slate-300"
          placeholder="ex. Nombre de visites client à réaliser ce mois"
        />
      </div>
      <div className="flex justify-end gap-3 pt-2">
        <button type="button" onClick={() => { setIsCreateOpen(false); setEditObjectif(null); setForm(EMPTY_FORM); }} className="px-6 py-3 text-text-secondary font-bold hover:bg-slate-50 rounded-xl transition-all">
          Annuler
        </button>
        <button
          onClick={onSubmit}
          disabled={!form.description.trim() || !form.valeur || isSaving}
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
          <h1 className="text-3xl font-black text-text-primary tracking-tight mb-2">Objectifs</h1>
          <p className="text-text-secondary font-medium">
            <span className="font-black text-text-primary">{objectifs.length}</span> objectif{objectifs.length > 1 ? 's' : ''} fixé{objectifs.length > 1 ? 's' : ''} pour l'équipe commerciale
          </p>
        </div>
        {isAdmin && (
          <button
            onClick={() => { setForm(EMPTY_FORM); setIsCreateOpen(true); }}
            className="bg-primary text-white px-6 py-3 rounded-xl font-bold flex items-center gap-3 shadow-lg shadow-primary/20 transition-all hover:bg-primary-dark hover:-translate-y-0.5 self-start"
          >
            <Plus size={18} />
            Nouvel objectif
          </button>
        )}
      </div>

      {/* Content */}
      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
          {Array(3).fill(0).map((_, i) => <div key={i} className="bg-white p-6 rounded-premium shadow-sm border border-slate-50 animate-pulse h-48" />)}
        </div>
      ) : objectifs.length === 0 ? (
        <div className="bg-white rounded-premium shadow-sm border border-slate-50 py-20 text-center">
          <div className="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-4">
            <Target size={24} className="text-slate-300" />
          </div>
          <p className="font-bold text-text-secondary">Aucun objectif défini.</p>
          {isAdmin && <p className="text-sm text-text-secondary mt-1">Créez le premier objectif pour votre équipe.</p>}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
          {objectifs.map((o) => {
            const cfg = TYPE_CONFIG[o.type] ?? TYPE_CONFIG.chiffre_affaire;
            const TypeIcon = cfg.icon;
            const periode = PERIODE_CONFIG[o.periode]?.label ?? o.periode;
            return (
              <div key={o.id} className="bg-white p-6 rounded-premium shadow-sm border border-slate-50 hover:shadow-md hover:-translate-y-0.5 transition-all group">
                <div className="flex items-start justify-between mb-4">
                  <div className={`p-3 rounded-xl ${cfg.tile}`}><TypeIcon size={20} /></div>
                  <span className="px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider bg-slate-50 text-text-secondary border border-slate-100 flex items-center gap-1.5">
                    <Calendar size={11} /> {periode}
                  </span>
                </div>
                <span className={`inline-block px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider border ${cfg.badge} mb-2`}>
                  {cfg.label}
                </span>
                <p className="text-2xl font-black text-text-primary mb-2">{formatValeur(o)}</p>
                <p className="text-sm text-text-secondary leading-relaxed line-clamp-3">{o.description}</p>

                {isAdmin && (
                  <div className="flex gap-2 mt-5 pt-4 border-t border-slate-50">
                    <button onClick={() => openEdit(o)} className="flex-1 py-2 text-xs font-bold text-primary bg-primary/10 rounded-lg hover:bg-primary hover:text-white transition-all flex items-center justify-center gap-1.5">
                      <Edit2 size={12} /> Modifier
                    </button>
                    <button onClick={() => setDeleteObjectif(o)} className="p-2 bg-red-50 text-error rounded-lg hover:bg-error hover:text-white border border-red-100 transition-all" title="Supprimer">
                      <Trash2 size={14} />
                    </button>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}

      <Modal isOpen={isCreateOpen} onClose={() => { setIsCreateOpen(false); setForm(EMPTY_FORM); }} title="Nouvel objectif">
        {ObjectifForm({ onSubmit: handleCreate, submitLabel: "Créer l'objectif" })}
      </Modal>

      <Modal isOpen={!!editObjectif} onClose={() => { setEditObjectif(null); setForm(EMPTY_FORM); }} title="Modifier l'objectif">
        {ObjectifForm({ onSubmit: handleEdit, submitLabel: 'Enregistrer' })}
      </Modal>

      <ConfirmDialog
        isOpen={!!deleteObjectif}
        onClose={() => setDeleteObjectif(null)}
        onConfirm={handleDelete}
        isLoading={isDeleting}
        title="Supprimer l'objectif"
        message="Êtes-vous sûr de vouloir supprimer cet objectif ? Cette action est irréversible."
        confirmLabel="Supprimer"
        variant="danger"
      />
    </div>
  );
};

export default ObjectifsView;
