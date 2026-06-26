import React, { useState, useEffect } from 'react';
import {
  TrendingUp, ClipboardList, CheckCircle2,
  ArrowUpRight, ArrowDownRight, MoreHorizontal,
  Calendar, Target, Activity, Clock, ChevronRight,
  Package, UserCheck, AlertCircle
} from 'lucide-react';
import { Link } from 'react-router-dom';
import { Services } from '../services/index.js';
import { useAuth } from '../context/AuthContext.jsx';

const PERIODS = [
  { label: 'Ce mois', value: 'month' },
  { label: 'Ce trimestre', value: 'quarter' },
];

const STATUS_MAP = {
  nouvelle:            { label: 'Nouvelle',      style: 'bg-blue-50 text-blue-600' },
  en_cours_validation: { label: 'En validation', style: 'bg-amber-50 text-amber-600' },
  validee:             { label: 'Validée',        style: 'bg-success/10 text-success' },
  refusee:             { label: 'Refusée',        style: 'bg-red-50 text-error' },
  en_cours_traitement: { label: 'En traitement', style: 'bg-yellow-50 text-yellow-700' },
  traitee:             { label: 'Traitée',        style: 'bg-emerald-50 text-emerald-700' },
  cloturee:            { label: 'Clôturée',       style: 'bg-slate-100 text-text-secondary' },
};

function fmt(val) {
  if (val >= 1000000) return `${(val / 1000000).toFixed(1)}M`;
  if (val >= 1000) return `${Math.round(val / 1000)}K`;
  return String(val);
}


