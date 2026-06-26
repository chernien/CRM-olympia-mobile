import React, { useState, useEffect } from 'react';
import {
  TrendingUp, TrendingDown, BarChart2, Download, Calendar,
  ArrowUpRight, ArrowDownRight, Target, Users, ClipboardList,
  CheckCircle2, Package, Wrench, Star
} from 'lucide-react';
import { Services } from '../services/index.js';

const PERIODS = [
  { label: 'Ce mois', value: 'month' },
  { label: 'Ce trimestre', value: 'quarter' },
  { label: 'Cette année', value: 'year' },
];

function fmt(val) {
  if (val >= 1_000_000) return `${(val / 1_000_000).toFixed(1)}M`;
  if (val >= 1_000) return `${Math.round(val / 1_000)}K`;
  return String(val);
}

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
          {Math.abs(trend)}%
        </span>
      </div>
      <p className="text-xs font-bold text-text-secondary uppercase tracking-widest mb-1">{label}</p>
      <p className="text-2xl font-black text-text-primary">{value}<span className="text-sm font-medium text-text-secondary ml-1">{unit}</span></p>
    </div>
  );
};

const SkeletonCard = () => (
  <div className="bg-white p-6 rounded-premium shadow-sm border border-slate-50 animate-pulse">
    <div className="h-10 w-10 bg-slate-100 rounded-xl mb-4" />
    <div className="h-3 w-24 bg-slate-100 rounded mb-3" />
    <div className="h-7 w-32 bg-slate-100 rounded" />
  </div>
);

const ReportsView = () => {
  const [period, setPeriod] = useState('month');
  const [stats, setStats] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    setIsLoading(true);
    setError(null);
    Services.dashboard.getStats(period).then(({ data, error: err }) => {
      if (err) setError(err);
      else setStats(data);
      setIsLoading(false);
    });
  }, [period]);

  const d = stats;

  const totalCA = d ? d.caIntern + d.caExtern + d.caOlybat : 0;
  const segments = d ? [
    { label: 'Segment INTERN', value: d.caIntern, color: 'bg-primary', textColor: 'text-primary', lightBg: 'bg-primary/10' },
    { label: 'Segment EXTERN', value: d.caExtern, color: 'bg-secondary', textColor: 'text-secondary', lightBg: 'bg-secondary/10' },
    { label: 'Segment OLYBAT', value: d.caOlybat, color: 'bg-amber-400', textColor: 'text-amber-600', lightBg: 'bg-amber-50' },
  ] : [];

  const monthlyCA = d ? d.caPoints.map(p => ({ month: p.label, value: Math.round(p.value / 1000) })) : [];
  const maxBarValue = monthlyCA.length ? Math.max(...monthlyCA.map(m => m.value)) : 1;

  const performers = d ? d.performers.map(p => ({
    ...p,
    perc: Math.round((p.caVal / p.objectif) * 100),
  })) : [];

  const globalObjPct = d ? Math.min(Math.round((d.ca / 500000) * 100), 100) : 0;

  return (
    <div className="max-w-[1400px] mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h1 className="text-3xl font-black text-text-primary tracking-tight mb-2">Rapports & Analyses</h1>
          <p className="text-text-secondary font-medium">Vue consolidée des performances commerciales de l'équipe.</p>
        </div>
        <div className="flex items-center gap-3">
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

      {error && (
        <div className="p-4 bg-red-50 border border-red-100 rounded-xl text-sm text-error font-medium">
          Erreur lors du chargement des données. Veuillez réessayer.
        </div>
      )}

      {/* KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-5">
        {isLoading ? (
          Array(4).fill(0).map((_, i) => <SkeletonCard key={i} />)
        ) : d ? (
          <>
            <StatCard icon={<TrendingUp size={20} className="text-primary" />} label="CA Global" value={fmt(d.ca)} trend={d.caTrend} unit="MAD" />
            <StatCard icon={<Users size={20} className="text-secondary" />} label="Visites Client" value={d.visites} trend={d.visitesTrend} unit="visites" />
            <StatCard icon={<CheckCircle2 size={20} className="text-success" />} label="Tâches Réalisées" value={d.taches} trend={d.tachesTrend} />
            <StatCard icon={<ClipboardList size={20} className="text-warning" />} label="Demandes Traitées" value={d.demandes} trend={d.demandesTrend} />
          </>
        ) : null}
      </div>

      {!isLoading && d && (
        <>
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

              <div className="flex items-end gap-3 h-[160px]">
                {monthlyCA.map((m, i) => {
                  const heightPct = (m.value / maxBarValue) * 100;
                  const isLast = i === monthlyCA.length - 1;
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
              <p className="text-xs text-text-secondary mb-8">Total: <span className="font-bold text-text-primary">{fmt(d.ca)} MAD</span></p>

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
                          <span className="text-xs font-black text-text-primary">{Math.round(seg.value / 1000)}K</span>
                          <span className="text-[10px] text-text-secondary ml-1">({pct}%)</span>
                        </div>
                      </div>
                      <div className="h-2.5 bg-slate-100 rounded-full overflow-hidden">
                        <div className={`h-full ${seg.color} rounded-full transition-all duration-1000`} style={{ width: `${pct}%` }}></div>
                      </div>
                    </div>
                  );
                })}
              </div>

              <div className="mt-8 p-4 bg-slate-50 rounded-xl border border-slate-100">
                <div className="flex justify-between items-center mb-2">
                  <span className="text-xs font-bold text-text-secondary uppercase tracking-widest">Objectif atteint</span>
                  <span className="text-sm font-black text-primary">{globalObjPct}%</span>
                </div>
                <div className="h-2 bg-slate-200 rounded-full overflow-hidden">
                  <div className="h-full bg-primary rounded-full transition-all duration-1000" style={{ width: `${globalObjPct}%` }}></div>
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
                        <span className="text-xs font-bold text-text-primary">{item.typeLabel ?? item.type}</span>
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
                {performers.map((p, i) => (
                  <div key={i} className="flex items-center gap-4 p-4 rounded-xl bg-slate-50 hover:bg-white hover:shadow-sm border border-transparent hover:border-slate-100 transition-all group cursor-pointer">
                    <div
                      className="w-7 h-7 rounded-full flex items-center justify-center text-xs font-black shrink-0"
                      style={{ background: i === 0 ? '#F59E0B' : i === 1 ? '#94A3B8' : '#C084FC', color: 'white' }}
                    >
                      {i + 1}
                    </div>
                    <div className={`w-10 h-10 rounded-xl ${p.color ?? 'bg-primary/10 text-primary'} flex items-center justify-center text-sm font-black shrink-0`}>
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

              <div className="mt-6 pt-6 border-t border-slate-50">
                <div className="flex justify-between items-center mb-3">
                  <div>
                    <p className="text-xs font-bold text-text-primary">Objectif Global Équipe</p>
                    <p className="text-[10px] text-text-secondary mt-0.5">500 000 MAD</p>
                  </div>
                  <div className="flex items-center gap-2 text-primary">
                    <Target size={16} />
                    <span className="text-sm font-black">{globalObjPct}%</span>
                  </div>
                </div>
                <div className="h-2 bg-slate-100 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-gradient-to-r from-primary to-secondary rounded-full transition-all duration-1000"
                    style={{ width: `${globalObjPct}%` }}
                  ></div>
                </div>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
};

export default ReportsView;
