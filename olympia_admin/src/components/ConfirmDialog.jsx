import React, { useEffect } from 'react';
import { createPortal } from 'react-dom';
import { AlertTriangle, Trash2, X } from 'lucide-react';

/**
 * ConfirmDialog - Reusable confirmation modal
 * Props:
 *   isOpen: boolean
 *   onClose: () => void
 *   onConfirm: () => void
 *   title: string
 *   message: string
 *   confirmLabel?: string  (default: "Confirmer")
 *   variant?: 'danger' | 'warning' | 'default'
 *   isLoading?: boolean
 */
const ConfirmDialog = ({
  isOpen,
  onClose,
  onConfirm,
  title = 'Confirmer l\'action',
  message = 'Êtes-vous sûr de vouloir effectuer cette action ?',
  confirmLabel = 'Confirmer',
  variant = 'danger',
  isLoading = false,
}) => {
  useEffect(() => {
    const handleEsc = (e) => { if (e.key === 'Escape') onClose(); };
    window.addEventListener('keydown', handleEsc);
    if (isOpen) document.body.style.overflow = 'hidden';
    return () => {
      window.removeEventListener('keydown', handleEsc);
      document.body.style.overflow = 'unset';
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const variantStyles = {
    danger: {
      icon: <Trash2 size={22} className="text-error" />,
      iconBg: 'bg-red-50',
      confirmBtn: 'bg-error hover:bg-red-600 shadow-red-200',
    },
    warning: {
      icon: <AlertTriangle size={22} className="text-warning" />,
      iconBg: 'bg-amber-50',
      confirmBtn: 'bg-warning hover:bg-amber-600 shadow-amber-200',
    },
    default: {
      icon: <AlertTriangle size={22} className="text-primary" />,
      iconBg: 'bg-blue-50',
      confirmBtn: 'bg-primary hover:bg-primary-dark shadow-primary/20',
    },
  };

  const styles = variantStyles[variant];

  return createPortal(
    <div
      className="fixed inset-0 z-[3000] flex items-center justify-center p-4 bg-black/20 backdrop-blur-sm"
      onClick={onClose}
    >
      <div
        className="bg-white rounded-premium w-full max-w-[420px] shadow-modal animate-in fade-in zoom-in-95 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="p-6 flex flex-col items-center text-center">
          {/* Icon */}
          <div className={`w-16 h-16 ${styles.iconBg} rounded-2xl flex items-center justify-center mb-5`}>
            {styles.icon}
          </div>

          {/* Close button */}
          <button
            onClick={onClose}
            className="absolute top-4 right-4 w-8 h-8 rounded-full flex items-center justify-center text-text-secondary hover:bg-slate-50 hover:text-error transition-all"
          >
            <X size={16} />
          </button>

          <h3 className="text-lg font-bold text-text-primary mb-2">{title}</h3>
          <p className="text-sm text-text-secondary leading-relaxed font-medium">{message}</p>
        </div>

        <div className="px-6 pb-6 flex gap-3">
          <button
            onClick={onClose}
            disabled={isLoading}
            className="flex-1 py-3 text-sm font-bold text-text-secondary bg-slate-50 rounded-xl hover:bg-slate-100 transition-all border border-slate-100 disabled:opacity-50"
          >
            Annuler
          </button>
          <button
            onClick={onConfirm}
            disabled={isLoading}
            className={`flex-1 py-3 text-sm font-bold text-white rounded-xl transition-all shadow-lg disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 ${styles.confirmBtn}`}
          >
            {isLoading ? (
              <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
            ) : confirmLabel}
          </button>
        </div>
      </div>
    </div>,
    document.body
  );
};

export default ConfirmDialog;
