import React, { useState } from 'react';
import {
  TrendingUp, Users, ClipboardList, CheckCircle2,
  ArrowUpRight, ArrowDownRight, MoreHorizontal,
  Calendar, Target, Activity, Clock, ChevronRight,
  Package, Wrench, UserCheck, AlertCircle
} from 'lucide-react';

const PERIODS = [
  { label: 'Ce mois', value: 'month' },
  { label: 'Ce trimestre', value: 'quarter' },
];

const DATA = {
  month: {
    ca: '125K', caTrend: +12.4,
    demandes: 6, demandesTrend: +2,
    taches: 8, tachesTrend: -1,
    visites: 12, visitesTrend: +3,
    caIntern: 36, caExtern: 44, caOlybat: 20,
    caInternVal: '45K', caExternVal: '55K', caOlybatVal: '25K',
    objectifPct: 68,
    objectifRemaining: '160K',
  },
  quarter: {
    ca: '330K', caTrend: +9.1,
    demandes: 24, demandesTrend: +8,
    taches: 34, tachesTrend: +5,
    visites: 98, visitesTrend: +14,
    caIntern: 36, caExtern: 44, caOlybat: 20,
    caInternVal: '120K', caExternVal: '145K', caOlybatVal: '65K',
    objectifPct: 44,
    objectifRemaining: '620K',
  },
};

const recentDemandes = [
  { id: 'DEM-2024-001', client: 'Brico Déco SARL', type: 'Échantillons', status: 'nouvelle', time: 'Il y a 2h' },
  { id: 'DEM-2024-002', client: 'Atlas Construction', type: 'Réclamation', status: 'en_cours_validation', time: 'Il y a 4h' },
  { id: 'DEM-2024-003', client: 'Global Build SA', type: 'Nouveau Client', status: 'validee', time: 'Hier 16:45' },
  { id: 'DEM-2024-004', client: 'Immo Prestige', type: 'Formation', status: 'refusee', time: 'Hier 10:20' },
];

const performers = [
  { name: 'Taha Mejdoub', zone: 'Casablanca Nord', perc: '92%', avatar: 'TM', color: 'bg-blue-50 text-blue-700', trend: '+8%' },
  { name: 'Ahmed Salhi', zone: 'Rabat Centre', perc: '84%', avatar: 'AS', color: 'bg-green-50 text-green-700', trend: '+4%' },
  { name: 'Yassine Rachidi', zone: 'Marrakech', perc: '68%', avatar: 'YR', color: 'bg-amber-50 text-amber-700', trend: '+12%' },
];

const STATUS_MAP = {
  nouvelle: { label: 'Nouvelle', style: 'bg-blue-50 text-blue-600' },
  en_cours_validation: { label: 'En validation', style: 'bg-amber-50 text-amber-600' },
  validee: { label: 'Validée', style: 'bg-success/10 text-success' },
  refusee: { label: 'Refusée', style: 'bg-red-50 text-error' },
  en_cours_traitement: { label: 'En traitement', style: 'bg-yellow-50 text-yellow-700' },
  traitee: { label: 'Traitée', style: 'bg-emerald-50 text-emerald-700' },
  cloturee: { label: 'Clôturée', style: 'bg-slate-100 text-text-secondary' },
};

