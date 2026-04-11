import React from 'react';
import { createPortal } from 'react-dom';
import { X, Bell, Info, AlertTriangle, CheckCircle } from 'lucide-react';

const NotificationSheet = ({ isOpen, onClose }) => {
  if (!isOpen) return null;

  const notifications = [
    { id: 1, type: 'info', title: 'Nouvelle Demande', message: 'La Société Alpha a soumis une demande d\'échantillons.', time: 'il y a 5 min' },
    { id: 2, type: 'warning', title: 'Tâche en retard', message: 'La tâche "Livraison Peinture" est en retard.', time: 'il y a 2h' },
    { id: 3, type: 'success', title: 'Paiement Validé', message: 'Le paiement de BatiConstruit a été confirmé.', time: 'il y a 1j' },
  ];

  const getIcon = (type) => {
    switch(type) {
      case 'info': return <Info size={18} className="text-primary" />;
      case 'warning': return <AlertTriangle size={18} className="text-warning" />;
      case 'success': return <CheckCircle size={18} className="text-success" />;
      default: return <Bell size={18} />;
    }
  };

  return createPortal(
    <div className="fixed inset-0 bg-black/10 backdrop-blur-[4px] z-[2000] flex justify-end" onClick={onClose}>
      <div 
        className="w-[400px] h-full bg-white shadow-sidebar flex flex-col animate-in slide-in-from-right duration-500 ease-in-out" 
        onClick={e => e.stopPropagation()}
      >
        <div className="p-6 border-b border-slate-50 flex justify-between items-center">
          <div className="flex items-center gap-3 text-text-primary">
            <Bell size={20} />
            <h2 className="text-lg font-bold">Notifications</h2>
          </div>
          <button 
            className="w-8 h-8 rounded-full bg-slate-50 flex items-center justify-center text-text-secondary hover:bg-red-50 hover:text-error transition-all" 
            onClick={onClose}
          >
            <X size={20} />
          </button>
        </div>
        
        <div className="flex-1 overflow-y-auto p-6 flex flex-col gap-4">
          {notifications.map(notif => (
            <div key={notif.id} className="flex gap-4 p-4 rounded-xl bg-slate-50 border border-transparent transition-all hover:border-primary/20 hover:-translate-y-0.5">
              <div className="w-10 h-10 rounded-lg bg-white flex items-center justify-center shadow-sm shrink-0">
                {getIcon(notif.type)}
              </div>
              <div className="flex-1">
                <h4 className="text-sm font-bold text-text-primary mb-1">{notif.title}</h4>
                <p className="text-xs text-text-secondary leading-relaxed mb-2">{notif.message}</p>
                <span className="text-[10px] font-bold text-primary uppercase">{notif.time}</span>
              </div>
            </div>
          ))}
        </div>

        <div className="p-6 border-t border-slate-50">
          <button className="w-full py-3 bg-primary text-white border-none rounded-xl font-bold transition-all hover:bg-primary-dark hover:shadow-lg hover:shadow-primary/20">
            Tout marquer comme lu
          </button>
        </div>
      </div>
    </div>,
    document.body
  );
};

export default NotificationSheet;
