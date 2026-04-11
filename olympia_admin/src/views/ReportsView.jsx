import React, { useState } from 'react';
import {
  TrendingUp, TrendingDown, BarChart2, Download, Calendar,
  ArrowUpRight, ArrowDownRight, Target, Users, ClipboardList,
  CheckCircle2, Package, Wrench, Star
} from 'lucide-react';

const PERIODS = [
  { label: 'Ce mois', value: 'month' },
  { label: 'Ce trimestre', value: 'quarter' },
  { label: 'Cette année', value: 'year' },
];

const DATA = {
  month: {
    caTotal: '125 000',
    caTrend: +12.4,
    caIntern: 45000,
    caExtern: 55000,
    caOlybat: 25000,
    visites: 34,
    visiteTrend: +8,
    taches: 12,
    tacheTrend: -2,
    demandes: 24,
    demandeTrend: +6,
    tauxValidation: 75,
    performers: [
      { name: 'Taha Mejdoub', zone: 'Casablanca Nord', ca: '52K', perc: 92, avatar: 'TM', color: 'bg-blue-50 text-blue-700' },
      { name: 'Ahmed Salhi', zone: 'Rabat Centre', ca: '43K', perc: 84, avatar: 'AS', color: 'bg-green-50 text-green-700' },
      { name: 'Yassine Rachidi', zone: 'Marrakech', ca: '30K', perc: 68, avatar: 'YR', color: 'bg-amber-50 text-amber-700' },
    ],
    demandesByType: [
      { type: 'Échantillons', count: 8, perc: 33 },
      { type: 'Réclamation', count: 5, perc: 21 },
      { type: 'Nouveau Client', count: 4, perc: 17 },
      { type: 'Formation', count: 3, perc: 12 },
      { type: 'Autres', count: 4, perc: 17 },
    ],
    monthlyCA: [
      { month: 'Oct', value: 98 },
      { month: 'Nov', value: 112 },
      { month: 'Déc', value: 89 },
      { month: 'Jan', value: 104 },
      { month: 'Fév', value: 118 },
      { month: 'Mar', value: 125 },
    ],
  },
  quarter: {
    caTotal: '330 000',
    caTrend: +9.1,
    caIntern: 120000,
    caExtern: 145000,
    caOlybat: 65000,
    visites: 98,
    visiteTrend: +14,
    taches: 34,
    tacheTrend: +5,
    demandes: 72,
    demandeTrend: +18,
    tauxValidation: 78,
    performers: [
      { name: 'Taha Mejdoub', zone: 'Casablanca Nord', ca: '142K', perc: 90, avatar: 'TM', color: 'bg-blue-50 text-blue-700' },
      { name: 'Ahmed Salhi', zone: 'Rabat Centre', ca: '118K', perc: 82, avatar: 'AS', color: 'bg-green-50 text-green-700' },
      { name: 'Yassine Rachidi', zone: 'Marrakech', ca: '70K', perc: 65, avatar: 'YR', color: 'bg-amber-50 text-amber-700' },
    ],
    demandesByType: [
      { type: 'Échantillons', count: 22, perc: 31 },
      { type: 'Réclamation', count: 15, perc: 21 },
      { type: 'Nouveau Client', count: 14, perc: 19 },
      { type: 'Formation', count: 11, perc: 15 },
      { type: 'Autres', count: 10, perc: 14 },
    ],
    monthlyCA: [
      { month: 'Jan', value: 104 },
      { month: 'Fév', value: 118 },
      { month: 'Mar', value: 125 },
      { month: 'Avr', value: 110 },
      { month: 'Mai', value: 132 },
      { month: 'Juin', value: 141 },
    ],
  },
  year: {
    caTotal: '1 280 000',
    caTrend: +22.5,
    caIntern: 460000,
    caExtern: 540000,
    caOlybat: 280000,
    visites: 412,
    visiteTrend: +32,
    taches: 148,
    tacheTrend: +21,
    demandes: 284,
    demandeTrend: +45,
    tauxValidation: 81,
    performers: [
      { name: 'Taha Mejdoub', zone: 'Casablanca Nord', ca: '530K', perc: 94, avatar: 'TM', color: 'bg-blue-50 text-blue-700' },
      { name: 'Ahmed Salhi', zone: 'Rabat Centre', ca: '455K', perc: 86, avatar: 'AS', color: 'bg-green-50 text-green-700' },
      { name: 'Yassine Rachidi', zone: 'Marrakech', ca: '295K', perc: 70, avatar: 'YR', color: 'bg-amber-50 text-amber-700' },
    ],
    demandesByType: [
      { type: 'Échantillons', count: 88, perc: 31 },
      { type: 'Réclamation', count: 62, perc: 22 },
      { type: 'Nouveau Client', count: 55, perc: 19 },
      { type: 'Formation', count: 44, perc: 16 },
      { type: 'Autres', count: 35, perc: 12 },
    ],
    monthlyCA: [
      { month: 'Jan', value: 88 },
      { month: 'Fév', value: 95 },
      { month: 'Mar', value: 102 },
      { month: 'Avr', value: 98 },
      { month: 'Mai', value: 115 },
      { month: 'Juin', value: 128 },
      { month: 'Juil', value: 108 },
      { month: 'Aoû', value: 92 },
      { month: 'Sep', value: 118 },
      { month: 'Oct', value: 132 },
      { month: 'Nov', value: 145 },
      { month: 'Déc', value: 159 },
    ],
  },
};

