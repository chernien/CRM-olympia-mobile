import React, { useState, useRef, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { MoreVertical } from 'lucide-react';

const ActionMenu = ({ 
  actions = [], 
  icon: Icon = MoreVertical,
  className = "",
  buttonClassName = "p-2 text-text-secondary hover:bg-slate-100 rounded-lg transition-all"
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [coords, setCoords] = useState({ top: 0, left: 0, placement: 'bottom' });
  const triggerRef = useRef(null);
  const dropdownRef = useRef(null);

  const updatePosition = () => {
    if (triggerRef.current) {
      const rect = triggerRef.current.getBoundingClientRect();
      const dropdownHeight = actions.length * 48 + 16; // Approx height
      const dropdownWidth = 180;
      
      const spaceBelow = window.innerHeight - rect.bottom;
      const placement = spaceBelow < dropdownHeight && rect.top > dropdownHeight ? 'top' : 'bottom';
      
      let leftOffset = rect.right - dropdownWidth; // Right-aligned by default
      if (leftOffset < 16) {
        leftOffset = 16; // Prevent overflowing left
      }
      
      setCoords({
        top: placement === 'bottom' ? rect.bottom + 4 : rect.top - 4,
        left: leftOffset,
        placement
      });
    }
  };

  useEffect(() => {
    if (isOpen) {
      window.addEventListener('scroll', updatePosition, true);
      window.addEventListener('resize', updatePosition);
    }
    return () => {
      window.removeEventListener('scroll', updatePosition, true);
      window.removeEventListener('resize', updatePosition);
    };
  }, [isOpen]);

  const handleToggle = (e) => {
    e.stopPropagation();
    if (!isOpen) updatePosition();
    setIsOpen(!isOpen);
  };

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target) && 
          triggerRef.current && !triggerRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };
    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [isOpen]);

  const menuDropdown = (
    <div 
      ref={dropdownRef}
      style={{ 
        position: 'fixed', 
        top: coords.placement === 'bottom' ? `${coords.top}px` : 'auto',
        bottom: coords.placement === 'top' ? `${window.innerHeight - coords.top}px` : 'auto',
        left: `${coords.left}px`,
        width: '180px'
      }}
      className={`
        bg-white rounded-xl shadow-premium border border-slate-100 z-[9999] p-1 
        animate-in fade-in 
        ${coords.placement === 'bottom' ? 'slide-in-from-top-2' : 'slide-in-from-bottom-2'} 
        duration-200
      `}
      onClick={(e) => e.stopPropagation()}
    >
      {actions.map((action, index) => {
        const ActionIcon = action.icon;
        const isDanger = action.variant === 'danger';
        
        return (
          <button
            key={index}
            onClick={(e) => {
              e.stopPropagation();
              action.onClick();
              setIsOpen(false);
            }}
            className={`
              w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-semibold transition-colors
              ${isDanger 
                ? 'text-error hover:bg-error/10' 
                : 'text-text-primary hover:bg-slate-50 hover:text-primary'}
            `}
          >
            {ActionIcon && <ActionIcon size={16} />}
            <span>{action.label}</span>
          </button>
        );
      })}
    </div>
  );

  return (
    <div className={`relative ${className}`}>
      <button 
        ref={triggerRef}
        onClick={handleToggle}
        className={buttonClassName}
      >
        <Icon size={16} />
      </button>

      {isOpen && createPortal(menuDropdown, document.body)}
    </div>
  );
};

export default ActionMenu;
