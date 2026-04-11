import React, { useState } from 'react';
import { Eye, EyeOff, Lock, Mail, ArrowRight, Shield } from 'lucide-react';

const LoginView = ({ onLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    if (!email || !password) {
      setError('Veuillez remplir tous les champs.');
      return;
    }
    setIsLoading(true);
    // Simulate API call
    await new Promise(r => setTimeout(r, 1200));
    if (email === 'admin@olympia.com' && password === 'admin123') {
      onLogin?.();
    } else {
      setError('Email ou mot de passe incorrect.');
    }
    setIsLoading(false);
  };

  return (
    <div className="min-h-screen bg-background flex">
      {/* Left Panel - Branding */}
      <div className="hidden lg:flex w-[45%] bg-gradient-to-br from-primary to-primary-dark relative overflow-hidden flex-col justify-between p-12">
        {/* Background decoration */}
        <div className="absolute inset-0">
          <div className="absolute top-[-100px] right-[-100px] w-[400px] h-[400px] bg-white/5 rounded-full blur-3xl"></div>
          <div className="absolute bottom-[-50px] left-[-50px] w-[300px] h-[300px] bg-white/5 rounded-full blur-3xl"></div>
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-white/3 rounded-full blur-3xl"></div>
        </div>

        {/* Logo */}
        <div className="relative z-10 flex items-center gap-3">
          <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
            <Shield size={20} className="text-white" />
          </div>
          <span className="text-2xl font-black italic tracking-tighter text-white">Olympia</span>
        </div>

        {/* Center Content */}
        <div className="relative z-10">
          <div className="mb-8">
            <div className="inline-flex items-center gap-2 bg-white/15 backdrop-blur-sm px-4 py-2 rounded-full mb-6">
              <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
              <span className="text-white/80 text-xs font-bold uppercase tracking-widest">Système Actif</span>
            </div>
            <h2 className="text-4xl font-black text-white leading-tight mb-4">
              Pilotez vos<br />performances<br />
              <span className="text-white/60">en temps réel.</span>
            </h2>
            <p className="text-white/60 text-base leading-relaxed">
              Gérez votre équipe commerciale, validez les demandes et suivez le CA — tout depuis un seul tableau de bord.
            </p>
          </div>

          {/* Stats preview */}
          <div className="grid grid-cols-3 gap-4">
            {[
              { label: 'CA ce mois', value: '125K', unit: 'MAD' },
              { label: 'Demandes', value: '24', unit: 'actives' },
              { label: 'Commerciaux', value: '8', unit: 'actifs' },
            ].map((stat, i) => (
              <div key={i} className="bg-white/10 backdrop-blur-sm rounded-2xl p-4 border border-white/10">
                <p className="text-white text-xl font-black">{stat.value}<span className="text-xs font-normal text-white/60 ml-1">{stat.unit}</span></p>
                <p className="text-white/50 text-[10px] font-bold uppercase tracking-widest mt-1">{stat.label}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Footer */}
        <div className="relative z-10">
          <p className="text-white/30 text-xs font-medium">© 2024 Olympia. Plateforme B2B Commerciale.</p>
        </div>
      </div>

      {/* Right Panel - Login Form */}
      <div className="flex-1 flex flex-col items-center justify-center px-6 lg:px-16">
        {/* Mobile logo */}
        <div className="lg:hidden flex items-center gap-3 mb-12">
          <div className="w-10 h-10 bg-primary rounded-xl flex items-center justify-center">
            <Shield size={20} className="text-white" />
          </div>
          <span className="text-2xl font-black italic tracking-tighter text-primary">Olympia</span>
        </div>

        <div className="w-full max-w-[420px]">
          <div className="mb-10">
            <h1 className="text-3xl font-black text-text-primary tracking-tight mb-2">Bon retour !</h1>
            <p className="text-text-secondary font-medium">Connectez-vous à votre espace administrateur.</p>
          </div>

          {/* Error Banner */}
          {error && (
            <div className="mb-6 p-4 bg-red-50 border border-red-100 rounded-xl flex items-center gap-3 animate-in fade-in slide-in-from-top-2 duration-300">
              <div className="w-8 h-8 bg-red-100 rounded-lg flex items-center justify-center shrink-0">
                <Lock size={14} className="text-error" />
              </div>
              <p className="text-sm font-bold text-error">{error}</p>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Email Field */}
            <div className="space-y-2">
              <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">
                Email professionnel
              </label>
              <div className="relative">
                <Mail size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-text-secondary" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="admin@olympia.com"
                  className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/40 focus:bg-white focus:shadow-sm transition-all font-medium text-text-primary placeholder:text-slate-300"
                  autoComplete="email"
                />
              </div>
            </div>

            {/* Password Field */}
            <div className="space-y-2">
              <label className="text-xs font-bold text-text-secondary uppercase tracking-widest pl-1">
                Mot de passe
              </label>
              <div className="relative">
                <Lock size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-text-secondary" />
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full pl-12 pr-14 py-4 bg-slate-50 border border-slate-100 rounded-xl outline-none focus:border-primary/40 focus:bg-white focus:shadow-sm transition-all font-medium text-text-primary placeholder:text-slate-300"
                  autoComplete="current-password"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-1/2 -translate-y-1/2 text-text-secondary hover:text-primary transition-colors p-1"
                >
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>

            {/* Remember me + Forgot password */}
            <div className="flex items-center justify-between">
              <label className="flex items-center gap-2 cursor-pointer group">
                <div
                  onClick={() => setRememberMe(!rememberMe)}
                  className={`w-5 h-5 rounded-md border-2 flex items-center justify-center transition-all ${
                    rememberMe ? 'bg-primary border-primary' : 'border-slate-200 bg-white'
                  }`}
                >
                  {rememberMe && (
                    <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                      <path d="M1 4L3.5 6.5L9 1" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                    </svg>
                  )}
                </div>
                <span className="text-sm font-medium text-text-secondary group-hover:text-text-primary transition-colors">
                  Se souvenir de moi
                </span>
              </label>
              <button type="button" className="text-sm font-bold text-primary hover:text-primary-dark transition-colors hover:underline">
                Mot de passe oublié ?
              </button>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full py-4 bg-primary text-white rounded-xl font-bold flex items-center justify-center gap-3 shadow-lg shadow-primary/25 transition-all hover:bg-primary-dark hover:-translate-y-0.5 hover:shadow-xl hover:shadow-primary/30 disabled:opacity-70 disabled:cursor-not-allowed disabled:transform-none mt-2"
            >
              {isLoading ? (
                <>
                  <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                  <span>Connexion en cours...</span>
                </>
              ) : (
                <>
                  <span>Se connecter</span>
                  <ArrowRight size={18} />
                </>
              )}
            </button>
          </form>

          {/* Demo credentials hint */}
          <div className="mt-8 p-4 bg-slate-50 rounded-xl border border-slate-100">
            <p className="text-[10px] font-bold text-text-secondary uppercase tracking-widest mb-2">Accès démo</p>
            <p className="text-xs font-medium text-text-secondary">
              Email: <span className="font-bold text-text-primary">admin@olympia.com</span>
            </p>
            <p className="text-xs font-medium text-text-secondary mt-1">
              Mot de passe: <span className="font-bold text-text-primary">admin123</span>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LoginView;