const StatCard = ({ icon, label, value, trend, unit = '' }) => {
  const isPositive = trend >= 0;
  return (
    <div className="bg-white p-6 rounded-premium shadow-sm border border-slate-50 hover:shadow-md hover:-translate-y-0.5 transition-all group">
      <div className="flex justify-between items-start mb-4">
        <div className="p-3 rounded-xl bg-slate-50 group-hover:bg-background transition-colors">
          {icon}
        </div>
        <span className={`text-xs font-bold flex items-center gap-1 px-2.5 py-1 rounded-full ${isPositive ? 'text-success bg-success/10' : 'text-error bg-red-50'}`}>
          {isPositive ? <ArrowUpRight size={12} /> : <ArrowDownRight size={12} />}
          {Math.abs(trend)}{typeof trend === 'number' && trend > 10 ? '%' : ''}
        </span>
      </div>
      <p className="text-xs font-bold text-text-secondary uppercase tracking-widest mb-1">{label}</p>
      <p className="text-2xl font-black text-text-primary">{value}<span className="text-sm font-medium text-text-secondary ml-1">{unit}</span></p>
    </div>
  );
};

const ReportsView = () => {
  const [period, setPeriod] = useState('month');
  const d = DATA[period];

  const totalCA = d.caIntern + d.caExtern + d.caOlybat;
  const segments = [
    { label: 'Segment INTERN', value: d.caIntern, color: 'bg-primary', textColor: 'text-primary', lightBg: 'bg-primary/10' },
    { label: 'Segment EXTERN', value: d.caExtern, color: 'bg-secondary', textColor: 'text-secondary', lightBg: 'bg-secondary/10' },
    { label: 'Segment OLYBAT', value: d.caOlybat, color: 'bg-amber-400', textColor: 'text-amber-600', lightBg: 'bg-amber-50' },
  ];

  const maxBarValue = Math.max(...d.monthlyCA.map(m => m.value));

  return (
    <div className="max-w-[1400px] mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h1 className="text-3xl font-black text-text-primary tracking-tight mb-2">Rapports & Analyses</h1>
          <p className="text-text-secondary font-medium">Vue consolidée des performances commerciales de l'équipe.</p>
        </div>
        <div className="flex items-center gap-3">
          {/* Period Selector */}
          <div className="flex items-center gap-1 bg-white p-1.5 rounded-xl border border-slate-100 shadow-sm">
            {PERIODS.map(p => (
              <button
                key={p.value}
                onClick={() => setPeriod(p.value)}
                className={`px-4 py-2 rounded-lg text-xs font-bold transition-all ${
                  period === p.value ? 'bg-primary text-white shadow-sm shadow-primary/20' : 'text-text-secondary hover:text-text-primary'
                }`}
              >
                {p.label}
              </button>
            ))}
          </div>
          <button className="flex items-center gap-2 px-4 py-2.5 bg-white border border-slate-100 text-text-secondary rounded-xl text-xs font-bold hover:text-primary hover:border-primary/20 transition-all shadow-sm">
            <Download size={14} />
            Exporter
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-5">
        <StatCard
          icon={<TrendingUp size={20} className="text-primary" />}
          label="CA Global"
          value={d.caTotal}
          trend={d.caTrend}
          unit="MAD"
        />
        <StatCard
          icon={<Users size={20} className="text-secondary" />}
          label="Visites Client"
          value={d.visites}
          trend={d.visiteTrend}
          unit="visites"
        />
        <StatCard
          icon={<CheckCircle2 size={20} className="text-success" />}
          label="Tâches Réalisées"
          value={d.taches}
          trend={d.tacheTrend}
        />
        <StatCard
          icon={<ClipboardList size={20} className="text-warning" />}
          label="Demandes Traitées"
          value={d.demandes}
          trend={d.demandeTrend}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-[1.5fr_1fr] gap-8">
        {/* CA Evolution Chart */}
        <div className="bg-white p-8 rounded-premium shadow-sm border border-slate-50">
          <div className="flex justify-between items-center mb-8">
            <div>
              <h3 className="text-lg font-bold text-text-primary">Évolution du CA</h3>
              <p className="text-xs text-text-secondary mt-1">Chiffre d'affaires en milliers (MAD)</p>
            </div>
            <div className="flex items-center gap-2 text-xs font-bold text-success bg-success/10 px-3 py-1.5 rounded-full">
              <TrendingUp size={12} />
              +{d.caTrend}%
            </div>
          </div>

          {/* Bar Chart */}
          <div className="flex items-end gap-3 h-[160px]">
            {d.monthlyCA.map((m, i) => {
              const heightPct = (m.value / maxBarValue) * 100;
              const isLast = i === d.monthlyCA.length - 1;
              return (
                <div key={i} className="flex-1 flex flex-col items-center gap-2 group">
                  <div className="w-full flex flex-col justify-end" style={{ height: '130px' }}>
                    <div
                      className={`w-full rounded-t-lg transition-all duration-700 relative ${isLast ? 'bg-primary shadow-lg shadow-primary/20' : 'bg-slate-100 group-hover:bg-primary/30'}`}
                      style={{ height: `${heightPct}%` }}
                    >
                      <div className="absolute -top-7 left-1/2 -translate-x-1/2 text-[10px] font-bold text-text-secondary opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">
                        {m.value}K
                      </div>
                    </div>
                  </div>
                  <span className={`text-[10px] font-bold uppercase tracking-wide ${isLast ? 'text-primary' : 'text-text-secondary'}`}>
                    {m.month}
                  </span>
                </div>
              );
            })}
          </div>
        </div>

        {/* CA by Segment */}
        <div className="bg-white p-8 rounded-premium shadow-sm border border-slate-50">
          <h3 className="text-lg font-bold text-text-primary mb-2">Répartition par Segment</h3>
          <p className="text-xs text-text-secondary mb-8">Total: <span className="font-bold text-text-primary">{d.caTotal} MAD</span></p>

          <div className="space-y-5">
            {segments.map((seg, i) => {
              const pct = Math.round((seg.value / totalCA) * 100);
              return (
                <div key={i}>
                  <div className="flex justify-between items-center mb-2">
                    <div className="flex items-center gap-2">
                      <div className={`w-2.5 h-2.5 rounded-full ${seg.color}`}></div>
                      <span className="text-xs font-bold text-text-primary">{seg.label}</span>
                    </div>
                    <div className="text-right">
                      <span className="text-xs font-black text-text-primary">{(seg.value / 1000).toFixed(0)}K</span>
                      <span className="text-[10px] text-text-secondary ml-1">({pct}%)</span>
                    </div>
                  </div>
                  <div className="h-2.5 bg-slate-100 rounded-full overflow-hidden">
                    <div
                      className={`h-full ${seg.color} rounded-full transition-all duration-1000`}
                      style={{ width: `${pct}%` }}
                    ></div>
                  </div>
                </div>
              );
            })}
          </div>

          {/* Taux validation */}
          <div className="mt-8 p-4 bg-slate-50 rounded-xl border border-slate-100">
            <div className="flex justify-between items-center mb-2">
              <span className="text-xs font-bold text-text-secondary uppercase tracking-widest">Taux de validation</span>
              <span className="text-sm font-black text-success">{d.tauxValidation}%</span>
            </div>
            <div className="h-2 bg-slate-200 rounded-full overflow-hidden">
              <div
                className="h-full bg-success rounded-full transition-all duration-1000"
                style={{ width: `${d.tauxValidation}%` }}
              ></div>
            </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-[1fr_1.2fr] gap-8">
        {/* Demandes by Type */}
        <div className="bg-white p-8 rounded-premium shadow-sm border border-slate-50">
          <h3 className="text-lg font-bold text-text-primary mb-2">Demandes par Type</h3>
          <p className="text-xs text-text-secondary mb-6">Répartition des {d.demandes} demandes traitées</p>

          <div className="space-y-4">
            {d.demandesByType.map((item, i) => (
              <div key={i} className="flex items-center gap-4 group">
                <div className="w-8 h-8 rounded-lg bg-slate-50 flex items-center justify-center shrink-0 group-hover:bg-primary/10 transition-colors">
                  <Package size={14} className="text-text-secondary group-hover:text-primary transition-colors" />
                </div>
                <div className="flex-1">
                  <div className="flex justify-between items-center mb-1.5">
                    <span className="text-xs font-bold text-text-primary">{item.type}</span>
                    <span className="text-xs font-black text-text-secondary">{item.count}</span>
                  </div>
                  <div className="h-1.5 bg-slate-100 rounded-full overflow-hidden">
                    <div
                      className="h-full bg-gradient-to-r from-primary to-secondary rounded-full transition-all duration-700"
                      style={{ width: `${item.perc}%` }}
                    ></div>
                  </div>
                </div>
                <span className="text-[10px] font-bold text-text-secondary w-8 text-right">{item.perc}%</span>
              </div>
            ))}
          </div>
        </div>

        {/* Top Performers */}
        <div className="bg-white p-8 rounded-premium shadow-sm border border-slate-50">
          <div className="flex justify-between items-center mb-6">
            <div>
              <h3 className="text-lg font-bold text-text-primary">Top Performers</h3>
              <p className="text-xs text-text-secondary mt-1">Classement par CA réalisé</p>
            </div>
            <div className="p-2 bg-amber-50 rounded-xl">
              <Star size={18} className="text-amber-500" />
            </div>
          </div>

          <div className="space-y-3">
            {d.performers.map((p, i) => (
              <div key={i} className="flex items-center gap-4 p-4 rounded-xl bg-slate-50 hover:bg-white hover:shadow-sm border border-transparent hover:border-slate-100 transition-all group cursor-pointer">
                <div className="w-7 h-7 rounded-full flex items-center justify-center text-xs font-black shrink-0"
                  style={{ background: i === 0 ? '#F59E0B' : i === 1 ? '#94A3B8' : '#C084FC', color: 'white' }}>
                  {i + 1}
                </div>
                <div className={`w-10 h-10 rounded-xl ${p.color} flex items-center justify-center text-sm font-black shrink-0`}>
                  {p.avatar}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-bold text-text-primary group-hover:text-primary transition-colors truncate">{p.name}</p>
                  <p className="text-[10px] font-medium text-text-secondary tracking-wide">{p.zone}</p>
                </div>
                <div className="text-right shrink-0">
                  <p className="text-sm font-black text-text-primary">{p.ca}</p>
                  <p className="text-[10px] font-bold text-success">{p.perc}% obj.</p>
                </div>
              </div>
            ))}
          </div>

          {/* Objectif global */}
          <div className="mt-6 pt-6 border-t border-slate-50">
            <div className="flex justify-between items-center mb-3">
              <div>
                <p className="text-xs font-bold text-text-primary">Objectif Global Équipe</p>
                <p className="text-[10px] text-text-secondary mt-0.5">500 000 MAD</p>
              </div>
              <div className="flex items-center gap-2 text-primary">
                <Target size={16} />
                <span className="text-sm font-black">{Math.round((parseFloat(d.caTotal.replace(/\s/g, '')) / 500000) * 100)}%</span>
              </div>
            </div>
            <div className="h-2 bg-slate-100 rounded-full overflow-hidden">
              <div
                className="h-full bg-gradient-to-r from-primary to-secondary rounded-full transition-all duration-1000"
                style={{ width: `${Math.min(Math.round((parseFloat(d.caTotal.replace(/\s/g, '')) / 500000) * 100), 100)}%` }}
              ></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ReportsView;