const DashboardView = () => {
  const { user } = useAuth();
  const [period, setPeriod] = useState('month');
  const [stats, setStats] = useState(null);
  const [recentDemandes, setRecentDemandes] = useState([]);
  const [loadingStats, setLoadingStats] = useState(true);
  const [loadingDemandes, setLoadingDemandes] = useState(true);

  useEffect(() => {
    setLoadingStats(true);
    Services.dashboard.getStats(period).then(({ data }) => {
      if (data) setStats(data);
      setLoadingStats(false);
    });
  }, [period]);

  useEffect(() => {
    setLoadingDemandes(true);
    Services.demandes.getDemandes({ pageSize: 4 }).then(({ data }) => {
      if (data) setRecentDemandes(data.data ?? []);
      setLoadingDemandes(false);
    });
  }, []);

  const d = stats;
  const caTotal = d?.ca ?? 0;
  const caIntern = d?.caIntern ?? 0;
  const caExtern = d?.caExtern ?? 0;
  const caOlybat = d?.caOlybat ?? 0;
  const internPct = caTotal > 0 ? Math.round((caIntern / caTotal) * 100) : 0;
  const externPct = caTotal > 0 ? Math.round((caExtern / caTotal) * 100) : 0;
  const olybatPct = caTotal > 0 ? Math.round((caOlybat / caTotal) * 100) : 0;
  const objectif = user?.objectifCA ?? 2000000;
  const objectifPct = objectif > 0 ? Math.min(100, Math.round((caTotal / objectif) * 100)) : 0;
  const remaining = Math.max(0, objectif - caTotal);

  const kpiCards = [
    { title: 'CA Global', value: `${fmt(caTotal)} MAD`, trend: d?.caTrend ?? 0, icon: <TrendingUp size={20} className="text-primary" />, bg: 'bg-primary/10' },
    { title: 'Demandes Actives', value: `${d?.demandes ?? 0} nouvelles`, trend: d?.demandesTrend ?? 0, icon: <ClipboardList size={20} className="text-secondary" />, bg: 'bg-secondary/10' },
    { title: 'Tâches ce mois', value: `${d?.taches ?? 0} tâches`, trend: d?.tachesTrend ?? 0, icon: <CheckCircle2 size={20} className="text-success" />, bg: 'bg-success/10' },
    { title: 'Visites Clients', value: `${d?.visites ?? 0} visites`, trend: d?.visitesTrend ?? 0, icon: <UserCheck size={20} className="text-warning" />, bg: 'bg-warning/10' },
  ];

  const userName = user ? `${user.prenom} ${user.nom}` : 'Admin';

  return (
    <div className="max-w-[1400px] mx-auto animate-in fade-in slide-in-from-bottom-4 duration-700 space-y-8">
      {/* Welcome Banner */}
      <div className="p-10 rounded-premium bg-gradient-to-r from-primary to-primary-dark text-white relative overflow-hidden shadow-premium">
        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div className="max-w-[550px]">
            <div className="inline-flex items-center gap-2 bg-white/15 backdrop-blur-sm px-3 py-1.5 rounded-full mb-4">
              <div className="w-1.5 h-1.5 bg-green-400 rounded-full animate-pulse" />
              <span className="text-white/80 text-[10px] font-bold uppercase tracking-widest">Système actif</span>
            </div>
            <h1 className="text-3xl font-black mb-2 leading-tight tracking-tight">Bonjour, {userName} !</h1>
            <p className="text-white/70 text-sm font-medium leading-relaxed">
              Voici un aperçu en temps réel des performances Olympia.
              {d ? ` ${d.demandes} demandes attendent votre validation.` : ''}
            </p>
          </div>
          <div className="flex items-center gap-4 shrink-0">
            <div className="bg-white/15 backdrop-blur-sm rounded-2xl p-4 border border-white/10 text-center min-w-[90px]">
              <p className="text-2xl font-black text-white">{d?.demandes ?? '—'}</p>
              <p className="text-white/60 text-[10px] font-bold uppercase tracking-widest mt-1">À valider</p>
            </div>
            <div className="bg-white/15 backdrop-blur-sm rounded-2xl p-4 border border-white/10 text-center min-w-[90px]">
              <p className="text-2xl font-black text-white">{d?.visites ?? '—'}</p>
              <p className="text-white/60 text-[10px] font-bold uppercase tracking-widest mt-1">Visites</p>
            </div>
          </div>
        </div>
        <div className="absolute right-[-60px] top-[-60px] w-[280px] h-[280px] bg-white/10 rounded-full blur-3xl" />
        <div className="absolute right-[100px] bottom-[-40px] w-[200px] h-[200px] bg-white/5 rounded-full blur-3xl" />
      </div>

      {/* Period selector */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-1 bg-white p-1 rounded-xl border border-slate-100 shadow-sm">
          {PERIODS.map((p) => (
            <button
              key={p.value}
              onClick={() => setPeriod(p.value)}
              className={`px-5 py-2 rounded-lg text-xs font-bold transition-all ${
                period === p.value ? 'bg-primary text-white shadow-sm shadow-primary/20' : 'text-text-secondary hover:text-text-primary'
              }`}
            >
              {p.label}
            </button>
          ))}
        </div>
        <div className="flex items-center gap-2 text-xs font-bold text-text-secondary">
          <Calendar size={14} />
          <span>Mis à jour en temps réel</span>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-5">
        {kpiCards.map((card, i) => {
          const isPos = card.trend >= 0;
          return (
            <div key={i} className="bg-white p-6 rounded-premium shadow-sm border border-slate-50 hover:shadow-md hover:-translate-y-0.5 transition-all group">
              <div className="flex justify-between items-start mb-4">
                <div className={`p-3 ${card.bg} rounded-xl`}>{card.icon}</div>
                {loadingStats ? (
                  <div className="w-12 h-6 bg-slate-100 rounded-full animate-pulse" />
                ) : (
                  <span className={`text-[10px] font-bold flex items-center gap-0.5 px-2 py-1 rounded-full ${isPos ? 'text-success bg-success/10' : 'text-error bg-red-50'}`}>
                    {isPos ? <ArrowUpRight size={10} /> : <ArrowDownRight size={10} />}
                    {Math.abs(card.trend)}%
                  </span>
                )}
              </div>
              <p className="text-[10px] font-bold text-text-secondary uppercase tracking-widest mb-1">{card.title}</p>
              {loadingStats
                ? <div className="h-7 w-28 bg-slate-100 rounded animate-pulse" />
                : <p className="text-xl font-black text-text-primary">{card.value}</p>
              }
            </div>
          );
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-[1fr_340px] gap-8">
        {/* Main */}
        <div className="space-y-8">
          {/* CA Segments */}
          <div className="bg-white p-8 rounded-premium shadow-sm border border-slate-50">
            <div className="flex justify-between items-center mb-8">
              <div>
                <h3 className="text-lg font-bold text-text-primary">Répartition CA par Segment</h3>
                <p className="text-xs text-text-secondary mt-1">Total: <span className="font-bold text-text-primary">{fmt(caTotal)} MAD</span></p>
              </div>
              <button className="p-2 rounded-xl hover:bg-slate-50 transition-colors">
                <MoreHorizontal size={20} className="text-text-secondary" />
              </button>
            </div>
            <div className="space-y-5">
              {[
                { label: 'Segment INTERN', value: fmt(caIntern), perc: internPct, color: 'bg-primary', dot: 'bg-primary' },
                { label: 'Segment EXTERN', value: fmt(caExtern), perc: externPct, color: 'bg-secondary', dot: 'bg-secondary' },
                { label: 'Segment OLYBAT', value: fmt(caOlybat), perc: olybatPct, color: 'bg-amber-400', dot: 'bg-amber-400' },
              ].map((item, i) => (
                <div key={i} className="group">
                  <div className="flex justify-between items-center mb-2">
                    <div className="flex items-center gap-2">
                      <div className={`w-2 h-2 rounded-full ${item.dot}`} />
                      <span className="text-xs font-bold text-text-primary uppercase tracking-wide">{item.label}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-black text-text-primary">{item.value} MAD</span>
                      <span className="text-[10px] font-bold text-text-secondary">({item.perc}%)</span>
                    </div>
                  </div>
                  <div className="h-2.5 bg-slate-100 rounded-full overflow-hidden">
                    <div className={`h-full ${item.color} rounded-full transition-all duration-1000`} style={{ width: `${item.perc}%` }} />
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Recent Demandes */}
          <div className="bg-white rounded-premium shadow-sm border border-slate-50 overflow-hidden">
            <div className="flex items-center justify-between p-6 border-b border-slate-50">
              <h3 className="text-lg font-bold text-text-primary">Dernières Demandes</h3>
              <Link to="/demandes" className="flex items-center gap-1 text-[10px] font-bold text-primary uppercase tracking-widest hover:underline">
                Voir tout <ChevronRight size={12} />
              </Link>
            </div>
            <div className="divide-y divide-slate-50">
              {loadingDemandes
                ? Array.from({ length: 4 }).map((_, i) => (
                    <div key={i} className="flex items-center gap-4 px-6 py-4">
                      <div className="w-9 h-9 bg-slate-100 rounded-xl animate-pulse" />
                      <div className="flex-1 space-y-2">
                        <div className="h-3 w-32 bg-slate-100 rounded animate-pulse" />
                        <div className="h-3 w-48 bg-slate-100 rounded animate-pulse" />
                      </div>
                    </div>
                  ))
                : recentDemandes.map((dem) => {
                    const s = STATUS_MAP[dem.statut] ?? STATUS_MAP.nouvelle;
                    return (
                      <div key={dem.id} className="flex items-center gap-4 px-6 py-4 hover:bg-slate-50/50 transition-colors group cursor-pointer">
                        <div className="w-9 h-9 rounded-xl bg-slate-50 flex items-center justify-center shrink-0 group-hover:bg-primary/10 transition-colors">
                          <Package size={15} className="text-text-secondary group-hover:text-primary transition-colors" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2">
                            <span className="text-xs font-black text-primary">{dem.numero}</span>
                            <span className="text-[10px] text-text-secondary">·</span>
                            <span className="text-xs font-medium text-text-secondary truncate">{dem.typeLabel}</span>
                          </div>
                          <p className="text-sm font-bold text-text-primary mt-0.5 truncate">{dem.nomClient}</p>
                        </div>
                        <div className="flex items-center gap-3 shrink-0">
                          <span className={`px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider ${s.style}`}>
                            {s.label}
                          </span>
                          <span className="text-[10px] font-bold text-text-secondary whitespace-nowrap">{dem.createdAt}</span>
                        </div>
                      </div>
                    );
                  })
              }
            </div>
          </div>
        </div>

        {/* Side Widgets */}
        <div className="space-y-6">
          {/* Objective */}
          <div className="bg-white p-8 rounded-premium shadow-sm border border-slate-50">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-base font-bold text-text-primary">Objectif CA</h3>
              <Target size={18} className="text-primary" />
            </div>
            <div className="flex justify-center py-4">
              <div
                className="w-[130px] h-[130px] rounded-full flex items-center justify-center shadow-premium relative"
                style={{
                  background: `radial-gradient(closest-side, white 78%, transparent 79% 100%), conic-gradient(#003690 ${objectifPct}%, #F1F5F9 0)`,
                }}
              >
                <div className="flex flex-col items-center">
                  <span className="text-2xl font-black text-primary">{objectifPct}%</span>
                  <span className="text-[9px] text-text-secondary font-bold uppercase tracking-widest">Atteint</span>
                </div>
              </div>
            </div>
            <div className="text-center mt-4">
              <p className="text-sm font-bold text-text-primary">
                Objectif: <span className="text-primary">{fmt(objectif)} MAD</span>
              </p>
              <p className="text-xs text-text-secondary mt-1">
                Encore <span className="font-bold text-warning">{fmt(remaining)}</span> à réaliser
              </p>
            </div>
          </div>

          {/* Quick Stats */}
          <div className="bg-white p-6 rounded-premium shadow-sm border border-slate-50">
            <h3 className="text-base font-bold text-text-primary mb-5">Activité Rapide</h3>
            <div className="space-y-3">
              {[
                { icon: <AlertCircle size={14} className="text-warning" />, label: 'En attente validation', value: d?.demandes ?? 0, bg: 'bg-warning/10' },
                { icon: <Activity size={14} className="text-primary" />, label: 'Tâches en cours', value: d?.tachesEnCours ?? 0, bg: 'bg-primary/10' },
                { icon: <CheckCircle2 size={14} className="text-success" />, label: 'Visites du mois', value: d?.visites ?? 0, bg: 'bg-success/10' },
              ].map((item, i) => (
                <div key={i} className="flex items-center gap-3 p-3 rounded-xl bg-slate-50 hover:bg-white hover:shadow-sm border border-transparent hover:border-slate-100 transition-all cursor-pointer">
                  <div className={`w-8 h-8 ${item.bg} rounded-lg flex items-center justify-center shrink-0`}>{item.icon}</div>
                  <span className="text-xs font-medium text-text-secondary flex-1">{item.label}</span>
                  <span className="text-sm font-black text-text-primary">{item.value}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Top Performers */}
          <div className="bg-white p-6 rounded-premium shadow-sm border border-slate-50">
            <div className="flex justify-between items-center mb-5">
              <h3 className="text-base font-bold text-text-primary">Top Performers</h3>
              <Link to="/users" className="text-[10px] text-primary font-bold uppercase tracking-widest hover:underline">Voir tout</Link>
            </div>
            <div className="space-y-3">
              {(stats?.performers ?? []).map((p, i) => {
                const perc = p.objectif > 0 ? `${Math.round((p.caVal / p.objectif) * 100)}%` : '0%';
                const colors = ['bg-blue-50 text-blue-700', 'bg-green-50 text-green-700', 'bg-amber-50 text-amber-700'];
                const color = p.color ?? colors[i] ?? colors[0];
                return (
                  <div key={i} className="flex items-center gap-3 p-3 rounded-xl bg-slate-50 hover:bg-white hover:shadow-sm border border-transparent hover:border-primary/10 hover:translate-x-0.5 transition-all cursor-pointer">
                    <div className={`w-9 h-9 rounded-xl ${color} flex items-center justify-center font-bold text-xs shrink-0`}>{p.avatar}</div>
                    <div className="flex-1 min-w-0">
                      <p className="text-xs font-bold text-text-primary group-hover:text-primary transition-colors truncate">{p.name}</p>
                      <p className="text-[10px] text-text-secondary">{p.zone}</p>
                    </div>
                    <div className="text-right shrink-0">
                      <p className="text-xs font-black text-text-primary">{perc}</p>
                      <p className="text-[10px] font-bold text-primary">{p.ca}</p>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardView;