const DashboardView = () => {
  const [period, setPeriod] = useState('month');
  const d = DATA[period];

  const stats = [
    {
      title: 'CA Global',
      value: d.ca + ' MAD',
      trend: d.caTrend,
      icon: <TrendingUp size={20} className="text-primary" />,
      bg: 'bg-primary/10',
    },
    {
      title: 'Demandes Actives',
      value: d.demandes + ' nouvelles',
      trend: d.demandesTrend,
      icon: <ClipboardList size={20} className="text-secondary" />,
      bg: 'bg-secondary/10',
    },
    {
      title: 'Tâches ce mois',
      value: d.taches + ' tâches',
      trend: d.tachesTrend,
      icon: <CheckCircle2 size={20} className="text-success" />,
      bg: 'bg-success/10',
    },
    {
      title: 'Visites Clients',
      value: d.visites + ' visites',
      trend: d.visitesTrend,
      icon: <UserCheck size={20} className="text-warning" />,
      bg: 'bg-warning/10',
    },
  ];

  return (
    <div className="max-w-[1400px] mx-auto animate-in fade-in slide-in-from-bottom-4 duration-700 space-y-8">
      {/* Welcome Section */}
      <div className="p-10 rounded-premium bg-gradient-to-r from-primary to-primary-dark text-white relative overflow-hidden shadow-premium">
        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div className="max-w-[550px]">
            <div className="inline-flex items-center gap-2 bg-white/15 backdrop-blur-sm px-3 py-1.5 rounded-full mb-4">
              <div className="w-1.5 h-1.5 bg-green-400 rounded-full animate-pulse"></div>
              <span className="text-white/80 text-[10px] font-bold uppercase tracking-widest">Système actif</span>
            </div>
            <h1 className="text-3xl font-black mb-2 leading-tight tracking-tight">Bonjour, Jason Ranti !</h1>
            <p className="text-white/70 text-sm font-medium leading-relaxed">
              Voici un aperçu en temps réel des performances Olympia. {d.demandes} demandes attendent votre validation.
            </p>
          </div>

          {/* Quick stats */}
          <div className="flex items-center gap-4 shrink-0">
            <div className="bg-white/15 backdrop-blur-sm rounded-2xl p-4 border border-white/10 text-center min-w-[90px]">
              <p className="text-2xl font-black text-white">{d.demandes}</p>
              <p className="text-white/60 text-[10px] font-bold uppercase tracking-widest mt-1">À valider</p>
            </div>
            <div className="bg-white/15 backdrop-blur-sm rounded-2xl p-4 border border-white/10 text-center min-w-[90px]">
              <p className="text-2xl font-black text-white">{d.visites}</p>
              <p className="text-white/60 text-[10px] font-bold uppercase tracking-widest mt-1">Visites</p>
            </div>
          </div>
        </div>
        <div className="absolute right-[-60px] top-[-60px] w-[280px] h-[280px] bg-white/10 rounded-full blur-3xl"></div>
        <div className="absolute right-[100px] bottom-[-40px] w-[200px] h-[200px] bg-white/5 rounded-full blur-3xl"></div>
      </div>

      {/* Period selector */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-1 bg-white p-1 rounded-xl border border-slate-100 shadow-sm">
          {PERIODS.map(p => (
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
          <span>Mis à jour il y a 5 min</span>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-5">
        {stats.map((stat, i) => {
          const isPos = stat.trend >= 0;
          return (
            <div key={i} className="bg-white p-6 rounded-premium shadow-sm border border-slate-50 hover:shadow-md hover:-translate-y-0.5 transition-all group">
              <div className="flex justify-between items-start mb-4">
                <div className={`p-3 ${stat.bg} rounded-xl`}>
                  {stat.icon}
                </div>
                <span className={`text-[10px] font-bold flex items-center gap-0.5 px-2 py-1 rounded-full ${isPos ? 'text-success bg-success/10' : 'text-error bg-red-50'}`}>
                  {isPos ? <ArrowUpRight size={10} /> : <ArrowDownRight size={10} />}
                  {Math.abs(stat.trend)}%
                </span>
              </div>
              <p className="text-[10px] font-bold text-text-secondary uppercase tracking-widest mb-1">{stat.title}</p>
              <p className="text-xl font-black text-text-primary">{stat.value}</p>
            </div>
          );
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-[1fr_340px] gap-8">
        {/* Main Content */}
        <div className="space-y-8">
          {/* CA Segments */}
          <div className="bg-white p-8 rounded-premium shadow-sm border border-slate-50">
            <div className="flex justify-between items-center mb-8">
              <div>
                <h3 className="text-lg font-bold text-text-primary">Répartition CA par Segment</h3>
                <p className="text-xs text-text-secondary mt-1">Total: <span className="font-bold text-text-primary">{d.ca} MAD</span></p>
              </div>
              <button className="p-2 rounded-xl hover:bg-slate-50 transition-colors">
                <MoreHorizontal size={20} className="text-text-secondary" />
              </button>
            </div>
            <div className="space-y-5">
              {[
                { label: 'Segment INTERN', value: d.caInternVal, perc: d.caIntern, color: 'bg-primary', dot: 'bg-primary' },
                { label: 'Segment EXTERN', value: d.caExternVal, perc: d.caExtern, color: 'bg-secondary', dot: 'bg-secondary' },
                { label: 'Segment OLYBAT', value: d.caOlybatVal, perc: d.caOlybat, color: 'bg-amber-400', dot: 'bg-amber-400' },
              ].map((item, i) => (
                <div key={i} className="group">
                  <div className="flex justify-between items-center mb-2">
                    <div className="flex items-center gap-2">
                      <div className={`w-2 h-2 rounded-full ${item.dot}`}></div>
                      <span className="text-xs font-bold text-text-primary uppercase tracking-wide">{item.label}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-black text-text-primary">{item.value} MAD</span>
                      <span className="text-[10px] font-bold text-text-secondary">({item.perc}%)</span>
                    </div>
                  </div>
                  <div className="h-2.5 bg-slate-100 rounded-full overflow-hidden">
                    <div
                      className={`h-full ${item.color} rounded-full transition-all duration-1000 group-hover:opacity-80`}
                      style={{ width: `${item.perc}%` }}
                    ></div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Recent Demandes */}
          <div className="bg-white rounded-premium shadow-sm border border-slate-50 overflow-hidden">
            <div className="flex items-center justify-between p-6 border-b border-slate-50">
              <h3 className="text-lg font-bold text-text-primary">Dernières Demandes</h3>
              <a href="/demandes" className="flex items-center gap-1 text-[10px] font-bold text-primary uppercase tracking-widest hover:underline">
                Voir tout <ChevronRight size={12} />
              </a>
            </div>
            <div className="divide-y divide-slate-50">
              {recentDemandes.map((dem) => {
                const s = STATUS_MAP[dem.status];
                return (
                  <div key={dem.id} className="flex items-center gap-4 px-6 py-4 hover:bg-slate-50/50 transition-colors group cursor-pointer">
                    <div className="w-9 h-9 rounded-xl bg-slate-50 flex items-center justify-center shrink-0 group-hover:bg-primary/10 transition-colors">
                      <Package size={15} className="text-text-secondary group-hover:text-primary transition-colors" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-black text-primary">{dem.id}</span>
                        <span className="text-[10px] text-text-secondary">·</span>
                        <span className="text-xs font-medium text-text-secondary truncate">{dem.type}</span>
                      </div>
                      <p className="text-sm font-bold text-text-primary mt-0.5 truncate">{dem.client}</p>
                    </div>
                    <div className="flex items-center gap-3 shrink-0">
                      <span className={`px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider ${s.style}`}>
                        {s.label}
                      </span>
                      <span className="text-[10px] font-bold text-text-secondary whitespace-nowrap">{dem.time}</span>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        {/* Side Widgets */}
        <div className="space-y-6">
          {/* Objective */}
          <div className="bg-white p-8 rounded-premium shadow-sm border border-slate-50">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-base font-bold text-text-primary">Objectif Mensuel</h3>
              <Target size={18} className="text-primary" />
            </div>
            <div className="flex justify-center py-4">
              <div
                className="w-[130px] h-[130px] rounded-full flex items-center justify-center shadow-premium relative"
                style={{
                  background: `radial-gradient(closest-side, white 78%, transparent 79% 100%), conic-gradient(#4278A1 ${d.objectifPct}%, #F1F5F9 0)`,
                }}
              >
                <div className="flex flex-col items-center">
                  <span className="text-2xl font-black text-primary">{d.objectifPct}%</span>
                  <span className="text-[9px] text-text-secondary font-bold uppercase tracking-widest">Atteint</span>
                </div>
              </div>
            </div>
            <div className="text-center mt-4">
              <p className="text-sm font-bold text-text-primary">
                Objectif: <span className="text-primary">500K MAD</span>
              </p>
              <p className="text-xs text-text-secondary mt-1">Encore <span className="font-bold text-warning">{d.objectifRemaining}</span> à réaliser</p>
            </div>
          </div>

          {/* Quick Stats */}
          <div className="bg-white p-6 rounded-premium shadow-sm border border-slate-50">
            <h3 className="text-base font-bold text-text-primary mb-5">Activité Rapide</h3>
            <div className="space-y-3">
              {[
                { icon: <AlertCircle size={14} className="text-warning" />, label: 'En attente validation', value: d.demandes, bg: 'bg-warning/10' },
                { icon: <Activity size={14} className="text-primary" />, label: 'Tâches en cours', value: Math.floor(d.taches * 0.4), bg: 'bg-primary/10' },
                { icon: <Clock size={14} className="text-error" />, label: 'Tâches en retard', value: 2, bg: 'bg-red-50' },
              ].map((item, i) => (
                <div key={i} className="flex items-center gap-3 p-3 rounded-xl bg-slate-50 hover:bg-white hover:shadow-sm border border-transparent hover:border-slate-100 transition-all group cursor-pointer">
                  <div className={`w-8 h-8 ${item.bg} rounded-lg flex items-center justify-center shrink-0`}>
                    {item.icon}
                  </div>
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
              <button className="text-[10px] text-primary font-bold uppercase tracking-widest hover:underline">Voir tout</button>
            </div>
            <div className="space-y-3">
              {performers.map((p, i) => (
                <div key={i} className="flex items-center gap-3 p-3 rounded-xl bg-slate-50 hover:bg-white hover:shadow-sm border border-transparent hover:border-primary/10 hover:translate-x-0.5 transition-all group cursor-pointer">
                  <div className={`w-9 h-9 rounded-xl ${p.color} flex items-center justify-center font-bold text-xs shrink-0`}>
                    {p.avatar}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs font-bold text-text-primary group-hover:text-primary transition-colors truncate">{p.name}</p>
                    <p className="text-[10px] text-text-secondary">{p.zone}</p>
                  </div>
                  <div className="text-right shrink-0">
                    <p className="text-xs font-black text-text-primary">{p.perc}</p>
                    <p className="text-[10px] font-bold text-success">{p.trend}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardView;
